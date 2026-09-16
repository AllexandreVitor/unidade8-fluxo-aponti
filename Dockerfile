# =========================
# Etapa 1 - Build
# =========================
FROM node:20-alpine AS build
RUN apk update && \
    apk upgrade --no-cache

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY tsconfig.json ./
COPY src ./src

RUN npm run build


# =========================
# Etapa 2 - Produção
# =========================
FROM node:20-alpine AS production
RUN apk update && \
    apk upgrade --no-cache 

WORKDIR /app

ENV NODE_ENV=production

COPY package*.json ./

RUN npm ci --omit=dev

COPY --from=build /app/dist ./dist

EXPOSE 3000

USER node

CMD ["node", "dist/server.js"]