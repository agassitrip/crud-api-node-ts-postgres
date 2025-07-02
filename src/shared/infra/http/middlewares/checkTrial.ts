import { NextFunction, Request, Response } from 'express';
import { AppError } from '@shared/errors/AppError';
import { PrismaCompaniesRepository } from '@modules/companies/repositories/implementations/PrismaCompaniesRepository';

// Middleware que verifica se o periodo de trial da empresa expirou.
// Deve ser usado SEMPRE APOS o middleware ensureAuthenticated.
export async function checkTrial(
  request: Request,
  response: Response,
  next: NextFunction
): Promise<void> {
  const { company_id } = request; // Pega o ID injetado pelo ensureAuthenticated
  const companiesRepository = new PrismaCompaniesRepository();

  const company = await companiesRepository.findById(company_id);

  if (!company) {
    throw new AppError('Empresa nao encontrada.', 404);
  }

  const today = new Date();
  if (today > company.plan_expires_at) {
    // 403 Forbidden: o usuario e conhecido, mas nao tem permissao para acessar o recurso.
    throw new AppError(
      'Seu periodo de teste expirou. Contrate um plano para continuar.',
      403 
    );
  }

  return next(); // Se o trial estiver ativo, permite o acesso.
}
