import { Request, Response } from 'express';
import { CreateCompanyUseCase, createCompanySchema } from './CreateCompanyUseCase';
import { PrismaCompaniesRepository } from '@modules/companies/repositories/implementations/PrismaCompaniesRepository';
import { BCryptHashProvider } from '@shared/providers/HashProvider/implementations/BCryptHashProvider';

export class CreateCompanyController {
  async handle(request: Request, response: Response): Promise<Response> {
    // 1. Validacao dos dados de entrada com Zod
    const validationResult = createCompanySchema.safeParse(request.body);
    if (!validationResult.success) {
      return response.status(400).json({ errors: validationResult.error.flatten().fieldErrors });
    }
    const { cnpj, nome_fantasia, razao_social, password } = validationResult.data;

    // 2. Injecao manual de dependencia
    const companiesRepository = new PrismaCompaniesRepository();
    const hashProvider = new BCryptHashProvider();
    const createCompanyUseCase = new CreateCompanyUseCase(companiesRepository, hashProvider);

    // 3. Execucao do caso de uso
    const company = await createCompanyUseCase.execute({ cnpj, nome_fantasia, razao_social, password });

    return response.status(201).json(company);
  }
}
