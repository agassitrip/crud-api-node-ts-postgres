// Arquivo principal de rotas. Agrega todas as rotas dos modulos.
import { Router } from 'express';
import { companiesRoutes } from './companies.routes';

const routes = Router();

// Rota de 'health check' para verificar se a API esta online
routes.get('/', (req, res) => {
  return res.json({ message: 'API de Cadastro v1.0 - Online' });
});

// Agrupa todas as rotas relacionadas a empresas sob o prefixo /companies
routes.use('/companies', companiesRoutes);
// Reutiliza o mesmo router para a rota de login para manter a consistencia
routes.use('/sessions', companiesRoutes);

export { routes };
