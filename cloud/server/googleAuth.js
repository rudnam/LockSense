var { google } = require("googleapis");

// Load the service account key JSON file.
var serviceAccount = require("./serviceAccountKey.json");

// Define the required scopes.
var scopes = [
  "https://www.googleapis.com/auth/userinfo.email",
  "https://www.googleapis.com/auth/firebase.database",
];

// Authenticate a JWT client with the service account.
var jwtClient = new google.auth.JWT(
  serviceAccount.client_email,
  null,
  serviceAccount.private_key,
  scopes
);

// Export a function that returns a promise resolving to the access token
module.exports = new Promise((resolve, reject) => {
  jwtClient.authorize(function (error, tokens) {
    if (error) {
      console.log("Error making request to generate access token:", error);
      reject(error);
    } else if (tokens.access_token === null) {
      console.log(
        "Provided service account does not have permission to generate access tokens"
      );
      reject(new Error("No access token generated"));
    } else {
      var accessToken = tokens.access_token;
      resolve(accessToken);
    }
  });
});
