# MiniLIMS Docker Setup

This setup runs MiniLIMS as a static HTML file served by nginx with HTTPS support.

## Prerequisites

1. Docker and Docker Compose installed
2. SSL certificates (cert.pem and key.pem)

## SSL Certificates

You need to provide SSL certificates. Place them in the `certs` directory:

```
certs/
  ├── cert.pem    # SSL certificate
  └── key.pem     # SSL private key
```

## Usage

1. **Build and start the container:**

```bash
docker-compose -f docker-compose.minilims.yml up -d --build
```

2. **Stop the container:**

```bash
docker-compose -f docker-compose.minilims.yml down
```

3. **View logs:**

```bash
docker-compose -f docker-compose.minilims.yml logs -f
```

4. **Access the application:**

- HTTPS: https://localhost (or your domain)
- HTTP: http://localhost (will redirect to HTTPS)

## Features

- ✅ HTTPS with SSL/TLS encryption
- ✅ HTTP to HTTPS redirect
- ✅ Security headers (HSTS, X-Frame-Options, etc.)
- ✅ Gzip compression
- ✅ Static file caching
- ✅ Production-ready nginx configuration

## Troubleshooting

### Certificate errors

If you see SSL certificate errors:
1. Make sure certificates are in `certs/` directory
2. Check file permissions: `chmod 644 certs/cert.pem` and `chmod 600 certs/key.pem`
3. Verify certificate paths in docker-compose.minilims.yml

### Port conflicts

If ports 80 or 443 are already in use:
- Change port mappings in docker-compose.minilims.yml:
  ```yaml
  ports:
    - "8080:80"
    - "8443:443"
  ```

