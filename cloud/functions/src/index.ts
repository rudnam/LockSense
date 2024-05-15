// import { onRequest } from "firebase-functions/v2/https";
import { onValueUpdated } from "firebase-functions/v2/database";
import { setGlobalOptions } from "firebase-functions/v2/options";

import * as logger from "firebase-functions/logger";

import * as admin from "firebase-admin";

setGlobalOptions({ region: "asia-southeast1" });
admin.initializeApp();

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", { structuredData: true });
//   response.send("Hello from Firebase!");
// });

export const notifyUserLed = onValueUpdated({ ref: "/led/state" }, (event) => {
  const snapshot = event.data.after;
  const value = snapshot.val();
  logger.log("The data value is", value);
  const ref = admin.database().ref("FCMToken");
  return ref.once(
    "value",
    (snap) => {
      const payload = {
        token: snap.val(),
        notification: {
          title: "The LED value changed!",
          body: `The LED's value is now ${value}`,
        },
      };

      admin.messaging().send(payload);
    },
    (errorObject) => {
      logger.error("The read failed: " + errorObject.message);
    }
  );
});
