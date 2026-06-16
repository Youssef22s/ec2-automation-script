# EC2 Automation Script

A simple Bash script to automate setup of multiple AWS EC2 Ubuntu servers via SSH.

## What it does
- Connects to multiple EC2 servers
- Creates a new user on each server
- Installs basic packages (nginx, curl, htop)
- Logs the process results

## Files
- setup_servers.sh → main script
- setup_summary.log → execution logs
- .gitignore → ignores sensitive files

## Requirements
- AWS EC2 Ubuntu servers
- SSH key access
- Bash + SSH installed

## How to run
```bash
chmod +x setup_servers.sh
./setup_servers.sh
