# Deployment Guide for MiniLIMS

This guide explains how to set up GitHub Actions for automated deployment of MiniLIMS to a remote server.

## Prerequisites

1. A remote server with:
   - Docker and Docker Compose installed
   - SSH access enabled
   - Ports 80 and 443 open
   - SSL certificates in `~/minilims/certs/` directory

2. GitHub repository with Actions enabled

## Setup Instructions

### 1. Generate SSH Key Pair

On your local machine:

```bash
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github_actions_deploy
```

### 2. Add SSH Public Key to Server

Copy the public key to your server:

```bash
ssh-copy-id -i ~/.ssh/github_actions_deploy.pub user@your-server.com
```

Or manually add to `~/.ssh/authorized_keys` on the server.

### 3. Configure GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions, and add:

#### Required Secrets:

- **`SSH_PRIVATE_KEY`**: The private key content (from `~/.ssh/github_actions_deploy`)
  ```bash
  cat ~/.ssh/github_actions_deploy
  ```

- **`SSH_USER`**: SSH username (e.g., `ubuntu`, `root`, `deploy`)

- **`SSH_HOST`**: Server IP or domain (e.g., `192.168.1.100` or `example.com`)

#### Optional (for Advanced workflow):

- **`GITHUB_TOKEN`**: Automatically provided by GitHub Actions (no need to set manually)

### 4. Prepare Server

On your remote server:

```bash
# Create directory structure
mkdir -p ~/minilims/certs
mkdir -p ~/minilims/logs

# Place SSL certificates
# certs/cert.pem and certs/key.pem should be in ~/minilims/certs/

# Ensure Docker and Docker Compose are installed
docker --version
docker-compose --version
```

### 5. Choose Workflow

#### Option A: Simple Deployment (`deploy-minilims.yml`)

- Builds Docker image on the server
- No container registry required
- Simpler setup
- Slower builds (builds on server)

**Use this if:** You want a simple setup without container registry.

#### Option B: Advanced Deployment (`deploy-minilims-advanced.yml`)

- Builds image in GitHub Actions
- Pushes to GitHub Container Registry
- Faster deployments (pulls pre-built image)
- Requires GitHub Container Registry access

**Use this if:** You want faster deployments and better CI/CD practices.

### 6. Enable Workflow

1. Push the workflow file to your repository
2. Go to Actions tab in GitHub
3. The workflow will trigger on:
   - Push to `main`/`master` branch (when relevant files change)
   - Manual trigger via "Run workflow" button

## Workflow Files

### `deploy-minilims.yml` (Simple)

- Builds Docker image on remote server
- Copies files via SCP
- Deploys using docker-compose
- No container registry needed

### `deploy-minilims-advanced.yml` (Advanced)

- Builds Docker image in GitHub Actions
- Pushes to GitHub Container Registry
- Pulls image on server
- Includes rollback mechanism
- Health checks

## Manual Deployment

If you need to deploy manually:

```bash
# On your server
cd ~/minilims
git pull  # if using git
docker-compose -f docker-compose.minilims.yml down
docker-compose -f docker-compose.minilims.yml build --no-cache
docker-compose -f docker-compose.minilims.yml up -d
```

## Troubleshooting

### SSH Connection Issues

```bash
# Test SSH connection
ssh -i ~/.ssh/github_actions_deploy user@your-server.com

# Check SSH key permissions
chmod 600 ~/.ssh/github_actions_deploy
```

### Docker Issues

```bash
# Check Docker status
docker ps
docker-compose -f ~/minilims/docker-compose.minilims.yml ps

# View logs
docker-compose -f ~/minilims/docker-compose.minilims.yml logs

# Check container status
docker-compose -f ~/minilims/docker-compose.minilims.yml ps
```

### Certificate Issues

```bash
# Verify certificates exist
ls -la ~/minilims/certs/

# Check permissions
chmod 644 ~/minilims/certs/cert.pem
chmod 600 ~/minilims/certs/key.pem
```

### Port Conflicts

```bash
# Check if ports are in use
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Stop conflicting services
sudo systemctl stop apache2  # or nginx, or other web server
```

## Security Best Practices

1. **SSH Key Security:**
   - Use dedicated SSH key for deployments
   - Never commit private keys to repository
   - Rotate keys periodically

2. **Server Security:**
   - Use non-root user for SSH
   - Enable firewall (UFW)
   - Keep system updated
   - Use strong passwords or disable password auth

3. **SSL Certificates:**
   - Use Let's Encrypt for production
   - Keep certificates updated
   - Set proper file permissions

4. **Docker Security:**
   - Run containers as non-root when possible
   - Keep Docker updated
   - Use specific image tags (not `latest` in production)

## Monitoring

Check deployment status:

```bash
# On server
cd ~/minilims
docker-compose ps
docker-compose logs -f minilims
```

## Rollback

If deployment fails, the advanced workflow includes automatic rollback. For manual rollback:

```bash
cd ~/minilims
docker-compose -f docker-compose.minilims.yml down
# Restore from backup
cp -r ~/minilims-backup-YYYYMMDD-HHMMSS/* .
docker-compose -f docker-compose.minilims.yml up -d
```

