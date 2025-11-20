FROM node:18-alpine

# Install dependencies
RUN apk update && apk add --no-cache \
    curl \
    tar \
    iptables \
    ip6tables \
    libc6-compat

# Download and install Tailscale with proper paths
RUN cd /tmp && \
    curl -fsSL -o tailscale.tgz https://pkgs.tailscale.com/stable/tailscale_1.58.2_amd64.tgz && \
    tar xzf tailscale.tgz && \
    mkdir -p /usr/local/bin /usr/local/sbin && \
    mv tailscale_*/tailscale /usr/local/bin/ && \
    mv tailscale_*/tailscaled /usr/local/sbin/ && \
    chmod +x /usr/local/bin/tailscale /usr/local/sbin/tailscaled && \
    rm -rf /tmp/tailscale*

# Verify installation
RUN ls -la /usr/local/bin/tailscale && \
    ls -la /usr/local/sbin/tailscaled && \
    /usr/local/bin/tailscale version

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm install

# Copy application code
COPY . .

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create Tailscale directories
RUN mkdir -p /var/run/tailscale /var/lib/tailscale

EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]