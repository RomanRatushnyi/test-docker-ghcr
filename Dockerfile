FROM node:20 AS build

WORKDIR /app
COPY . .

RUN npm install && npm run build

FROM node:20-alpine AS production

RUN npm install -g serve

WORKDIR /app

COPY --from=build /app/dist .
COPY --from=build /app/package.json ./

EXPOSE 80
CMD ["serve", "-s", ".", "-l", "80"]

