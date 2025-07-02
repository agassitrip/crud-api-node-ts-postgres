import { Company, Prisma } from '@prisma/client';

export interface ICompaniesRepository {
  create(data: Prisma.CompanyCreateInput): Promise<Company>;
  findByCnpj(cnpj: string): Promise<Company | null>;
  findById(id: string): Promise<Company | null>;
}
