export interface ITokenProvider {
  generateToken(payload: { sub: string }): string;
  verifyToken(token: string): { sub: string };
}
