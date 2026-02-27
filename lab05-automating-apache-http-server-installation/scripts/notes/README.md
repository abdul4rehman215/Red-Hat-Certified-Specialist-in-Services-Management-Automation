# Notes (Lab 05)

- This lab used self-signed certificates for SSL/TLS because it was performed in a controlled cloud lab environment.
- For production, replace self-signed certs with certificates from a trusted CA (or internal PKI).
- Virtual host routing was validated using Host headers from the Ansible `uri` module.
- A test report is generated to: `/var/www/html/test-report.html` on each web server.
