# N8N Auto Deploy Script

Script này giúp bạn tự động triển khai n8n + Nginx + SSL Let's Encrypt trên Ubuntu.

## Cách dùng

```bash
git clone https://github.com/youruser/n8n-auto-deploy.git
cd n8n-auto-deploy
chmod +x install.sh
./install.sh <domain> <n8n_user> <n8n_pass> <email>
```

Ví dụ:

```bash
./install.sh n8n.example.com admin mypass admin@example.com
```

## Yêu cầu

- Ubuntu 20.04+ (test trên 22.04)
- Domain đã trỏ về IP máy chủ
