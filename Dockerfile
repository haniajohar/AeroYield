FROM python:3.12-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends gcc && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /install /usr/local
COPY . .
RUN mkdir -p audio_cache
ENV HOST=0.0.0.0
ENV PORT=8000
EXPOSE 8000
CMD uvicorn app.main:app --host $HOST --port $PORT --workers 2
