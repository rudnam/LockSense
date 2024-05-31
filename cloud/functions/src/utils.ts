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

const sendPushNotification = async (
  token: string,
  information: {
    title: string;
    body: string;
  }
) => {
  const payload = {
    token: token,
    notification: {
      ...information,
    },
  };

  await admin.messaging().send(payload);
};

const updateNotifications = async (
  userId: string,
  information: { title: string; body: string }
) => {
  const type: NotificationType = information.title.includes("unlocked")
    ? "unlocked"
    : information.title.includes("locked")
    ? "locked"
    : information.title.includes("vibration")
    ? "warning"
    : "default";

  const notificationObj = {
    ...information,
    timestamp: Date.now(),
    type: type,
  };

  await pushDatabase(`/users/${userId}/notifications`, notificationObj);
};

const notifyUsers = async (
  userIds: string[],
  message: { title: string; body: string }
) => {
  const tokensSet = new Set<string>();

  await Promise.all(
    userIds.map(async (userId) => {
      const token = ((await getDatabase(`users/${userId}/FCMToken`)) ??
        "") as string;
      if (token) {
        tokensSet.add(token);
      }
    })
  );

  const tokens = Array.from(tokensSet);

  await Promise.all(
    tokens.map(async (token) => {
      await sendPushNotification(token, message);
    })
  );

  await Promise.all(
    userIds.map(async (userId) => {
      await updateNotifications(userId, message);
    })
  );
};

const capitalize = (str: string) => {
  return str.charAt(0).toUpperCase() + str.slice(1);
};

const isValidLockStatus = (str: string): str is LockStatus => {
  return ["unlocked", "locked", "unlocking", "locking", "vibrating"].includes(
    str
  );
};

export default {
  getDatabase,
  setDatabase,
  pushDatabase,
  sendNotification: sendPushNotification,
  notifyUsers,
  capitalize,
  isValidLockStatus,
};
