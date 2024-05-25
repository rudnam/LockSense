import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

const getDatabase = async (path: string) => {
  const ref = admin.database().ref(path);
  return new Promise((resolve, reject) => {
    ref.once(
      "value",
      (snapshot) => {
        const value = snapshot.val();
        logger.log(`Successfully read db path "${path}" with value ${value}`);

        resolve(value);
      },
      (errorObject) => {
        logger.error(`The read failed: ${errorObject.message}.`);
        reject(errorObject);
      }
    );
  });
};

const setDatabase = async (path: string, value: unknown) => {
  const ref = admin.database().ref(path);
  return ref.set(value, (err) => {
    if (!err) {
      logger.log(`Successfully updated db path "${path}" with value ${value}`);
    } else {
      logger.error(`Set database failed: ${err.message}.`);
    }
  });
};

const sendNotification = async (information: {
  title: string;
  body: string;
}) => {
  const token = (await getDatabase("FCMToken")) as string;
  const payload = {
    token: token,
    notification: {
      title: information.title,
      body: information.body,
    },
  };

  await admin.messaging().send(payload);
  logger.log(
    `Successfully sent push notification, title: ${information.title}`
  );
};

export default {
  getDatabase,
  setDatabase,
  sendNotification,
};
