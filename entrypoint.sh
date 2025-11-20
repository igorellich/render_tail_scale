#!/bin/sh
set -e

echo "Starting Tailscale..."

# Create the tailscale state directory
mkdir -p /var/lib/tailscale

# Start tailscaled in background
echo "Starting tailscaled..."
tailscaled --tun=userspace-networking --socket=/var/run/tailscale/tailscaled.sock &
sleep 5
# Bring up Tailscale
echo "Starting Tailscale with auth key..."
tailscale up \
    --authkey=${TS_AUTHKEY} \
    --hostname=render-${RENDER_SERVICE_NAME:-app} \
    --advertise-exit-node \
    --accept-dns=false

echo "Tailscale started successfully!"
sleep 10
# Get Tailscale IP address
TAILSCALE_IP=$(tailscale ip -4)
echo "Tailscale IP: ${TAILSCALE_IP}"

# Start your main application
echo "Starting main application..."
exec npm start