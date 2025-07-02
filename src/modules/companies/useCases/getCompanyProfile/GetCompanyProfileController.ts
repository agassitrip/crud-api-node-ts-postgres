import { Request, Response } from 'express';
import { GetCompanyProfileUseCase } from './GetCompanyProfileUseCase';
import { PrismaCompaniesRepository } from '@modules/companies/repositories/implementations/PrismaCompaniesRepository';

export class GetCompanyProfileController {
  async handle(request: Request, response: Response): Promise<Response> {
    // O ID da empresa e adicionado ao request pelo middleware de autenticacao
    const { company_id } = request;
    
    const companiesRepository = new PrismaCompaniesRepository();
    const getCompanyProfileUseCase = new GetCompanyProfileUseCase(companiesRepository);

    const company = await getCompanyProfileUseCase.execute(company_id);

    return response.json(company);
  }
}
