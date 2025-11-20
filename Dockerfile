# Use your application's base image
FROM node:18-alpine

# Install Tailscale dependencies
RUN apk add --no-cache \
    curl \
    iptables \
    ip6tables \
    net-tools

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Copy your application code
COPY package*.json ./
RUN npm install

COPY . .

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose your application port
EXPOSE 3000

# Use the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]