import { ICompaniesRepository } from '@modules/companies/repositories/ICompaniesRepository';
import { IHashProvider } from '@shared/providers/HashProvider/IHashProvider';
import { AppError } from '@shared/errors/AppError';
import { Company } from '@prisma/client';
import { z } from 'zod';

// Schema de validacao com Zod
export const createCompanySchema = z.object({
  cnpj: z.string().length(14, 'CNPJ deve ter 14 digitos'),
  razao_social: z.string().min(3),
  nome_fantasia: z.string().min(3),
  password: z.string().min(6, 'A senha deve ter no minimo 6 caracteres'),
});

type IRequest = z.infer<typeof createCompanySchema>;

export class CreateCompanyUseCase {
  // Injetando dependencias para manter o caso de uso desacoplado e testavel
  constructor(
    private companiesRepository: ICompaniesRepository,
    private hashProvider: IHashProvider
  ) {}

  async execute(data: IRequest): Promise<Omit<Company, 'password_hash'>> {
    // Regra de Negocio: Validar se o CNPJ ja existe
    const companyAlreadyExists = await this.companiesRepository.findByCnpj(data.cnpj);
    if (companyAlreadyExists) {
      throw new AppError('Uma empresa com este CNPJ ja esta cadastrada.');
    }

    // Regra de Negocio: Criptografar a senha
    const passwordHash = await this.hashProvider.generateHash(data.password);

    // Regra de Negocio: Definir data de expiracao do Trial (14 dias)
    const trialPeriodInDays = 14;
    const planExpiresAt = new Date();
    planExpiresAt.setDate(planExpiresAt.getDate() + trialPeriodInDays);

    const company = await this.companiesRepository.create({
      cnpj: data.cnpj,
      razao_social: data.razao_social,
      nome_fantasia: data.nome_fantasia,
      password_hash: passwordHash,
      plan_expires_at: planExpiresAt,
    });
    
    // Removendo o hash da senha do objeto de retorno por seguranca
    const { password_hash, ...companyWithoutPassword } = company;
    return companyWithoutPassword;
  }
}
