FROM python:3.11-slim

WORKDIR /app

COPY . .

WORKDIR /app/web

EXPOSE 10000

CMD ["python3", "-m", "http.server", "10000"]
