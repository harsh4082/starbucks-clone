# Stage 1: Build React App
FROM node:18 AS build

WORKDIR /app

# Copy package files first for caching
COPY package*.json ./
RUN npm install

# Copy rest of the source code
COPY . .

# Build production bundle
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
