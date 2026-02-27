# 🎤 Interview Q&A — Lab 18: Systemd Unit Files for Custom Services

## 1) What are the main sections of a systemd service unit file?
A service unit typically contains:
- **[Unit]** → description + dependencies + ordering
- **[Service]** → how the service runs (ExecStart, restart behavior, user, security)
- **[Install]** → where it hooks into boot targets (WantedBy)

---

## 2) Where are unit files commonly stored on RHEL/CentOS?
Common unit file locations:
- `/usr/lib/systemd/system/` → vendor packages (RPM-managed)
- `/etc/systemd/system/` → admin overrides + custom units (preferred for custom)
- `/run/systemd/system/` → runtime-generated units

---

## 3) What does `systemctl daemon-reload` do?
It reloads systemd’s unit configuration so new or modified unit files are recognized.  
You typically run it after editing or copying unit files into `/etc/systemd/system/`.

---

## 4) What’s the difference between `enable` and `start`?
- `systemctl start <unit>` → starts immediately (current runtime session)
- `systemctl enable <unit>` → configures it to start automatically at boot (creates symlinks)

---

## 5) What is `WantedBy=multi-user.target` used for?
It ties the service to a boot target (roughly “non-graphical multi-user mode”).  
When the system reaches `multi-user.target`, services linked to it will start.

---

## 6) Why did we run the web server service as `nobody:nobody`?
To reduce risk:
- running network services as root increases impact if compromised
- using a low-privileged user follows the principle of least privilege

---

## 7) What does `Restart=on-failure` mean?
systemd will restart the service if it exits with an error or is killed unexpectedly.  
It will **not** restart if the service exits normally with success.

---

## 8) Why did the service restart after `kill -9`?
`kill -9` terminates the process immediately. systemd detects the main process died and, because the unit had restart behavior configured, it restarted the service with a new PID.

---

## 9) What is the purpose of `ExecReload=/bin/kill -HUP $MAINPID`?
It defines how to reload the service without a full restart (where supported).  
For many daemons, `HUP` triggers a config reload. (For scripts, it may not always apply.)

---

## 10) What is a `Type=oneshot` service and when do you use it?
`Type=oneshot` runs a task and exits.  
It’s ideal for:
- cleanup jobs
- migrations
- maintenance tasks
- one-time provisioning tasks

---

## 11) How does a systemd timer compare to cron?
Timers are systemd-native scheduled tasks:
- integrate with unit dependency handling
- provide consistent journald logging
- have `Persistent=true` behavior (catch up after downtime)
Cron is simpler but less integrated with systemd units.

---

## 12) What does `Persistent=true` do in a timer unit?
If the machine was off during a scheduled time, systemd will run the missed job soon after the system boots (catch-up execution).

---

## 13) Why do we use security directives like `NoNewPrivileges=true`?
It prevents the service and its children from gaining additional privileges (like via setuid binaries), reducing privilege escalation opportunities.

---

## 14) What does `ProtectSystem=strict` do?
It makes most of the filesystem read-only for the service.  
This reduces the blast radius if the service is compromised.

---

## 15) How do you troubleshoot a custom service that fails to start?
Steps:
1) Check status:
```bash
systemctl status <unit> -l
````

2. Check logs:

```bash
journalctl -u <unit> --since "1 hour ago"
```

3. Validate unit file syntax:

```bash
systemd-analyze verify /etc/systemd/system/<unit>
```

4. Confirm permissions and script paths are correct:

```bash
ls -la /path/to/script
```

---
