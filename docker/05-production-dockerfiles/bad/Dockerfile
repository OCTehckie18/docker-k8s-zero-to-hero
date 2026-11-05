# ⚠️ ANTI-PATTERN DOCKERFILE: count the problems (Lab D05 lists them).
FROM python:latest
COPY . /app
WORKDIR /app
RUN apt-get update
RUN apt-get install -y curl vim
ENV API_KEY=sk-live-1234567890
CMD ./start.sh
