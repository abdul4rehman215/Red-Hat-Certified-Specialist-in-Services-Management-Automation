#!/bin/bash
# Lab 18: Systemd Unit Files for Custom Services
# Commands Executed During Lab (Sequential, paste-ready)

# ---------------------------------------------
# Task 1.1: Review systemd unit file structure
# ---------------------------------------------
sudo systemctl cat sshd.service
systemctl show --property=UnitPath

# ---------------------------------------------
# Task 1.1: Create working directory structure
# ---------------------------------------------
mkdir ~/systemd-lab
cd ~/systemd-lab
mkdir scripts
mkdir unit-files
ls -la

# ---------------------------------------------
# Task 1.2: Create + test Python web server
# ---------------------------------------------
nano scripts/simple-webserver.py
chmod +x scripts/simple-webserver.py

python3 scripts/simple-webserver.py &
WEBSERVER_PID=$!
echo "Test webserver PID: $WEBSERVER_PID"

curl http://localhost:8080/
curl http://localhost:8080/status

kill $WEBSERVER_PID

# ---------------------------------------------
# Task 1.2: Create systemd unit for webserver
# ---------------------------------------------
nano unit-files/custom-webserver.service

# ---------------------------------------------
# Task 1.3: Create log monitor service + unit
# ---------------------------------------------
nano scripts/log-monitor.sh
chmod +x scripts/log-monitor.sh

nano unit-files/log-monitor.service

# ---------------------------------------------
# Task 1.4: Create cleanup service + timer
# ---------------------------------------------
nano scripts/system-cleanup.sh
chmod +x scripts/system-cleanup.sh

nano unit-files/system-cleanup.service
nano unit-files/system-cleanup.timer

# ---------------------------------------------
# Task 2.1: Install unit files into systemd path
# ---------------------------------------------
sudo cp unit-files/*.service /etc/systemd/system/
sudo cp unit-files/*.timer /etc/systemd/system/

sudo chmod 644 /etc/systemd/system/custom-webserver.service
sudo chmod 644 /etc/systemd/system/log-monitor.service
sudo chmod 644 /etc/systemd/system/system-cleanup.service
sudo chmod 644 /etc/systemd/system/system-cleanup.timer

ls -la /etc/systemd/system/custom-* /etc/systemd/system/log-monitor.* /etc/systemd/system/systemcleanup.*
ls -la /etc/systemd/system/custom-* /etc/systemd/system/log-monitor.* /etc/systemd/system/system-cleanup.*

sudo systemctl daemon-reload
systemctl list-unit-files | grep -E "(custom-webserver|log-monitor|system-cleanup)"

# ---------------------------------------------
# Task 2.1: Enable + start custom-webserver
# ---------------------------------------------
sudo systemctl enable custom-webserver.service
sudo systemctl start custom-webserver.service
systemctl status custom-webserver.service

systemctl is-active custom-webserver.service
systemctl is-enabled custom-webserver.service

# ---------------------------------------------
# Task 2.2: Enable + start log-monitor service
# ---------------------------------------------
sudo systemctl enable log-monitor.service
sudo systemctl start log-monitor.service
systemctl status log-monitor.service

sudo journalctl -u log-monitor.service -f --lines=10

sudo systemctl stop log-monitor.service
systemctl status log-monitor.service
sudo systemctl restart log-monitor.service
sudo systemctl reload-or-restart log-monitor.service

# ---------------------------------------------
# Task 2.3: Enable + start timer-based service
# ---------------------------------------------
sudo systemctl enable system-cleanup.timer
sudo systemctl start system-cleanup.timer
systemctl status system-cleanup.timer

systemctl list-timers --all

sudo systemctl start system-cleanup.service
systemctl status system-cleanup.service
sudo journalctl -u system-cleanup.service --lines=20

# ---------------------------------------------
# Task 3.1: Test web endpoints + port listening
# ---------------------------------------------
curl -s http://localhost:8080/ | head -5
curl -s http://localhost:8080/status

wget -qO- http://localhost:8080/status

sudo netstat -tlnp | grep :8080
sudo ss -tlnp | grep :8080

# ---------------------------------------------
# Task 3.1: Resilience test (kill PID -> restart)
# ---------------------------------------------
WEB_PID=$(systemctl show --property MainPID custom-webserver.service | cut -d= -f2)
echo "Web server PID: $WEB_PID"
sudo kill -9 $WEB_PID
sleep 10
systemctl status custom-webserver.service
curl -s http://localhost:8080/status

# ---------------------------------------------
# Task 3.2: Log monitor functionality validation
# ---------------------------------------------
sudo tail -f /var/log/custom-monitor.log &
TAIL_PID=$!
echo "tail PID: $TAIL_PID"

mkdir -p /tmp/monitor
touch /tmp/monitor/test1.txt /tmp/monitor/test2.txt

sleep 35

kill $TAIL_PID

sudo tail -10 /var/log/custom-monitor.log

sudo systemctl restart log-monitor.service
systemctl status log-monitor.service
sleep 35
sudo tail -5 /var/log/custom-monitor.log

# ---------------------------------------------
# Task 3.3: Timer validation and logs
# ---------------------------------------------
systemctl list-timers system-cleanup.timer
systemctl show system-cleanup.timer
sudo journalctl -u system-cleanup.service --since "10 minutes ago"

sudo systemctl start system-cleanup.service
systemctl status system-cleanup.service
sudo tail -10 /var/log/system-cleanup.log

# ---------------------------------------------
# Task 3.4: Boot enablement verification
# ---------------------------------------------
systemctl is-enabled custom-webserver.service
systemctl is-enabled log-monitor.service
systemctl is-enabled system-cleanup.timer
systemctl list-unit-files --state=enabled | grep -E "(custom|log-monitor|system-cleanup)"

sudo systemctl stop custom-webserver.service
sudo systemctl stop log-monitor.service
sudo systemctl stop system-cleanup.timer

systemctl is-active custom-webserver.service
systemctl is-active log-monitor.service
systemctl is-active system-cleanup.timer

sudo systemctl start multi-user.target
sudo systemctl start timers.target

sleep 10

systemctl is-active custom-webserver.service
systemctl is-active log-monitor.service
systemctl is-active system-cleanup.timer

# ---------------------------------------------
# Task 3.5: Dependencies + performance checks
# ---------------------------------------------
systemctl list-dependencies custom-webserver.service
systemctl list-dependencies log-monitor.service
systemctl list-dependencies system-cleanup.timer
systemctl list-dependencies --reverse custom-webserver.service

systemctl show custom-webserver.service --property=MainPID
systemctl show log-monitor.service --property=MainPID

WEB_PID=$(systemctl show --property MainPID custom-webserver.service | cut -d= -f2)
LOG_PID=$(systemctl show --property MainPID log-monitor.service | cut -d= -f2)

if [ "$WEB_PID" != "0" ]; then
  echo "Web server resource usage:"
  ps -p $WEB_PID -o pid,ppid,cmd,%mem,%cpu
fi

if [ "$LOG_PID" != "0" ]; then
  echo "Log monitor resource usage:"
  ps -p $LOG_PID -o pid,ppid,cmd,%mem,%cpu
fi

# ---------------------------------------------
# Task 3.6: Comprehensive test script
# ---------------------------------------------
nano scripts/test-services.sh
chmod +x scripts/test-services.sh
./scripts/test-services.sh

echo "Testing service failure and recovery..."
WEB_PID=$(systemctl show --property MainPID custom-webserver.service | cut -d= -f2)
if [ "$WEB_PID" != "0" ]; then
  echo "Killing web server process $WEB_PID"
  sudo kill -9 $WEB_PID

  echo "Waiting for restart..."
  sleep 10

  if systemctl is-active --quiet custom-webserver.service; then
    echo "✓ Web server restarted successfully"
  else
    echo "✗ Web server failed to restart"
  fi
fi

echo "Testing configuration reload..."
sudo systemctl reload-or-restart custom-webserver.service
systemctl status custom-webserver.service --no-pager -l

# ---------------------------------------------
# Cleanup (optional)
# ---------------------------------------------
sudo systemctl stop custom-webserver.service
sudo systemctl stop log-monitor.service
sudo systemctl stop system-cleanup.timer

sudo systemctl disable custom-webserver.service
sudo systemctl disable log-monitor.service
sudo systemctl disable system-cleanup.timer

sudo rm /etc/systemd/system/custom-webserver.service
sudo rm /etc/systemd/system/log-monitor.service
sudo rm /etc/systemd/system/system-cleanup.service
sudo rm /etc/systemd/system/system-cleanup.timer

sudo systemctl daemon-reload

sudo rm -f /var/log/custom-monitor.log
sudo rm -f /var/log/system-cleanup.log
