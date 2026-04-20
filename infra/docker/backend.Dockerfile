# checkov:skip=CKV_DOCKER_2,CKV_DOCKER_3:

# Use the official Python image
FROM python:3.12-slim

# Set working directory
WORKDIR /app/backend

# Copy dependency files
COPY requirements.txt .

# Copy the rest of the backend code
COPY app/backend/ .

# Upgrade pip and install dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Run as non-root user
RUN useradd --no-create-home appuser
USER appuser

# Expose the port the app will run on
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import socket; s = socket.socket(); s.connect(('localhost', 8000)); s.close()" || exit 1

# Default command to run the backend (Gunicorn)
CMD ["gunicorn", "boardgames.wsgi:application", "--bind", "0.0.0.0:8000"]
