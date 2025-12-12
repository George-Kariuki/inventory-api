#!/bin/bash
# User Data Script: Runs automatically when EC2 instance starts
# This script installs Docker, runs your app, and sets up Prometheus

set -e  # Exit on any error

# Update system packages
sudo yum update -y

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create directory for the app
mkdir -p /home/ec2-user/inventory-api
cd /home/ec2-user/inventory-api

# Create docker-compose.yml for the app
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  db:
    image: postgres:16-alpine
    container_name: inventory_db
    environment:
      POSTGRES_USER: inventory_user
      POSTGRES_PASSWORD: inventory_password
      POSTGRES_DB: inventory_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U inventory_user"]
      interval: 10s
      timeout: 5s
      retries: 5

  app:
    # IMPORTANT: Replace YOUR_DOCKER_USERNAME with your actual Docker Hub username
    # Example: georgekariuki/inventory-api:latest
    image: YOUR_DOCKER_USERNAME/inventory-api:latest
    container_name: inventory_api
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://inventory_user:inventory_password@db:5432/inventory_db
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    restart: unless-stopped

volumes:
  postgres_data:
  prometheus_data:
EOF

# Create Prometheus configuration directory
mkdir -p prometheus

# Create Prometheus config file
cat > prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s  # How often to collect metrics
  evaluation_interval: 15s

scrape_configs:
  # Scrape Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Scrape the Inventory API
  - job_name: 'inventory-api'
    static_configs:
      - targets: ['app:8000']  # Your FastAPI app
    metrics_path: '/metrics'  # We'll add this endpoint later
EOF

# Note: The Docker image will be pulled from Docker Hub
# Make sure to replace YOUR_DOCKER_USERNAME in docker-compose.yml
# with your actual Docker Hub username

# Start services (will be done manually after pulling the image)
echo "Setup complete! Next steps:"
echo "1. Edit docker-compose.yml and replace YOUR_DOCKER_USERNAME"
echo "2. Run: docker-compose up -d"
echo "3. Access API at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8000"
echo "4. Access Prometheus at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9090"

