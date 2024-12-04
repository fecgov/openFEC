# Force x86_64 base image for compatibility with Flyway
FROM python:3.10-slim

#  Set a working directory inside the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    tar \
    unzip \
    gcc \
    make \
    libpq-dev \
    git \
    postgresql-server-dev-all \
    && rm -rf /var/lib/apt/lists/*  # Clean up to reduce the image size

# Download Flyway CLI
RUN wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/11.0.0/flyway-commandline-11.0.0-linux-x64.tar.gz && \
    tar -xvf flyway-commandline-11.0.0-linux-x64.tar.gz && \
    mv flyway-11.0.0 /flyway && \
    ln -s /flyway/flyway /usr/local/bin/flyway && \
    rm flyway-commandline-11.0.0-linux-x64.tar.gz


# Copy application files
COPY . /app


# Install Python dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -r requirements-dev.txt

# Expose ports for flask and locust
EXPOSE 5000
EXPOSE 8089

# Add Python path environment variable
ENV PYTHONPATH "${PYTHONPATH}:/app"

CMD ["flask", "run"]
