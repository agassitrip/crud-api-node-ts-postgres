# Funcionalidades e Regras de Negócio da API

Este documento descreve as funcionalidades centrais e as regras de negócio que governam a nossa API de gestão de empresas.

## 1. Onboarding de Clientes (Cadastro)

O objetivo é fornecer um processo de entrada simples e rápido para novas empresas.

-   **Fluxo:** Uma empresa se cadastra fornecendo informações essenciais (CNPJ, Razão Social, Nome Fantasia) e criando uma credencial de acesso (senha).
-   **Regra de Negócio:** O CNPJ é o identificador único para cada empresa. O sistema não permite o cadastro de dois clientes com o mesmo CNPJ.
-   **Segurança:** A senha do cliente é criptografada (hashed) antes de ser armazenada, garantindo que ninguém, nem mesmo os administradores do sistema, tenha acesso à senha original.

## 2. Acesso Seguro à Plataforma (Autenticação)

Garantir que apenas usuários autorizados possam acessar suas informações e os recursos da plataforma.

-   **Fluxo:** O cliente informa seu CNPJ e senha para fazer login. Se as credenciais estiverem corretas, o sistema retorna um **Token de Acesso (JWT)**.
-   **Regra de Negócio:** Este token é temporário e deve ser enviado em todas as requisições futuras para acessar áreas protegidas, como o painel de controle.
-   **Benefício:** O uso de tokens JWT é um padrão de mercado que oferece alta segurança e permite que a autenticação seja "stateless" (sem estado), facilitando a escalabilidade da aplicação.

## 3. Modelo de Negócio: Período de Teste (Trial)

Oferecer uma degustação do serviço para atrair novos clientes, com conversão para um plano pago como objetivo final.

-   **Fluxo:** Ao se cadastrar, a empresa automaticamente ganha acesso completo à plataforma por um período de **14 dias**.
-   **Regra de Negócio:** A data de expiração do plano é calculada e salva no momento do cadastro (`data_de_cadastro + 14 dias`).
-   **Controle de Acesso:** Antes de permitir o acesso a funcionalidades-chave (como o "Dashboard"), o sistema verifica se o período de teste do cliente já expirou.
-   **Expansão Futura:** Este modelo é a base para um sistema de assinaturas. No futuro, podemos criar rotas para que o cliente possa contratar um plano (Básico, Premium), atualizando a data de expiração e o tipo do plano no seu cadastro.

## 4. Painel do Cliente (Dashboard Simples)

Um espaço central onde o cliente pode ver suas informações e acessar os recursos da plataforma.

-   **Fluxo:** Após o login, o cliente pode acessar uma rota `/profile` ou `/dashboard`.
-   **Regra de Negócio:** Esta é uma área protegida. O acesso só é permitido com um Token de Acesso válido e se o período de teste não tiver expirado.
-   **Funcionalidade:** Inicialmente, o painel exibe os dados cadastrais da empresa para confirmação. No futuro, pode ser expandido para mostrar gráficos, relatórios, atalhos para outras funcionalidades, etc.