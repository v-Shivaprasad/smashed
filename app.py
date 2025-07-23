from flask import Flask, render_template, jsonify, request
import os
import sys
import threading
import time
import signal
import logging
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

class RemoteSmashKartsBot:
    def __init__(self):
        self.driver = None
        self.bot_running = False
        self.bot_thread = None

    def setup_browser(self):
        """Setup Chrome browser for VNC display"""
        chrome_options = Options()

        # VNC display configuration
        chrome_options.add_argument("--display=:99")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--remote-debugging-port=9222")

        # Anti-detection measures
        chrome_options.add_argument("--disable-blink-features=AutomationControlled")
        chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
        chrome_options.add_experimental_option('useAutomationExtension', False)

        # Performance options
        chrome_options.add_argument("--disable-logging")
        chrome_options.add_argument("--disable-extensions")
        chrome_options.add_argument("--disable-web-security")

        try:
            self.driver = webdriver.Chrome(options=chrome_options)

            # Hide automation indicators
            self.driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")

            # Navigate to Smash Karts
            self.driver.get("https://smashkarts.io/")
            self.driver.maximize_window()

            logger.info("✅ Browser setup complete")
            return True

        except Exception as e:
            logger.error(f"❌ Browser setup failed: {e}")
            return False

    def bot_cycle(self):
        """Main bot movement cycle"""
        logger.info("🤖 Bot started! Running movement pattern...")

        if not self.driver:
            logger.error("❌ No browser instance available")
            return

        try:
            body = self.driver.find_element(By.TAG_NAME, "body")
            actions = ActionChains(self.driver)

            cycle_count = 0
            while self.bot_running:
                try:
                    cycle_count += 1
                    logger.info(f"🔄 Cycle {cycle_count}")

                    movements = [
                        (Keys.ARROW_UP, 5, "Up"),
                        ((Keys.ARROW_UP, Keys.ARROW_LEFT), 5, "Up+Left"),
                        ((Keys.ARROW_UP, Keys.ARROW_RIGHT), 5, "Up+Right"),
                        (Keys.SPACE, 0.5, "Space"),
                        (Keys.ARROW_DOWN, 5, "Down"),
                        ((Keys.ARROW_DOWN, Keys.ARROW_LEFT), 5, "Down+Left"),
                        ((Keys.ARROW_DOWN, Keys.ARROW_RIGHT), 5, "Down+Right"),
                        (Keys.SPACE, 0.5, "Space"),
                    ]

                    for keys, duration, description in movements:
                        if not self.bot_running:
                            break

                        # Press keys
                        if isinstance(keys, tuple):
                            for key in keys:
                                actions.key_down(key)
                        else:
                            actions.key_down(keys)
                        actions.perform()

                        if not self._sleep_check(duration, description):
                            break

                        # Release keys
                        if isinstance(keys, tuple):
                            for key in keys:
                                actions.key_up(key)
                        else:
                            actions.key_up(keys)
                        actions.perform()

                except Exception as e:
                    logger.error(f"❌ Error in cycle: {e}")
                    break

        except Exception as e:
            logger.error(f"❌ Bot cycle error: {e}")
        finally:
            self._release_all_keys()
            logger.info("🛑 Bot stopped")

    def _sleep_check(self, duration, action):
        end_time = time.time() + duration
        while time.time() < end_time:
            if not self.bot_running:
                return False
            time.sleep(0.1)
        return True

    def _release_all_keys(self):
        if not self.driver:
            return
        try:
            actions = ActionChains(self.driver)
            for key in [Keys.ARROW_UP, Keys.ARROW_DOWN, Keys.ARROW_LEFT, Keys.ARROW_RIGHT, Keys.SPACE]:
                actions.key_up(key)
            actions.perform()
        except Exception as e:
            logger.error(f"Error releasing keys: {e}")

    def start_bot(self):
        if self.bot_running:
            return False, "Bot is already running"

        if not self.driver:
            if not self.setup_browser():
                return False, "Failed to setup browser"

        try:
            self.bot_running = True
            self.bot_thread = threading.Thread(target=self.bot_cycle, daemon=True)
            self.bot_thread.start()
            return True, "Bot started successfully"
        except Exception as e:
            self.bot_running = False
            return False, f"Failed to start bot: {e}"

    def stop_bot(self):
        if not self.bot_running:
            return False, "Bot is not running"

        try:
            self.bot_running = False
            if self.bot_thread:
                self.bot_thread.join(timeout=5)
            return True, "Bot stopped successfully"
        except Exception as e:
            return False, f"Failed to stop bot: {e}"

    def get_status(self):
        return "running" if self.bot_running else "idle"

    def cleanup(self):
        self.stop_bot()
        if self.driver:
            try:
                self.driver.quit()
            except:
                pass

# Global bot instance
bot = RemoteSmashKartsBot()

# Routes
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/vnc')
def vnc():
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>VNC Viewer</title>
        <style>
            body { margin: 0; padding: 0; }
            iframe { width: 100%; height: 100vh; border: none; }
        </style>
    </head>
    <body>
        <iframe src="http://localhost:6080/vnc.html?autoconnect=true&resize=scale"></iframe>
    </body>
    </html>
    """

@app.route('/status')
def status():
    return jsonify({
        'status': bot.get_status(),
        'browser_active': bot.driver is not None
    })

@app.route('/start', methods=['POST'])
def start():
    success, message = bot.start_bot()
    return jsonify({'success': success, 'message': message})

@app.route('/stop', methods=['POST'])
def stop():
    success, message = bot.stop_bot()
    return jsonify({'success': success, 'message': message})

@app.route('/restart', methods=['POST'])
def restart():
    try:
        if bot.driver:
            bot.driver.quit()
            bot.driver = None
        success = bot.setup_browser()
        return jsonify({
            'success': success,
            'message': 'Browser restarted' if success else 'Failed to restart browser'
        })
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

# Cleanup on exit
def signal_handler(sig, frame):
    logger.info("Shutting down...")
    bot.cleanup()
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

if __name__ == '__main__':
    try:
        logger.info("Starting Remote Smash Karts Bot Server...")
        app.run(host='0.0.0.0', port=5000, debug=False)
    except Exception as e:
        logger.error(f"Failed to start server: {e}")
    finally:
        bot.cleanup()
