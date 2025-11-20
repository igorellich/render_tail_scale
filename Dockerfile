FROM node:18-alpine

# Install dependencies
RUN apk update && apk add --no-cache \
    curl \
    iptables \
    ip6tables \
    tar

# Download and extract Tailscale to correct locations
RUN curl -fsSL -o /tmp/tailscale.tgz https://pkgs.tailscale.com/stable/tailscale_1.58.2_amd64.tgz && \
    tar xzf /tmp/tailscale.tgz -C /usr/local/bin/ --strip-components=1 tailscale_*/tailscale && \
    tar xzf /tmp/tailscale.tgz -C /usr/local/sbin/ --strip-components=1 tailscale_*/tailscaled && \
    chmod +x /usr/local/bin/tailscale /usr/local/sbin/tailscaled && \
    rm -f /tmp/tailscale.tgz

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir -p /var/run/tailscale /var/lib/tailscale

EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]