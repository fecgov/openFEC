FROM python:3.10

#  Set a working directory inside the container
WORKDIR /app

RUN apt-get clean

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
-o Acquire::http::No-Cache=true \
-o Acquire::http::Pipeline-Depth=0 \
-o Acquire::BrokenProxy=true \
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


# Upgrade pip
RUN pip install --upgrade pip

# Install Python dependencies from requirements.txt
COPY requirements*.txt /app/
RUN pip install --no-cache-dir -r /app/requirements.txt -r /app/requirements-dev.txt
COPY . /app

# Expose ports for flask and locust
EXPOSE 5000
EXPOSE 8089

# Add Python path environment variable
ENV PYTHONPATH "${PYTHONPATH}:/app"

CMD ["flask", "run"]
