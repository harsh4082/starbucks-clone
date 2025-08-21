# Stage 1: Build React App
FROM node:18 AS build

WORKDIR /app

# Copy only package.json & package-lock.json to cache dependencies
COPY package*.json ./
RUN npm ci --legacy-peer-deps  # faster, clean install

# Copy rest of the code
COPY . .

# Build React app
RUN npm run build --max_old_space_size=4096  # prevent memory issues

# Stage 2: Serve with Nginx
FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
