# 🎤 Lab 08 — Interview Q&A (Automating DHCP Server Configuration with Ansible)

## 1) What is DHCP and why is it important in networks?
**Answer:** DHCP (Dynamic Host Configuration Protocol) automatically assigns IP addresses and network settings (gateway, DNS, subnet mask) to clients. It reduces manual configuration and prevents IP conflicts in enterprise networks.

---

## 2) Why automate DHCP server deployment with Ansible?
**Answer:** Automation ensures **consistent configuration**, faster deployment, reduced human error, easy scaling, and repeatable changes using Infrastructure as Code (IaC). Playbooks also act as living documentation.

---

## 3) Which service provides DHCP on RHEL/CentOS in this lab?
**Answer:** The ISC DHCP server daemon, managed as the `dhcpd` systemd service (package: `dhcp-server`).

---

## 4) What are the DHCP ports used by server and client?
**Answer:** DHCP uses:
- **UDP 67** (server side)
- **UDP 68** (client side)

---

## 5) What is a DHCP scope and what does it contain?
**Answer:** A DHCP scope defines a subnet and the range of IP addresses that can be leased, plus options like routers (default gateway), DNS servers, lease time, and domain name.

---

## 6) Why did you validate the DHCP config using `dhcpd -t -cf`?
**Answer:** It checks configuration syntax before restarting or applying changes. This prevents downtime caused by invalid DHCP configuration files.

---

## 7) What is the role of Jinja2 templates in this lab?
**Answer:** Jinja2 templates generate `dhcpd.conf` dynamically from variables and lists (like multiple scopes and reservations). This allows reusable, parameterized configuration.

---

## 8) What does it mean when the client output shows `DHCPOFFER` and `DHCPACK`?
**Answer:** It confirms the DHCP handshake worked:
- **DHCPOFFER**: server offers an IP
- **DHCPACK**: server confirms and assigns the lease
The client becomes “bound” to the assigned IP.

---

## 9) How did you confirm that a client successfully received a DHCP lease?
**Answer:** By running `dhclient -v` and verifying:
- offer/ack messages from the server
- assigned IP visible in `ip addr show`
- server lease file includes the lease entry

---

## 10) What files store DHCP lease information on the server?
**Answer:** The lease database is stored at:
- `/var/lib/dhcpd/dhcpd.leases`

---

## 11) Why did you create backup directories for DHCP configuration?
**Answer:** Backups allow quick rollback if new configurations break service. It’s a best practice when automating changes to critical network services.

---

## 12) What is a static reservation in DHCP?
**Answer:** A static reservation maps a specific MAC address to a fixed IP address. This is commonly used for devices like servers, printers, network appliances, or monitoring systems.

---

## 13) How did you monitor DHCP activity in this lab?
**Answer:** Monitoring was done by:
- checking systemd status of `dhcpd`
- reading journald logs (`journalctl -u dhcpd`)
- viewing active lease entries from `/var/lib/dhcpd/dhcpd.leases`
- confirming firewall state includes `dhcp`

---

## 14) Why use tcpdump during DHCP load testing?
**Answer:** DHCP is UDP broadcast traffic; tcpdump confirms real DISCOVER/OFFER/REQUEST/ACK packets are flowing on ports 67/68 and provides evidence of DHCP transactions.

---

## 15) What is one production improvement you could add to this lab setup?
**Answer:** Improvements could include:
- high availability DHCP (failover pairs)
- DHCP logging to centralized SIEM
- network segmentation/VLAN-aware scopes
- stricter firewall rules and interface binding
- integration with DNS updates (DDNS) if required
