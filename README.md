# 🎮 Remote Smash Karts Bot

A deployable web application that runs a Smash Karts game bot on a server with remote VNC access. Play games automatically while consuming server resources, not your local machine!

## 🌟 Features

- **Remote Browser Control**: Full VNC access to interact with the game
- **Web Interface**: Start/stop bot with beautiful web controls
- **Server-Side Processing**: All resources consumed on the server
- **Real-time Monitoring**: See the bot playing in real-time
- **Easy Deployment**: Docker-based deployment for any server

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Your Browser  │───▶│   Flask Server   │───▶│  Chrome + Bot   │
│   (Web UI)      │    │  (Port 5000)     │    │  (VNC Display)  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │                        │
                                ▼                        ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │  noVNC Server    │◀───│  VNC Server     │
                       │  (Port 6080)     │    │  (Display :99)  │
                       └──────────────────┘    └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- At least 4GB RAM available
- 2 CPU cores recommended

### 1. Clone/Download Files

Create a new directory and add these files:

```
remote-bot/
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── supervisord.conf
├── app.py
├── index.html
├── deploy.sh
└── README.md
```

### 2. Deploy

```bash
# Make deploy script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

### 3. Access

- **Main Interface**: http://localhost:5000
- **Direct VNC**: http://localhost:6080

## 📋 How to Use

### Step 1: Access the Web Interface
Open http://localhost:5000 in your browser

### Step 2: Wait for VNC to Load
The remote browser will appear in the iframe

### Step 3: Navigate to Game
Click in the VNC window and go to https://smashkarts.io

### Step 4: Join a Game
- Login to your account
- Select game mode
- Join a game room
- Wait until you're actually playing (can see your kart)

### Step 5: Start the Bot
Click the "🚀 Start Bot" button in the web interface

### Step 6: Monitor
Watch the bot play automatically while you do other things!

## 🔧 Manual Setup (Without Docker)

If you prefer to set up manually:

### System Requirements
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3 python3-pip xvfb x11vnc novnc websockify fluxbox

# Install Chrome
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update && sudo apt install google-chrome-stable

# Install ChromeDriver
CHROMEDRIVER_VERSION=$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE)
wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip
unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/
chmod +x /usr/local/bin/chromedriver
```

### Python Dependencies
```bash
pip3 install flask selenium requests websockify
```

### Start Services
```bash
# Terminal 1: Start Xvfb
Xvfb :99 -screen 0 1920x1080x24 &

# Terminal 2: Start window manager
DISPLAY=:99 fluxbox &

# Terminal 3: Start VNC server
x11vnc -forever -shared -rfbport 5900 -display :99 &

# Terminal 4: Start noVNC
websockify --web=/usr/share/novnc 6080 localhost:5900 &

# Terminal 5: Start Flask app
DISPLAY=:99 python3 app.py
```

## 🌐 Cloud Deployment

### AWS EC2
```bash
# Launch t3.medium instance (2 vCPU, 4GB RAM)
# Open ports 5000 and 6080 in security group
# SSH into instance and run deployment script
```

### Google Cloud Platform
```bash
# Create e2-standard-2 instance
# Configure firewall rules for ports 5000, 6080
# Deploy using the provided scripts
```

### DigitalOcean
```bash
# Create 4GB droplet
# Add firewall rules
# Use one-click Docker app or manual setup
```

## 🔒 Security Notes

- **Firewall**: Only expose ports 5000 and 6080 to trusted IPs
- **Authentication**: Consider adding basic auth for production
- **HTTPS**: Use reverse proxy (nginx) with SSL for production
- **Resource Limits**: Docker compose includes memory/CPU limits

## ⚡ Performance Tips

- **Memory**: Allocate at least 4GB RAM
- **CPU**: 2+ cores recommended for smooth operation
- **Storage**: SSD recommended for better performance
- **Network**: Good internet connection for smooth VNC

## 🐛 Troubleshooting

### Bot Won't Start
- Check if you're actually in a game (not just on homepage)
- Ensure the browser is focused on the game
- Check Flask logs: `docker-compose logs`

### VNC Not Working
- Wait 30 seconds for services to fully start
- Try refreshing the page
- Check if ports 6080 is accessible

### Browser Crashes
- Increase shared memory: `shm_size: 4gb` in docker-compose.yml
- Add more RAM to container
- Check Chrome processes: `docker exec -it <container> ps aux`

### High Resource Usage
- Adjust Docker resource limits
- Use smaller screen resolution
- Reduce bot movement frequency

## 📊 Monitoring

### Resource Usage
```bash
# Check container stats
docker stats

# Check logs
docker-compose logs -f

# Access container
docker exec -it <container_name> bash
```

### Bot Status
The web interface shows real-time status:
- 🟢 Connected: Server is responsive
- 🟡 Running: Bot is actively playing
- 🔴 Error: Something went wrong

## 🛠️ Customization

### Bot Behavior
Edit `app.py` and modify the `bot_cycle()` method to change:
- Movement patterns
- Key sequences
- Timing intervals
- Actions performed

### UI Styling
Edit `index.html` to customize:
- Colors and themes
- Layout and components
- Additional controls
- Monitoring displays

### Game Configuration
- Change target URL in `setup_browser()`
- Modify browser options
- Add game-specific logic

## 📝 API Endpoints

- `GET /` - Main web interface
- `GET /vnc` - VNC viewer page
- `GET /status` - Bot status (JSON)
- `POST /start` - Start the bot
- `POST /stop` - Stop the bot
- `POST /restart` - Restart browser

## ⚖️ Legal Notice

This bot is for educational purposes only. Make sure to:
- Follow the game's Terms of Service
- Use responsibly and ethically
- Respect other players
- Not use for commercial purposes

## 🤝 Contributing

Feel free to improve this project by:
- Adding new features
- Improving bot AI
- Enhancing UI/UX
- Optimizing performance
- Adding more games support

## 📄 License

MIT License - feel free to modify and distribute!

---

**Happy Gaming! 🎮✨**
