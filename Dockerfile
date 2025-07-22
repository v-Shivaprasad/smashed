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
    git \
    gnupg \
    unzip \
    xvfb \
    x11vnc \
    websockify \
    fluxbox \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC manually
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc \
 && git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify \
 && ln -s /opt/novnc/vnc_lite.html /opt/novnc/index.html

# Install Google Chrome using correct key method
RUN mkdir -p /usr/share/keyrings \
 && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
 && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update \
 && apt-get install -y google-chrome-stable \
 && rm -rf /var/lib/apt/lists/*

# ChromeDriver version (can be overridden with build-arg)
ARG CHROMEDRIVER_VERSION=119.0.6045.105

# Install ChromeDriver
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

# Supervisor config
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports for Flask and noVNC
EXPOSE 5000 6080

# Set environment variables
ENV DISPLAY=:99
ENV PYTHONUNBUFFERED=1

# Start supervisor (manages all services)
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
