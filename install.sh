#!/bin/bash

# Check args
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <domain> <n8n_user> <n8n_pass> <email>"
    exit 1
fi

DOMAIN=$1
N8N_USER=$2
N8N_PASS=$3
EMAIL=$4

echo "🚀 Bắt đầu setup n8n cho domain: $DOMAIN"

# Cài đặt gói cần thiết
apt update
apt install -y docker.io docker-compose nginx certbot python3-certbot-nginx

# Tạo thư mục n8n
mkdir -p /opt/n8n && cd /opt/n8n

# Tạo docker-compose từ template
cat > docker-compose.yml <<EOF
version: '3'
services:
  n8n:
    image: n8nio/n8n
    restart: always
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=$N8N_USER
      - N8N_BASIC_AUTH_PASSWORD=$N8N_PASS
      - N8N_HOST=$DOMAIN
      - N8N_PROTOCOL=https
    volumes:
      - n8n_data:/home/node/.n8n
volumes:
  n8n_data:
EOF

# Khởi động n8n
docker compose up -d

# Cấu hình Nginx reverse proxy
cat > /etc/nginx/sites-available/n8n <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

ln -sf /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# Cấp SSL miễn phí từ Let's Encrypt
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL

echo "🎉 Setup thành công! Truy cập: https://$DOMAIN"
