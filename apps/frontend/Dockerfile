# The frontend tier: NGINX as a reverse proxy in front of the API.
# nginx-unprivileged runs as a non-root user and listens on 8080.
FROM nginxinc/nginx-unprivileged:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
