import { ICompaniesRepository } from '@modules/companies/repositories/ICompaniesRepository';
import { IHashProvider } from '@shared/providers/HashProvider/IHashProvider';
import { ITokenProvider } from '@shared/providers/TokenProvider/ITokenProvider';
import { AppError } from '@shared/errors/AppError';

interface IRequest {
  cnpj: string;
  password: string;
}

interface IResponse {
  company: { id: string; nome_fantasia: string; };
  token: string;
}

export class AuthenticateCompanyUseCase {
  constructor(
    private companiesRepository: ICompaniesRepository,
    private hashProvider: IHashProvider,
    private tokenProvider: ITokenProvider
  ) {}

  async execute({ cnpj, password }: IRequest): Promise<IResponse> {
    const company = await this.companiesRepository.findByCnpj(cnpj);
    if (!company) {
      throw new AppError('CNPJ ou senha incorretos.', 401);
    }

    const passwordMatch = await this.hashProvider.compareHash(password, company.password_hash);
    if (!passwordMatch) {
      throw new AppError('CNPJ ou senha incorretos.', 401);
    }

    const token = this.tokenProvider.generateToken({ sub: company.id });

    return {
      company: { id: company.id, nome_fantasia: company.nome_fantasia },
      token,
    };
  }
}
