import { Router } from 'express';
import { CreateCompanyController } from '@modules/companies/useCases/createCompany/CreateCompanyController';
import { AuthenticateCompanyController } from '@modules/companies/useCases/authenticateCompany/AuthenticateCompanyController';
import { GetCompanyProfileController } from '@modules/companies/useCases/getCompanyProfile/GetCompanyProfileController';
import { ensureAuthenticated } from '../middlewares/ensureAuthenticated';
import { checkTrial } from '../middlewares/checkTrial';

const companiesRoutes = Router();

const createCompanyController = new CreateCompanyController();
const authenticateCompanyController = new AuthenticateCompanyController();
const getCompanyProfileController = new GetCompanyProfileController();

// Rota publica para criar empresa
companiesRoutes.post('/', createCompanyController.handle);

// Rota publica para login (sessao)
companiesRoutes.post('/sessions', authenticateCompanyController.handle);

// Rota de perfil/dashboard - Rota Protegida
// A ordem dos middlewares e importante: primeiro autentica, depois verifica o plano.
companiesRoutes.get(
  '/profile',
  ensureAuthenticated,
  checkTrial,
  getCompanyProfileController.handle
);

export { companiesRoutes };
