#!/bin/bash

# Remote Smash Karts Bot Deployment Script
echo "🎮 Deploying Remote Smash Karts Bot..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create logs directory
mkdir -p logs

# Stop existing containers
print_status "Stopping existing containers..."
docker-compose down --remove-orphans

# Build and start the containers
print_status "Building and starting containers..."
docker-compose up --build -d

# Wait for services to start
print_status "Waiting for services to start..."
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    print_status "Deployment successful!"
    echo ""
    echo "🌐 Access your bot at:"
    echo "   Main Interface: http://localhost:5000"
    echo "   Direct VNC:     http://localhost:6080"
    echo ""
    echo "📋 Next steps:"
    echo "1. Open http://localhost:5000 in your browser"
    echo "2. Wait for the VNC interface to load"
    echo "3. Navigate to smashkarts.io in the remote browser"
    echo "4. Join a game manually"
    echo "5. Click 'Start Bot' to begin automation"
    echo ""
    print_status "Bot is ready to use!"
else
    print_error "Deployment failed! Check the logs:"
    docker-compose logs
    exit 1
fi
