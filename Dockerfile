FROM python:3.12-slim

# Install cron
RUN apt-get update && apt-get install -y cron

WORKDIR /app

# Install the required packages
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy your application code and entry script
COPY . .
COPY entry.sh /entry.sh

# Give execution rights on the entry script
RUN chmod +x /entry.sh

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the entry script
ENTRYPOINT ["/entry.sh"]