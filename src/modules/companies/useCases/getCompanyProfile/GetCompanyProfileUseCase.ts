import { ICompaniesRepository } from '@modules/companies/repositories/ICompaniesRepository';
import { AppError } from '@shared/errors/AppError';
import { Company } from '@prisma/client';

export class GetCompanyProfileUseCase {
  constructor(private companiesRepository: ICompaniesRepository) {}

  async execute(company_id: string): Promise<Omit<Company, 'password_hash'>> {
    const company = await this.companiesRepository.findById(company_id);
    if (!company) {
      throw new AppError('Empresa nao encontrada.', 404);
    }
    const { password_hash, ...profile } = company;
    return profile;
  }
}
