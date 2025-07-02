import { Company, Prisma } from '@prisma/client';
import { prisma } from '@shared/infra/prisma';
import { ICompaniesRepository } from '../ICompaniesRepository';

// Implementacao concreta do repositorio de empresas usando Prisma.
export class PrismaCompaniesRepository implements ICompaniesRepository {
  async create(data: Prisma.CompanyCreateInput): Promise<Company> {
    const company = await prisma.company.create({ data });
    return company;
  }

  async findByCnpj(cnpj: string): Promise<Company | null> {
    const company = await prisma.company.findUnique({ where: { cnpj } });
    return company;
  }

  async findById(id: string): Promise<Company | null> {
    const company = await prisma.company.findUnique({ where: { id } });
    return company;
  }
}
