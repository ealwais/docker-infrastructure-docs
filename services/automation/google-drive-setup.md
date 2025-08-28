# Google Drive n8n Setup Guide

## Google Cloud Console URLs
- Main Console: https://console.cloud.google.com
- API Library: https://console.cloud.google.com/apis/library
- Credentials: https://console.cloud.google.com/apis/credentials
- OAuth Consent: https://console.cloud.google.com/apis/credentials/consent

## Required OAuth2 Redirect URIs
Add BOTH of these to your OAuth client:
```
http://192.168.3.11:5678/rest/oauth2-credential/callback
https://n8n.alwais.org/rest/oauth2-credential/callback
```

## Common Issues & Solutions

### "Access blocked" error
- Make sure you added your email as a test user in OAuth consent screen
- Or publish the app (requires review for production use)

### "Redirect URI mismatch"
- Check that you added both HTTP and HTTPS callback URLs
- The URL must match exactly (including http vs https)

### Connection timeout
- Try using the local URL first: http://192.168.3.11:5678
- Make sure n8n is accessible at the URL you're using

## Available Google Drive Operations in n8n
- Create/Upload files
- Download files
- List files in folders
- Move/Copy files
- Delete files
- Share files
- Update file metadata