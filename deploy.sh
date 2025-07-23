#!/bin/bash

# Remote Smash Karts Bot Deployment Script

# Output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_status()    { echo -e "${GREEN}✅ $1${NC}"; }
print_warning()   { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error()     { echo -e "${RED}❌ $1${NC}"; }
print_info()      { echo -e "${CYAN}➡️  $1${NC}"; }

echo "${CYAN}🎮 Deploying Remote Smash Karts Bot...${NC}"

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker."
    exit 1
fi

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose."
    exit 1
fi

# Create logs directory
mkdir -p logs

# Stop and remove old containers
print_status "Stopping existing containers..."
docker-compose down --remove-orphans

# Build and start containers
print_status "Building and starting containers..."
docker-compose up --build -d

# Wait for services to initialize
print_info "Waiting for services to start..."
sleep 10

# Check if the container is up
if docker-compose ps | grep -q "Up"; then
    print_status "Deployment successful!"

    echo -e "\n🌐 ${CYAN}Access your bot dashboard:${NC}"
    echo "   📄 Flask Control UI : http://localhost:5000"
    echo "   🖥️  VNC Interface    : http://localhost:6080/vnc.html"

    echo -e "\n📋 ${CYAN}Next Steps:${NC}"
    echo "1. Open http://localhost:5000"
    echo "2. Click 'Open VNC' to view the remote browser"
    echo "3. Join a Smash Karts game"
    echo "4. Click 'Start Bot' to begin automation"
    echo -e "\n🎯 ${GREEN}Bot is ready to race!${NC}"
else
    print_error "Deployment failed! Logs below:"
    docker-compose logs
    exit 1
fi
