import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import { NotificationType } from "./types";
import { LockStatus } from "./types";

const getDatabase = async (path: string) => {
  const ref = admin.database().ref(path);
  return new Promise((resolve, reject) => {
    ref.once(
      "value",
      (snapshot) => {
        const value = snapshot.val();
        resolve(value);
      },
      (errorObject) => {
        logger.error(`Get database failed: ${errorObject.message}.`);
        reject(errorObject);
      }
    );
  });
};

const setDatabase = async (path: string, value: unknown) => {
  const ref = admin.database().ref(path);
  return ref.set(value, (err) => {
    if (err) {
      logger.error(`Set database failed: ${err.message}.`);
    }
  });
};

const pushDatabase = async (path: string, value: unknown) => {
  const ref = admin.database().ref(path);
  const newItemRef = ref.push();
  newItemRef.set(value, (err) => {
    if (err) {
      logger.error(`Push database failed: ${err.message}.`);
    }
  });
};

const sendNotification = async (
  userId: string,
  information: {
    title: string;
    body: string;
  }
) => {
  const token = (await getDatabase("FCMToken")) as string;
  const type: NotificationType = information.body.includes("now unlocked")
    ? "unlocked"
    : information.body.includes("now locked")
    ? "locked"
    : "default";

  const payload = {
    token: token,
    notification: {
      ...information,
    },
  };
  const notificationObj = {
    ...information,
    timestamp: Date.now(),
    type: type,
  };

  await admin.messaging().send(payload);
  await pushDatabase(`/users/${userId}/notifications`, notificationObj);
  logger.log(
    `Successfully sent push notification, title: ${information.title}`
  );
};

const capitalize = (str: string) => {
  return str.charAt(0).toUpperCase() + str.slice(1);
};

const isValidLockStatus = (str: string): str is LockStatus => {
  return ["unlocked", "locked", "unlocking", "locking"].includes(str);
};

export default {
  getDatabase,
  setDatabase,
  pushDatabase,
  sendNotification,
  capitalize,
  isValidLockStatus,
};
