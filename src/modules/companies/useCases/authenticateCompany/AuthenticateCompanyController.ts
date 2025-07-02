import { Request, Response } from 'express';
import { AuthenticateCompanyUseCase } from './AuthenticateCompanyUseCase';
import { PrismaCompaniesRepository } from '@modules/companies/repositories/implementations/PrismaCompaniesRepository';
import { BCryptHashProvider } from '@shared/providers/HashProvider/implementations/BCryptHashProvider';
import { JWTTokenProvider } from '@shared/providers/TokenProvider/implementations/JWTTokenProvider';

export class AuthenticateCompanyController {
  async handle(request: Request, response: Response): Promise<Response> {
    const { cnpj, password } = request.body;
    
    const companiesRepository = new PrismaCompaniesRepository();
    const hashProvider = new BCryptHashProvider();
    const tokenProvider = new JWTTokenProvider();
    const authenticateCompanyUseCase = new AuthenticateCompanyUseCase(companiesRepository, hashProvider, tokenProvider);

    const result = await authenticateCompanyUseCase.execute({ cnpj, password });

    return response.json(result);
  }
}
