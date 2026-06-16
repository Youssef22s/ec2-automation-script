#!/bin/env bash 

# ==========================================
#          Configuration Variables
# ==========================================
#


TARGET_SERVERS=("3.84.143.159" "34.230.29.193")
SSH_USER="ubuntu"
SSH_KEY=~/.ssh/dev_web_key.pem
NEW_USER="newUserrr"
LOG_FILE="./setup_summary.log"
PACKAGES=("nginx" "curl" "htop")

SSH_OPTS="-i $SSH_KEY -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=5"

SUCCESS_COUNT=0
FAILURE_COUNT=0

log_msg() {

	local STATUS=$1
	local MESSAGE=$2
	local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

	local LOG_LINE="[$TIMESTAMP] [$STATUS] - [$MESSAGE]"

	echo "$LOG_LINE" >> "$LOG_FILE"

}

check_server() {

	local SERVER=$1

	log_msg "INFO" "Checking connection to $SERVER...."
	
	if nc -z -w 3 "$SERVER" 22 &>/dev/null
	then 
		log_msg "OK" "Server $SERVER is reachable."
        	return 0
	else
        	log_msg "FAIL" "Server $SERVER is UNREACHABLE."
        	return 1
   	fi
}

configure_target_server() {

	local SERVER="$1"

	echo "[INFO] Starting Config for $SERVER...."

	log_msg "INFO" "Starting Config for $SERVER...."

	echo "[INFO] Creating user $NEW_USER on $SERVER...."

	log_msg "INFO" "Creating user $NEW_USER on $SERVER...."

	if ssh $SSH_OPTS "$SSH_USER@$SERVER" id "$NEW_USER" &> /dev/null; then 
		echo "[ERROR] User $NEW_USER is already exist in $SERVER"
		log_msg "ERROR" "User $NEW_USER is already exist in $SERVER"
	else 
		ssh $SSH_OPTS "$SSH_USER@$SERVER" sudo useradd -m -s /bin/bash "$NEW_USER"

		if [[ $? -eq 0 ]]; then 
			echo "[OK] User created successfully In $SERVER"
			log_msg "OK" "User $NEW_USER created successfully in $SERVER."
		else
			echo "[FAIL] Failed to create user $NEW_USER in $SERVER."
			log_msg "ERROR" "Failed to create user in $SERVER."
			return 1
		fi
	fi

	echo "[INFO] Updating apt & installing packages..."
	log_msg "INFO" "Updating apt & installing packages..."

	if ssh $SSH_OPTS "$SSH_USER@$SERVER" \
		"sudo apt-get update &&sudo apt-get install -y" "${PACKAGES[@]}" &>/dev/null
	then
		echo "[OK] ${PACKAGES[@]} installed successfully on $SERVER."
   		log_msg "OK" "Packages installed successfully on $SERVER."
		return 0
	else
		echo "[FAIL] Failed to install packages on $SERVER."
    		log_msg "ERROR" "Failed to install packages on $SERVER."
		return 1
	fi
}

display_summary() {
    echo "[INFO] ========================================"
    echo "[INFO] EXECUTION SUMMARY"
    echo "[INFO] ========================================"
    echo  "[SUCCESS] $SUCCESS_COUNT servers fully configured."
    echo "[FAIL] $FAILURE_COUNT servers encountered errors or were unreachable."
    echo "[INFO] Detailed logs saved to: $LOG_FILE"
}

> "$LOG_FILE"
log_msg "INFO" "Starting multi-server configuration script..."

for SERVER in "${TARGET_SERVERS[@]}"; do
    log_msg "INFO" "----------------------------------------"
    log_msg "INFO" "Processing Server: $SERVER"

    echo "[INFO] Checking connection to $SERVER"

    if check_server "$SERVER"; then

	    echo "[OK] $SERVER is reachable"   

    	if configure_target_server "$SERVER"; then
		echo "[SUCCESS] Config on $SERVER completed successfully."
        	log_msg "SUCCESS" "Configuration on $SERVER completed successfully."
        	((SUCCESS_COUNT++))
        else
		echo "[FAIL] Config aborted for $SERVER due to errors."
            log_msg "FAIL" "Configuration aborted for $SERVER due to errors."
            ((FAILURE_COUNT++))
        fi
    else
        log_msg "INFO" "Skipping configuration for $SERVER."
        ((FAILURE_COUNT++))
    fi
done

display_summary

