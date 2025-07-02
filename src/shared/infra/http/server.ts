import 'dotenv/config';
import express, { NextFunction, Request, Response } from 'express';
import 'express-async-errors'; // Essencial para capturar erros em funcoes async
import { AppError } from '@shared/errors/AppError';
import { routes } from './routes';

const app = express();

app.use(express.json()); // Habilita o parsing de JSON no corpo das requisicoes
app.use(routes); // Centraliza todas as rotas da aplicacao

// Middleware global para tratamento de erros.
// Deve vir depois das rotas.
app.use(
  (err: Error, request: Request, response: Response, next: NextFunction) => {
    // Se for um erro conhecido da nossa aplicacao, retorna o status code dele
    if (err instanceof AppError) {
      return response.status(err.statusCode).json({
        message: err.message,
      });
    }

    // Para erros inesperados (500), loga o erro e retorna uma mensagem generica
    console.error(err);
    return response.status(500).json({
      status: 'error',
      message: Internal server error,
    });
  }
);

const PORT = process.env.PORT || 3333;

app.listen(PORT, () => console.log(Server is running on port \));
