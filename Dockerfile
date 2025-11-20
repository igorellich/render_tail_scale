FROM node:18-alpine

# Install dependencies in single layer
RUN apk add --no-cache \
    curl \
    iptables \
    ip6tables \
    net-tools \
    bash

# Download and install Tailscale manually
RUN curl -fsSL -o /tmp/tailscale.tgz https://pkgs.tailscale.com/stable/tailscale_1.58.2_amd64.tgz && \
    tar xzf /tmp/tailscale.tgz -C /tmp && \
    mkdir -p /usr/local/bin /usr/local/sbin && \
    cp /tmp/tailscale_*/tailscale /usr/local/bin/ && \
    cp /tmp/tailscale_*/tailscaled /usr/local/sbin/ && \
    rm -rf /tmp/tailscale*

# Create necessary directories
RUN mkdir -p /var/run/tailscale /var/lib/tailscale /var/cache/tailscale

# Copy your application code
COPY package*.json ./
RUN npm install

COPY . .

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]