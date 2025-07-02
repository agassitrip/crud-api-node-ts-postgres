import { compare, hash } from 'bcryptjs';
import { IHashProvider } from '../IHashProvider';

export class BCryptHashProvider implements IHashProvider {
  public async generateHash(payload: string): Promise<string> {
    return hash(payload, 8); // O '8' e o custo do hash (salt rounds)
  }

  public async compareHash(payload: string, hashed: string): Promise<boolean> {
    return compare(payload, hashed);
  }
}
