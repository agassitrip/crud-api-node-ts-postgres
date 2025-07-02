# --- Estagio de Build ---
FROM node:18-alpine AS builder
ECHO est  desativado.
WORKDIR /app
ECHO est  desativado.
COPY package*.json ./
RUN npm install
ECHO est  desativado.
COPY . .
RUN npm run build
ECHO est  desativado.
# --- Estagio de Producao ---
FROM node:18-alpine
ECHO est  desativado.
WORKDIR /app
ECHO est  desativado.
COPY --from=builder /app/build ./build
COPY package*.json ./
ECHO est  desativado.
RUN npm install --omit=dev
ECHO est  desativado.
EXPOSE 3333
ECHO est  desativado.
CMD ["node", "build/shared/infra/http/server.js"]
