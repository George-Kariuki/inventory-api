# Setup Guide: Accounts and Secrets Configuration

This guide will walk you through creating the necessary accounts and configuring secrets for CI/CD.

## Step 1: Create Docker Hub Account

**Why:** To store and share Docker images

**Steps:**
1. Go to https://hub.docker.com/signup
2. Create a free account (choose a username - this will be your Docker Hub username)
3. Verify your email address
4. **Note your username** - you'll need it for secrets

**What you'll need:**
- Docker Hub Username (e.g., `georgekariuki`)
- Docker Hub Password (or Access Token - recommended)

**Create Access Token (Recommended):**
1. Go to https://hub.docker.com/settings/security
2. Click "New Access Token"
3. Name it: `github-actions`
4. Copy the token (you won't see it again!)
5. Use this token as your `DOCKER_PASSWORD` secret

---

## Step 2: Create Heroku Account

**Why:** To deploy your application to the cloud

**Steps:**
1. Go to https://signup.heroku.com/
2. Create a free account
3. Verify your email address
4. **Note your email** - you'll need it for secrets

**Install Heroku CLI (Optional but helpful):**
```bash
# macOS
brew tap heroku/brew && brew install heroku

# Or download from: https://devcenter.heroku.com/articles/heroku-cli
```

**Login to Heroku:**
```bash
heroku login
```

**Create a Heroku App:**
```bash
# Create app (choose a unique name)
heroku create inventory-api-yourname

# Or create via web: https://dashboard.heroku.com/new-app
```

**Get Heroku API Key:**
1. Go to https://dashboard.heroku.com/account
2. Scroll to "API Key"
3. Click "Reveal" and copy it
4. This is your `HEROKU_API_KEY` secret

**What you'll need:**
- Heroku Email (the email you signed up with)
- Heroku API Key (from account settings)
- Heroku App Name (e.g., `inventory-api-yourname`)

---

## Step 3: Configure GitHub Secrets

**Why:** GitHub Actions needs credentials to push to Docker Hub and deploy to Heroku

**Steps:**
1. Go to your GitHub repository: https://github.com/George-Kariuki/inventory-api
2. Click **Settings** (top menu)
3. Click **Secrets and variables** → **Actions** (left sidebar)
4. Click **New repository secret** for each secret below:

### Required Secrets:

#### Docker Hub Secrets:
- **Name:** `DOCKER_USERNAME`
  - **Value:** Your Docker Hub username (e.g., `georgekariuki`)

- **Name:** `DOCKER_PASSWORD`
  - **Value:** Your Docker Hub password OR access token (recommended)

#### Heroku Secrets:
- **Name:** `HEROKU_EMAIL`
  - **Value:** Your Heroku account email

- **Name:** `HEROKU_API_KEY`
  - **Value:** Your Heroku API key (from https://dashboard.heroku.com/account)

- **Name:** `HEROKU_APP_NAME`
  - **Value:** Your Heroku app name (e.g., `inventory-api-yourname`)

**Important:** 
- Secrets are encrypted and only visible to GitHub Actions
- Never commit secrets to your code!
- If you change a secret, update it in GitHub Settings

---

## Step 4: Configure Heroku Environment Variables

**Why:** Your app needs database connection and other configs on Heroku

**Steps:**
1. Go to https://dashboard.heroku.com/apps/YOUR_APP_NAME/settings
2. Click **Reveal Config Vars**
3. Add these variables:

**Required:**
- **Key:** `DATABASE_URL`
  - **Value:** Will be auto-created when you add PostgreSQL addon (see below)

**Optional (for production):**
- **Key:** `ENVIRONMENT`
  - **Value:** `production`

- **Key:** `LOG_LEVEL`
  - **Value:** `INFO`

---

## Step 5: Add PostgreSQL to Heroku

**Why:** Your app needs a database

**Steps:**
1. Go to https://dashboard.heroku.com/apps/YOUR_APP_NAME/resources
2. Search for "Heroku Postgres"
3. Click "Add" (free tier: "Hobby Dev")
4. The `DATABASE_URL` will be automatically set!

**Or via CLI:**
```bash
heroku addons:create heroku-postgresql:hobby-dev
```

---

## Step 6: Test the Setup

**After configuring all secrets:**

1. **Push your code:**
   ```bash
   git add .
   git commit -m "Add CI/CD with linting, Docker Hub, and Heroku"
   git push
   ```

2. **Watch GitHub Actions:**
   - Go to https://github.com/George-Kariuki/inventory-api/actions
   - Click on the running workflow
   - Watch it:
     - ✅ Run linting (ruff, black, mypy)
     - ✅ Run tests
     - ✅ Build Docker image
     - ✅ Push to Docker Hub
     - ✅ Deploy to Heroku

3. **Check your app:**
   - Go to https://YOUR_APP_NAME.herokuapp.com
   - Test endpoints: https://YOUR_APP_NAME.herokuapp.com/docs

---

## Troubleshooting

### Docker Hub Push Fails
- Check `DOCKER_USERNAME` and `DOCKER_PASSWORD` secrets are correct
- Verify Docker Hub account is active
- Try using an access token instead of password

### Heroku Deployment Fails
- Check all Heroku secrets are set correctly
- Verify Heroku app name matches `HEROKU_APP_NAME` secret
- Check Heroku logs: `heroku logs --tail -a YOUR_APP_NAME`

### Linting Fails
- Run locally: `poetry run ruff check app/`
- Auto-fix: `poetry run ruff check --fix app/`
- Format: `poetry run black app/`

---

## Quick Reference

**Local Commands:**
```bash
# Lint code
poetry run ruff check app/

# Auto-fix linting issues
poetry run ruff check --fix app/

# Format code
poetry run black app/

# Type check
poetry run mypy app/

# Run all checks
poetry run ruff check app/ && poetry run black --check app/ && poetry run mypy app/
```

**Heroku Commands:**
```bash
# View logs
heroku logs --tail -a YOUR_APP_NAME

# Open app
heroku open -a YOUR_APP_NAME

# Check app status
heroku ps -a YOUR_APP_NAME
```

---

## Next Steps

Once everything is set up:
1. ✅ Code is automatically linted on every push
2. ✅ Tests run automatically
3. ✅ Docker image is built and pushed to Docker Hub
4. ✅ App is deployed to Heroku automatically

Your API will be live at: `https://YOUR_APP_NAME.herokuapp.com`

🎉 Congratulations! You now have a complete CI/CD pipeline!

