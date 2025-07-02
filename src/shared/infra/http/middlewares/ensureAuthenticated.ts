import { NextFunction, Request, Response } from 'express';
import { AppError } from '@shared/errors/AppError';
import { JWTTokenProvider } from '@shared/providers/TokenProvider/implementations/JWTTokenProvider';

// Adicionando a propriedade company_id a interface Request do Express para tipagem
declare global {
  namespace Express {
    export interface Request {
      company_id: string;
    }
  }
}

// Middleware para garantir que o usuario esta autenticado
export function ensureAuthenticated(
  request: Request,
  response: Response,
  next: NextFunction
): void {
  const authHeader = request.headers.authorization;

  if (!authHeader) {
    throw new AppError('Token JWT ausente.', 401);
  }

  // O formato do header e 'Bearer TOKEN'
  const [, token] = authHeader.split(' ');

  try {
    const tokenProvider = new JWTTokenProvider();
    const { sub: company_id } = tokenProvider.verifyToken(token);

    // Anexa o ID da empresa no objeto request para ser usado nas proximas etapas
    request.company_id = company_id;

    return next(); // Prossiga para a proxima etapa (proximo middleware ou controller)
  } catch {
    throw new AppError('Token JWT invalido.', 401);
  }
}
