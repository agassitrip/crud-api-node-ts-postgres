# encoding: utf8
# Script PowerShell para gerar a estrutura completa de um projeto Node.js com TypeScript.
# Autor: Gemini AI, a pedido de Vinicius Agassi

Clear-Host
Write-Host "======================================================" -ForegroundColor Green
Write-Host "INICIANDO A GERACAO DO PROJETO NODE.JS + TYPESCRIPT" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host

# --- Definição da Estrutura de Pastas ---
Write-Host "Criando estrutura de diretorios..." -ForegroundColor Cyan
$projectRoot = $PSScriptRoot
$directories = @(
    "prisma",
    "src/modules/companies/repositories/implementations",
    "src/modules/companies/useCases/authenticateCompany",
    "src/modules/companies/useCases/createCompany",
    "src/modules/companies/useCases/getCompanyProfile",
    "src/shared/container",
    "src/shared/errors",
    "src/shared/infra/http/middlewares",
    "src/shared/infra/http/routes",
    "src/shared/infra/prisma",
    "src/shared/providers/HashProvider/implementations",
    "src/shared/providers/TokenProvider/implementations"
)

foreach ($dir in $directories) {
    $fullPath = Join-Path -Path $projectRoot -ChildPath $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    }
}
Write-Host "Estrutura de diretorios criada com sucesso." -ForegroundColor Green
Write-Host

# --- Geração dos Arquivos de Configuração ---
Write-Host "Gerando arquivos de configuracao..." -ForegroundColor Cyan

# package.json
$packageJsonContent = @"
{
  "name": "crud-api-node-ts-postgres",
  "version": "1.0.0",
  "description": "API RESTful para cadastro e autenticacao de empresas, construida com Node.js, TypeScript, PostgreSQL e Docker.",
  "main": "index.js",
  "author": "Vinicius Agassi",
  "scripts": {
    "dev": "tsx watch src/shared/infra/http/server.ts",
    "build": "tsup src --out-dir build"
  },
  "keywords": [],
  "license": "MIT",
  "devDependencies": {
    "@types/bcryptjs": "^2.4.6",
    "@types/express": "^4.17.21",
    "@types/jsonwebtoken": "^9.0.6",
    "@types/node": "^20.14.2",
    "prisma": "^5.15.0",
    "tsup": "^8.1.0",
    "tsx": "^4.15.2",
    "typescript": "^5.4.5"
  },
  "dependencies": {
    "@prisma/client": "^5.15.0",
    "bcryptjs": "^2.4.3",
    "dotenv": "^16.4.5",
    "express": "^4.19.2",
    "express-async-errors": "^3.1.1",
    "jsonwebtoken": "^9.0.2",
    "zod": "^3.23.8"
  }
}
"@
Set-Content -Path (Join-Path $projectRoot "package.json") -Value $packageJsonContent

# tsconfig.json
$tsconfigContent = @"
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "skipLibCheck": true,
    "baseUrl": ".",
    "paths": {
      "@modules/*": ["src/modules/*"],
      "@shared/*": ["src/shared/*"]
    },
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true
  }
}
"@
Set-Content -Path (Join-Path $projectRoot "tsconfig.json") -Value $tsconfigContent

# .gitignore
$gitignoreContent = @"
# Dependencias
node_modules
dist
build

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Arquivos de ambiente
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDEs e editores
.vscode/
.idea/
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?
"@
Set-Content -Path (Join-Path $projectRoot ".gitignore") -Value $gitignoreContent

# .env.example
$envExampleContent = @"
# Variaveis de Ambiente - NUNCA comite o arquivo .env!

# Configuracoes do Banco de Dados (Docker Compose vai usar isso)
POSTGRES_USER=docker
POSTGRES_PASSWORD=docker
POSTGRES_DB=crudapi
DATABASE_URL="postgresql://docker:docker@localhost:5432/crudapi?schema=public"

# Configuracoes da Aplicacao
PORT=3333

# JWT (use um segredo forte e aleatorio)
JWT_SECRET=super-secret-key-for-dev-change-it
JWT_EXPIRES_IN=1d
"@
Set-Content -Path (Join-Path $projectRoot ".env.example") -Value $envExampleContent

# docker-compose.yml
$dockerComposeContent = @"
version: '3.8'

services:
  postgres:
    image: postgres:14-alpine
    container_name: crud-postgres-ps
    restart: always
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=\${POSTGRES_USER}
      - POSTGRES_PASSWORD=\${POSTGRES_PASSWORD}
      - POSTGRES_DB=\${POSTGRES_DB}
    volumes:
      - pgdata:/data/postgres

volumes:
  pgdata:
    driver: local
"@
Set-Content -Path (Join-Path $projectRoot "docker-compose.yml") -Value $dockerComposeContent

# prisma/schema.prisma
$prismaSchemaContent = @"
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Company {
  id            String   @id @default(cuid())
  cnpj          String   @unique
  razao_social  String
  nome_fantasia String
  password_hash String

  // Controla a data de expiracao do plano/trial
  plan_expires_at DateTime @map("plan_expires_at")

  created_at DateTime @default(now())
  updated_at DateTime @updatedAt

  @@map("companies")
}
"@
Set-Content -Path (Join-Path $projectRoot "prisma/schema.prisma") -Value $prismaSchemaContent

Write-Host "Arquivos de configuracao gerados." -ForegroundColor Green
Write-Host

# --- Geração do Código Fonte ---
Write-Host "Gerando codigo-fonte da aplicacao..." -ForegroundColor Cyan

# --- CAMADA SHARED ---
Set-Content -Path "src/shared/errors/AppError.ts" -Value @"
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
"@

Set-Content -Path "src/shared/infra/http/server.ts" -Value @"
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
      message: `Internal server error`,
    });
  }
);

const PORT = process.env.PORT || 3333;

app.listen(PORT, () => console.log(`Server is running on port \${PORT}`));
"@

Set-Content -Path "src/shared/infra/http/routes/index.ts" -Value @"
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
"@

# --- ARQUIVOS DOS MÓDULOS ---

# Interfaces de Repositório e Provedores
Set-Content -Path "src/modules/companies/repositories/ICompaniesRepository.ts" -Value @"
import { Company, Prisma } from '@prisma/client';

export interface ICompaniesRepository {
  create(data: Prisma.CompanyCreateInput): Promise<Company>;
  findByCnpj(cnpj: string): Promise<Company | null>;
  findById(id: string): Promise<Company | null>;
}
"@
Set-Content -Path "src/shared/providers/HashProvider/IHashProvider.ts" -Value @"
export interface IHashProvider {
  generateHash(payload: string): Promise<string>;
  compareHash(payload: string, hashed: string): Promise<boolean>;
}
"@
Set-Content -Path "src/shared/providers/TokenProvider/ITokenProvider.ts" -Value @"
export interface ITokenProvider {
  generateToken(payload: { sub: string }): string;
  verifyToken(token: string): { sub: string };
}
"@

# Implementações (Prisma, Bcrypt, JWT)
Set-Content -Path "src/modules/companies/repositories/implementations/PrismaCompaniesRepository.ts" -Value @"
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
"@
Set-Content -Path "src/shared/providers/HashProvider/implementations/BCryptHashProvider.ts" -Value @"
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
"@
Set-Content -Path "src/shared/providers/TokenProvider/implementations/JWTTokenProvider.ts" -Value @"
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
"@

# Casos de Uso (Use Cases) e Controladores
# CreateCompany
Set-Content -Path "src/modules/companies/useCases/createCompany/CreateCompanyUseCase.ts" -Value @"
import { ICompaniesRepository } from '@modules/companies/repositories/ICompaniesRepository';
import { IHashProvider } from '@shared/providers/HashProvider/IHashProvider';
import { AppError } from '@shared/errors/AppError';
import { Company } from '@prisma/client';
import { z } from 'zod';

// Schema de validacao com Zod
export const createCompanySchema = z.object({
  cnpj: z.string().length(14, 'CNPJ deve ter 14 digitos'),
  razao_social: z.string().min(3),
  nome_fantasia: z.string().min(3),
  password: z.string().min(6, 'A senha deve ter no minimo 6 caracteres'),
});

type IRequest = z.infer<typeof createCompanySchema>;

export class CreateCompanyUseCase {
  // Injetando dependencias para manter o caso de uso desacoplado e testavel
  constructor(
    private companiesRepository: ICompaniesRepository,
    private hashProvider: IHashProvider
  ) {}

  async execute(data: IRequest): Promise<Omit<Company, 'password_hash'>> {
    // Regra de Negocio: Validar se o CNPJ ja existe
    const companyAlreadyExists = await this.companiesRepository.findByCnpj(data.cnpj);
    if (companyAlreadyExists) {
      throw new AppError('Uma empresa com este CNPJ ja esta cadastrada.');
    }

    // Regra de Negocio: Criptografar a senha
    const passwordHash = await this.hashProvider.generateHash(data.password);

    // Regra de Negocio: Definir data de expiracao do Trial (14 dias)
    const trialPeriodInDays = 14;
    const planExpiresAt = new Date();
    planExpiresAt.setDate(planExpiresAt.getDate() + trialPeriodInDays);

    const company = await this.companiesRepository.create({
      cnpj: data.cnpj,
      razao_social: data.razao_social,
      nome_fantasia: data.nome_fantasia,
      password_hash: passwordHash,
      plan_expires_at: planExpiresAt,
    });
    
    // Removendo o hash da senha do objeto de retorno por seguranca
    const { password_hash, ...companyWithoutPassword } = company;
    return companyWithoutPassword;
  }
}
"@
Set-Content -Path "src/modules/companies/useCases/createCompany/CreateCompanyController.ts" -Value @"
import { Request, Response } from 'express';
import { CreateCompanyUseCase, createCompanySchema } from './CreateCompanyUseCase';
import { PrismaCompaniesRepository } from '@modules/companies/repositories/implementations/PrismaCompaniesRepository';
import { BCryptHashProvider } from '@shared/providers/HashProvider/implementations/BCryptHashProvider';

export class CreateCompanyController {
  async handle(request: Request, response: Response): Promise<Response> {
    // 1. Validacao dos dados de entrada com Zod
    const validationResult = createCompanySchema.safeParse(request.body);
    if (!validationResult.success) {
      return response.status(400).json({ errors: validationResult.error.flatten().fieldErrors });
    }
    const { cnpj, nome_fantasia, razao_social, password } = validationResult.data;

    // 2. Injecao manual de dependencia
    const companiesRepository = new PrismaCompaniesRepository();
    const hashProvider = new BCryptHashProvider();
    const createCompanyUseCase = new CreateCompanyUseCase(companiesRepository, hashProvider);

    // 3. Execucao do caso de uso
    const company = await createCompanyUseCase.execute({ cnpj, nome_fantasia, razao_social, password });

    return response.status(201).json(company);
  }
}
"@
# AuthenticateCompany
Set-Content -Path "src/modules/companies/useCases/authenticateCompany/AuthenticateCompanyUseCase.ts" -Value @"
import { ICompaniesRepository } from '@modules/companies/repositories/ICompaniesRepository';
import { IHashProvider } from '@shared/providers/HashProvider/IHashProvider';
import { ITokenProvider } from '@shared/providers/TokenProvider/ITokenProvider';
import { AppError } from '@shared/errors/AppError';

interface IRequest {
  cnpj: string;
  password: string;
}

interface IResponse {
  company: { id: string; nome_fantasia: string; };
  token: string;
}

export class AuthenticateCompanyUseCase {
  constructor(
    private companiesRepository: ICompaniesRepository,
    private hashProvider: IHashProvider,
    private tokenProvider: ITokenProvider
  ) {}

  async execute({ cnpj, password }: IRequest): Promise<IResponse> {
    const company = await this.companiesRepository.findByCnpj(cnpj);
    if (!company) {
      throw new AppError('CNPJ ou senha incorretos.', 401);
    }

    const passwordMatch = await this.hashProvider.compareHash(password, company.password_hash);
    if (!passwordMatch) {
      throw new AppError('CNPJ ou senha incorretos.', 401);
    }

    const token = this.tokenProvider.generateToken({ sub: company.id });

    return {
      company: { id: company.id, nome_fantasia: company.nome_fantasia },
      token,
    };
  }
}
"@
Set-Content -Path "src/modules/companies/useCases/authenticateCompany/AuthenticateCompanyController.ts" -Value @"
import { Request, Response } from 'express';
import { AuthenticateCompanyUseCase } from './AuthenticateCompanyUseCase';
import { PrismaCompaniesRepository } from '@modules/companies/repositories/implementations/PrismaCompaniesRepository';
import { BCryptHashProvider } from '@shared/providers/HashProvider/implementations/BCryptHashProvider';
import { JWTTokenProvider } from '@shared/providers/TokenProvider/implementations/JWTTokenProvider';

export class AuthenticateCompanyController {
  async handle(request: Request, response: Response): Promise<Response> {
    const { cnpj, password } = request.body;
    
    const companiesRepository = new PrismaCompaniesRepository();
    const hashProvider = new BCryptHashProvider();
    const tokenProvider = new JWTTokenProvider();
    const authenticateCompanyUseCase = new AuthenticateCompanyUseCase(companiesRepository, hashProvider, tokenProvider);

    const result = await authenticateCompanyUseCase.execute({ cnpj, password });

    return response.json(result);
  }
}
"@
# GetCompanyProfile
Set-Content -Path "src/modules/companies/useCases/getCompanyProfile/GetCompanyProfileUseCase.ts" -Value @"
import { ICompaniesRepository } from '@modules/companies/repositories/ICompaniesRepository';
import { AppError } from '@shared/errors/AppError';
import { Company } from '@prisma/client';

export class GetCompanyProfileUseCase {
  constructor(private companiesRepository: ICompaniesRepository) {}

  async execute(company_id: string): Promise<Omit<Company, 'password_hash'>> {
    const company = await this.companiesRepository.findById(company_id);
    if (!company) {
      throw new AppError('Empresa nao encontrada.', 404);
    }
    const { password_hash, ...profile } = company;
    return profile;
  }
}
"@
Set-Content -Path "src/modules/companies/useCases/getCompanyProfile/GetCompanyProfileController.ts" -Value @"
import { Request, Response } from 'express';
import { GetCompanyProfileUseCase } from './GetCompanyProfileUseCase';
import { PrismaCompaniesRepository } from '@modules/companies/repositories/implementations/PrismaCompaniesRepository';

export class GetCompanyProfileController {
  async handle(request: Request, response: Response): Promise<Response> {
    // O ID da empresa e adicionado ao request pelo middleware de autenticacao
    const { company_id } = request;
    
    const companiesRepository = new PrismaCompaniesRepository();
    const getCompanyProfileUseCase = new GetCompanyProfileUseCase(companiesRepository);

    const company = await getCompanyProfileUseCase.execute(company_id);

    return response.json(company);
  }
}
"@

# Rotas e Middlewares
Set-Content -Path "src/shared/infra/http/routes/companies.routes.ts" -Value @"
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
"@

Set-Content -Path "src/shared/infra/http/middlewares/ensureAuthenticated.ts" -Value @"
import { NextFunction, Request, Response } from 'express';
import { AppError } from '@shared/errors/AppError';
import { JWTTokenProvider } from '@shared/providers/TokenProvider/implementations/JWTTokenProvider';

// Adicionando a propriedade `company_id` a interface Request do Express para tipagem
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
"@

Set-Content -Path "src/shared/infra/http/middlewares/checkTrial.ts" -Value @"
import { NextFunction, Request, Response } from 'express';
import { AppError } from '@shared/errors/AppError';
import { PrismaCompaniesRepository } from '@modules/companies/repositories/implementations/PrismaCompaniesRepository';

// Middleware que verifica se o periodo de trial da empresa expirou.
// Deve ser usado SEMPRE APOS o middleware `ensureAuthenticated`.
export async function checkTrial(
  request: Request,
  response: Response,
  next: NextFunction
): Promise<void> {
  const { company_id } = request; // Pega o ID injetado pelo `ensureAuthenticated`
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
"@

Write-Host "Codigo-fonte da aplicacao gerado." -ForegroundColor Green
Write-Host

# --- Finalização ---
Write-Host "======================================================" -ForegroundColor Green
Write-Host "PROJETO GERADO COM SUCESSO!" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "1. Copie o arquivo .env.example para .env:" -ForegroundColor Yellow
Write-Host "   copy .env.example .env" -ForegroundColor White
Write-Host
Write-Host "2. Inicie o banco de dados com Docker:" -ForegroundColor Yellow
Write-Host "   docker-compose up -d" -ForegroundColor White
Write-Host
Write-Host "3. Instale as dependencias do Node.js:" -ForegroundColor Yellow
Write-Host "   npm install" -ForegroundColor White
Write-Host
Write-Host "4. Crie as tabelas no banco de dados com o Prisma:" -ForegroundColor Yellow
Write-Host "   npx prisma migrate dev --name init" -ForegroundColor White
Write-Host
Write-Host "5. Inicie a aplicacao em modo de desenvolvimento:" -ForegroundColor Yellow
Write-Host "   npm run dev" -ForegroundColor White
Write-Host
Write-Host "A API estara disponivel em http://localhost:3333" -ForegroundColor Cyan
Write-Host