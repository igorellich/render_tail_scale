FROM node:18-alpine

# Install dependencies
RUN apk update && apk add --no-cache \
    curl \
    iptables \
    ip6tables \
    net-tools \
    tar

# Install Tailscale MANUALLY (no install script)
RUN curl -f -o /tmp/tailscale.tgz https://pkgs.tailscale.com/stable/tailscale_1.58.2_amd64.tgz && \
    tar xzf /tmp/tailscale.tgz -C /tmp --strip-components=1 && \
    mv /tmp/tailscale /usr/local/bin/ && \
    mv /tmp/tailscaled /usr/local/sbin/ && \
    rm -rf /tmp/tailscale*

WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install npm dependencies
RUN npm cache clean --force && \
    npm install

# Copy application code
COPY . .

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create Tailscale directories
RUN mkdir -p /var/run/tailscale /var/lib/tailscale

EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]