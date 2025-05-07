FROM node:20-alpine

RUN apk add --no-cache nginx

WORKDIR /app
COPY . .
RUN npm install && npm run build

RUN mkdir -p /var/www/html && cp -r dist/* /var/www/html/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
