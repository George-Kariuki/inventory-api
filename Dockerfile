FROM python:3.12-slim

WORKDIR /app

# Install system dependencies required for psycopg2-binary
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    postgresql-client \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

RUN pip install poetry==1.8.3

COPY pyproject.toml poetry.lock* ./

RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi --no-root --no-dev

COPY . .

RUN poetry install --no-interaction --no-ansi --no-dev

EXPOSE 8000

# Use PORT environment variable (Heroku provides this dynamically)
CMD poetry run uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}

