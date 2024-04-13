# Use Ubuntu as the base image
FROM ubuntu:latest

# for tz question
# Set the timezone environment variable to UTC
# Create a symbolic link for the timezone
ENV TZ="UTC"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime

# set local bin in ENV
ENV PATH="/root/.local/bin:$PATH"

# Install necessary dependencies
RUN apt-get update --fix-missing && \ 
    apt-get install -y software-properties-common \
    ca-certificates \
    curl \
    wget \
    git \
    vim \
    nano \
    unzip \
    zip \
    build-essential \
    netcat \
    lsof

# install Python3.11
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update --fix-missing && \
    apt-get install -y python3.11 \
    python3-pip

# install node LTS
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install nodejs -y

# install poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# install docker client
RUN apt-get install docker.io -y

# Set the working directory in the container
WORKDIR /app

# Clone the OpenDevin repository in the /app directory
RUN git clone --branch docker_fixes_04122024 https://github.com/risingsunomi/OpenDevin.git
WORKDIR /app/OpenDevin

# Build the frontend and backend
RUN make build-nodocker

# Setup config
RUN make setup-config

# Expose the port on which the application will run
EXPOSE 3001

# Start the docker, backend and frontend
CMD make run