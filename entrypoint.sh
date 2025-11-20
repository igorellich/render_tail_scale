#!/bin/sh
set -e

echo "=== Starting Application ==="
echo "Current directory: $(pwd)"
echo "Directory contents:"
ls -la

# Create required directories
echo "Creating Tailscale directories..."
mkdir -p /var/run/tailscale /var/lib/tailscale

# Start Tailscale daemon
echo "Starting Tailscale daemon..."
/usr/local/sbin/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
TAILSCALED_PID=$!

echo "Waiting for Tailscale to start..."
sleep 20

# Check if TS_AUTHKEY is set
if [ -z "${TS_AUTHKEY}" ]; then
    echo "ERROR: TS_AUTHKEY is not set!"
    echo "Please set TS_AUTHKEY in Render environment variables"
    exit 1
fi

echo "Authenticating with Tailscale..."
if /usr/local/bin/tailscale up \
    --authkey="${TS_AUTHKEY}" \
    --hostname="render-app" \
    --accept-dns=false; then
    echo "Tailscale authentication successful!"
    echo "Tailscale IP: $(/usr/local/bin/tailscale ip -4)"
else
    echo "WARNING: Tailscale authentication failed, but continuing..."
fi

# Start the application
echo "Starting Node.js application..."
echo "Current directory: $(pwd)"
echo "Node version: $(node --version)"
echo "NPM version: $(npm --version)"

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "ERROR: package.json not found!"
    ls -la
    exit 1
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "WARNING: node_modules not found, installing dependencies..."
    npm install
fi

echo "Running: npm start"
exec npm start