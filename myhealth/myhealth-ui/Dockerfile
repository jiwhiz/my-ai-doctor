# Stage 1: Build the Elm Land project
FROM node:latest AS build

WORKDIR /app
COPY package.json ./
COPY src ./src
COPY static ./static
COPY elm.json ./
COPY elm-land.json ./

ENV AUTH_SERVER_URL="http://auth.myhealth"
ENV API_BASE_URL="http://api.myhealth/api/v1"

RUN npm install
RUN npm run build

# Stage 2: Set up Nginx to serve the Elm Land app
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/myhealth.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
