# Stage 1 - Builder
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json yarn.lock ./

RUN yarn install --frozen-lockfile

COPY . .

RUN DISABLE_ESLINT_PLUGIN=true yarn build

# Stage 2 - Runtime
FROM nginx:alpine@sha256:feb6f75a08aa55b44576f98c15b8859819ecf54f3e4d2157f42c2d01cb58a3d2

WORKDIR /usr/share/nginx/html

COPY --from=builder /app/build .

COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN addgroup -S appgroup && adduser -S appuser -G appgroup \
    && chown -R appuser:appgroup /usr/share/nginx/html \
    && chown -R appuser:appgroup /var/cache/nginx \
    && chown -R appuser:appgroup /var/log/nginx \
    && touch /var/run/nginx.pid \
    && chown appuser:appgroup /var/run/nginx.pid

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s \
    CMD wget --spider http://localhost:8080 || exit 1

CMD ["nginx", "-g", "daemon off;"]