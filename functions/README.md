# Drive Upload Function Setup

This function uploads asset images to Google Drive and returns a public image URL.

## 1) Create/choose a Google Cloud service account

- In Google Cloud Console (same project as Firebase), create a service account.
- Enable **Google Drive API** for the project.
- Generate a JSON key for that service account.

## 2) Share your Drive folder with the service account

Share this folder as `Editor` to the service account email:

`https://drive.google.com/drive/folders/149NF4OGeb1pIf7LfVzDlg4xOq_evfP_5`

## 3) Set function environment variables

From `functions/`:

```bash
firebase functions:secrets:set DRIVE_FOLDER_ID
firebase functions:secrets:set DRIVE_CLIENT_EMAIL
firebase functions:secrets:set DRIVE_PRIVATE_KEY
```

Values:
- `DRIVE_FOLDER_ID`: `149NF4OGeb1pIf7LfVzDlg4xOq_evfP_5`
- `DRIVE_CLIENT_EMAIL`: from service account JSON (`client_email`)
- `DRIVE_PRIVATE_KEY`: from service account JSON (`private_key`)

## 4) Build & deploy

```bash
npm install
npm run build
firebase deploy --only functions
```

Callable function name:
- `uploadAssetImageToDrive`

