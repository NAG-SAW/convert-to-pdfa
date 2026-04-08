FROM python:3.14-slim

# Install security updates and required packages
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    bash \
    ghostscript \
    icc-profiles-free \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd --create-home --shell /bin/bash appuser

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .
COPY convert_to_pdfa.sh .

# Create directories and set permissions
RUN mkdir -p processed temp_files \
    && chown -R appuser:appuser /app \
    && chmod +x convert_to_pdfa.sh

USER appuser
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

