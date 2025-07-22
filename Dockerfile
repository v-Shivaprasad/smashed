# Use Ubuntu base image with Python
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    wget \
    curl \
    gnupg \
    unzip \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    fluxbox \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome (use modern keyring method)
RUN wget -q -O /usr/share/keyrings/google-chrome.gpg https://dl.google.com/linux/linux_signing_key.pub \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
      > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Build arg for ChromeDriver version (default set)
ARG CHROMEDRIVER_VERSION=119.0.6045.105

# Install ChromeDriver for specified version
RUN wget -O /tmp/chromedriver.zip "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${CHROMEDRIVER_VERSION}/linux64/chromedriver-linux64.zip" \
    && unzip /tmp/chromedriver.zip -d /tmp/ \
    && mv /tmp/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver \
    && chmod +x /usr/local/bin/chromedriver \
    && rm -rf /tmp/chromedriver.zip /tmp/chromedriver-linux64

# Install Python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip3 install --no-cache-dir -r /app/requirements.txt

# Set up VNC
RUN mkdir -p /root/.vnc \
    && x11vnc -storepasswd "" /root/.vnc/passwd

# Copy application files
COPY . /app
WORKDIR /app

# Create supervisor config
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports for your web and VNC services
EXPOSE 5000 6080

# Set environment variables for display and Python
ENV DISPLAY=:99
ENV PYTHONUNBUFFERED=1

# Start supervisor (manages all services)
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
