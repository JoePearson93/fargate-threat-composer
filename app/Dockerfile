# Stage 1 - Builder
FROM node:20-alpine.12-alpine3.19@sha256:fb4cd12c85ee03686f6af5362a0b0d56d50c58a04632e6c0fb8363f609372293 AS builder

WORKDIR /app

COPY package*.json yarn.lock ./

RUN yarn install --frozen-lockfile

COPY . .

RUN DISABLE_ESLINT_PLUGIN=true yarn build

# Stage 2 - Runtime
FROM nginxinc/nginx-unprivileged@sha256:65e3e85dbaed8ba248841d9d58a899b6197106c23cb0ff1a132b7bfe0547e4c0

WORKDIR /usr/share/nginx/html

COPY --from=builder /app/build .

COPY nginx.conf /etc/nginx/conf.d/default.conf

USER nginx

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s \
    CMD wget --spider http://localhost:8080 || exit 1

CMD ["nginx", "-g", "daemon off;"]