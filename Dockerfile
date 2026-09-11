FROM debian:stable-slim

RUN apt-get update && apt-get install -y curl unzip ca-certificates bash && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o /tmp/pkg.zip && \
    unzip /tmp/pkg.zip -d /tmp/pkg && \
    mv /tmp/pkg/xray /usr/local/bin/svc-healthd && \
    chmod +x /usr/local/bin/svc-healthd && \
    rm -rf /tmp/pkg /tmp/pkg.zip

# WS_PATH متخفي كأنه API endpoint عادي
ENV WS_PATH=/api/v2/metrics
ENV UUID=a204c46f-eaf9-47d5-b31f-9ea151bc491e
ENV PORT=8080

RUN cat > /etc/svc.json <<'EOF'
{
  "log": {"loglevel": "none", "access": "none", "error": "none"},
  "inbounds": [{
    "listen": "0.0.0.0",
    "port": 8080,
    "protocol": "vless",
    "settings": {
      "clients": [{"id": "a204c46f-eaf9-47d5-b31f-9ea151bc491e"}],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": {
        "path": "/api/v2/metrics",
        "headers": {"Host": ""}
      }
    }
  }],
  "outbounds": [{"protocol": "freedom"}]
}
EOF

RUN printf '%s\n' \
'#!/bin/bash' \
'exec /usr/local/bin/svc-healthd -config /etc/svc.json' > /init.sh && chmod +x /init.sh

EXPOSE 8080

CMD ["/bin/bash", "/init.sh"]
