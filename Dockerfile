FROM node:18-alpine

# Install dependencies
RUN apk update && apk add --no-cache \
    curl \
    iptables \
    ip6tables \
    net-tools

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install with retry logic and cache cleaning
RUN npm cache verify && \
    (npm install || (sleep 5 && npm install))

# Copy application code
COPY . .

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]