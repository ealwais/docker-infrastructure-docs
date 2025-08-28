# GitHub n8n Setup Guide

## Quick Links
- Personal Access Tokens: https://github.com/settings/tokens
- Developer Settings: https://github.com/settings/apps
- OAuth Apps: https://github.com/settings/developers

## Recommended Token Scopes

### Basic Operations
- `repo` - Full control of private repositories
- `public_repo` - Access public repositories only

### Advanced Operations
- `workflow` - Update GitHub Action workflows
- `gist` - Create gists
- `delete_repo` - Delete repositories
- `user` - Update profile
- `read:org` - Read organization data
- `admin:repo_hook` - Manage webhooks

## Common GitHub Operations in n8n

### Repository Operations
- Get repository info
- List repositories
- Create issues
- Get/Create/Update files
- List commits
- Create releases

### Pull Request Operations
- List pull requests
- Create pull request
- Update pull request
- Merge pull request

### Issues Operations
- Create issue
- Update issue
- List issues
- Add comments

### User Operations
- Get user info
- List user repos
- Get authenticated user

## Example Workflows

### Auto-create issues from form submissions
1. Webhook/Form trigger
2. GitHub: Create Issue
3. Send notification

### Backup code to GitHub
1. Schedule trigger (daily)
2. Read files
3. GitHub: Create/Update file
4. Notification on success/failure