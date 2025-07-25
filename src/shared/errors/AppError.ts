// Classe de erro padronizada para a aplicacao.
// Permite lancar erros com uma mensagem e um codigo de status HTTP especifico.
export class AppError {
  public readonly message: string;
  public readonly statusCode: number;

  constructor(message: string, statusCode = 400) {
    this.message = message;
    this.statusCode = statusCode;
  }
}
