# Etapa 1: Build da aplicação com Vite
FROM node:20-alpine AS builder

# Define diretório de trabalho
WORKDIR /app

# Copia os arquivos do projeto
COPY . .

# Instala dependências e faz o build
RUN npm install && npm run build

# Etapa 2: Container de produção com NGINX
FROM nginx:alpine

# Copia os arquivos estáticos gerados para o diretório padrão do NGINX
COPY --from=builder /app/dist /usr/share/nginx/html

# Remove a configuração default (opcional)
RUN rm /etc/nginx/conf.d/default.conf

# Cria nova configuração mínima para servir o app
RUN echo 'server {\n\
  listen 80;\n\
  location / {\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    try_files $uri $uri/ /index.html;\n\
  }\n\
}' > /etc/nginx/conf.d/react.conf

# Expõe a porta padrão
EXPOSE 80

# Inicia o NGINX
CMD ["nginx", "-g", "daemon off;"]
