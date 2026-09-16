FROM node:20-alpine AS build

WORKDIR /app

RUN apk update && \
    apk upgrade --no-cache

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build


FROM node:20-alpine AS production

WORKDIR /app

RUN apk update && \
    apk upgrade --no-cache

COPY package*.json ./

RUN npm ci --omit=dev

COPY --from=build /app/dist ./dist

EXPOSE 8080

CMD ["node", "dist/server.js"]
