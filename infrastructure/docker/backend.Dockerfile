# Use the official Python image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy dependency files
COPY requirements.txt .

# Copy the rest of the backend code
COPY app/backend/ .

# Upgrade pip and install dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Expose the port the app will run on
EXPOSE 8000

# Default command to run the backend (Gunicorn)
CMD ["gunicorn", "myproject.wsgi:application", "--bind", "0.0.0.0:8000"]
