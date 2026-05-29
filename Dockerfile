# CPU-only Dockerfile with Whisper transcription
FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV GPU_ENABLED=false
ENV WHISPER_MODEL=tiny

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    fonts-dejavu-core \
    fonts-liberation \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies (CPU-only PyTorch for smaller image)
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir torch torchaudio --index-url https://download.pytorch.org/whl/cpu && \
    pip install --no-cache-dir yt-dlp flask gunicorn requests openai-whisper

# Pre-download Whisper tiny model
RUN python -c "import whisper; whisper.load_model('tiny')"

WORKDIR /app

# Copy all application files including assets
COPY . .

EXPOSE 8080

CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:${PORT:-8080} --timeout 600 --workers 1 --threads 2 app:app"]
