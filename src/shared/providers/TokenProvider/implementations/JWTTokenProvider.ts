import { sign, verify } from 'jsonwebtoken';
import { AppError } from '@shared/errors/AppError';
import { ITokenProvider } from '../ITokenProvider';

export class JWTTokenProvider implements ITokenProvider {
  private get secret(): string {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
      throw new AppError('JWT Secret not provided in .env file.');
    }
    return secret;
  }

  generateToken(payload: { sub: string }): string {
    return sign({}, this.secret, {
      subject: payload.sub, // 'sub' (subject) e o padrao JWT para o ID do usuario
      expiresIn: process.env.JWT_EXPIRES_IN || '1d',
    });
  }

  verifyToken(token: string): { sub: string } {
    try {
      const decoded = verify(token, this.secret);
      return decoded as { sub: string };
    } catch {
      throw new AppError('Invalid JWT token.', 401);
    }
  }
}
