FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    cron \
    postgresql-client \
    git \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY ingestion/ ./ingestion/
COPY transforms/ ./transforms/
COPY run_pipeline.sh .
COPY entrypoint.sh .

# Make scripts executable
RUN chmod +x run_pipeline.sh entrypoint.sh

# Set up dbt profile directory
RUN mkdir -p /root/.dbt
COPY docker/profiles.yml /root/.dbt/profiles.yml

# Add cron job — runs pipeline daily at 6am
RUN echo "0 6 * * * /app/run_pipeline.sh >> /var/log/pipeline.log 2>&1" > /etc/cron.d/pipeline \
    && chmod 0644 /etc/cron.d/pipeline \
    && crontab /etc/cron.d/pipeline

# Create log file
RUN touch /var/log/pipeline.log

ENTRYPOINT ["/app/entrypoint.sh"]