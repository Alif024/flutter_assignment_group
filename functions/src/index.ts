import {Readable} from "stream";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2";
import {google} from "googleapis";

setGlobalOptions({region: "us-central1", maxInstances: 10});

export const uploadAssetImageToDrive = onCall({
  secrets: ["DRIVE_FOLDER_ID", "DRIVE_CLIENT_EMAIL", "DRIVE_PRIVATE_KEY"],
}, async (request) => {
  const data = request.data ?? {};
  const base64 = String(data.base64 ?? "").trim();
  const fileName = String(data.fileName ?? "").trim();
  const mimeType = String(data.mimeType ?? "image/jpeg").trim();
  const assetCode = String(data.assetCode ?? "").trim();

  if (!base64 || !fileName || !assetCode) {
    throw new HttpsError(
      "invalid-argument",
      "base64, fileName and assetCode are required.",
    );
  }

  const folderId = process.env.DRIVE_FOLDER_ID?.trim();
  const clientEmail = process.env.DRIVE_CLIENT_EMAIL?.trim();
  const privateKey = process.env.DRIVE_PRIVATE_KEY?.replace(/\\n/g, "\n");
  if (!folderId || !clientEmail || !privateKey) {
    throw new HttpsError(
      "failed-precondition",
      "Missing Drive credentials in function environment.",
    );
  }

  const auth = new google.auth.JWT({
    email: clientEmail,
    key: privateKey,
    scopes: ["https://www.googleapis.com/auth/drive"],
  });
  const drive = google.drive({version: "v3", auth});

  const bytes = Buffer.from(base64, "base64");
  const stream = Readable.from(bytes);

  const createRes = await drive.files.create({
    requestBody: {
      name: fileName,
      parents: [folderId],
      description: `Asset image for ${assetCode}`,
    },
    media: {
      mimeType,
      body: stream,
    },
    fields: "id",
  });

  const fileId = createRes.data.id;
  if (!fileId) {
    throw new HttpsError("internal", "Drive upload failed.");
  }

  await drive.permissions.create({
    fileId,
    requestBody: {
      role: "reader",
      type: "anyone",
    },
  });

  return {
    fileId,
    imageUrl: `https://drive.google.com/uc?export=view&id=${fileId}`,
    webViewLink: `https://drive.google.com/file/d/${fileId}/view`,
  };
});
