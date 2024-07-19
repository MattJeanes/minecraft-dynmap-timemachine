#!/bin/bash

# Function to handle SIGINT (Ctrl-C)
cleanup() {
    echo "Caught SIGINT signal. Exiting."
    # Stop the cron service or any other cleanup you want to perform
    service cron stop
    # Kill the tail process
    kill "$TAIL_PID"
    exit 0
}

# Trap SIGINT and call the cleanup function
trap cleanup SIGINT

# Error if CRON_SCHEDULE is not set
if [ -z "${CRON_SCHEDULE}" ]; then
    echo "CRON_SCHEDULE is not set. Exiting."
    exit 1
fi

# Collect all arguments for the Python script
PYTHON_ARGS="$@"

# Create crontab entry with the user-provided schedule and pass all arguments to the Python script
echo "${CRON_SCHEDULE} /usr/local/bin/python3.12 /app/dynmap-timemachine.py ${PYTHON_ARGS} >> /var/log/cron.log 2>&1" > /etc/cron.d/dynamic-crontab

# Give execution rights on the cron job
chmod 0644 /etc/cron.d/dynamic-crontab

# Apply cron job
crontab /etc/cron.d/dynamic-crontab

# Start cron in the background
service cron start

# Start tail in the background and save its PID
tail -f /var/log/cron.log &
TAIL_PID=$!

# Keep the script running to catch the signal
while true; do
    sleep 1
done