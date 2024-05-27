const { google } = require("googleapis");
const serviceAccount = require("./serviceAccountKey.json");

const scopes = [
  "https://www.googleapis.com/auth/userinfo.email",
  "https://www.googleapis.com/auth/firebase.database",
];

const jwtClient = new google.auth.JWT(
  serviceAccount.client_email,
  null,
  serviceAccount.private_key,
  scopes
);

let cachedToken = null;
let tokenExpiry = null;

async function getAccessToken() {
  if (cachedToken && tokenExpiry && Date.now() < tokenExpiry - 60000) {
    return cachedToken;
  }

  const tokens = await jwtClient.authorize();
  if (tokens.access_token) {
    cachedToken = tokens.access_token;
    tokenExpiry = tokens.expiry_date;
    return cachedToken;
  } else {
    throw new Error("Failed to obtain access token");
  }
}

module.exports = getAccessToken;
