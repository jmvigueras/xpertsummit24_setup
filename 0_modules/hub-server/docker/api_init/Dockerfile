FROM ubuntu:20.04

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get install -y wget unzip vim && \
    apt-get install -y git jq curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the application code
COPY api.py .

# Expose the port
EXPOSE 8080

# Start the application
CMD ["python3", "api.py"]