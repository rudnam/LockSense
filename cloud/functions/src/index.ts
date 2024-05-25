import { onValueUpdated } from "firebase-functions/v2/database";
import { setGlobalOptions } from "firebase-functions/v2/options";

import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import * as mqtt from "mqtt";

type QoS = 0 | 1 | 2;

// Setup

setGlobalOptions({ region: "asia-southeast1" });
admin.initializeApp();

// MQTT

const client = mqtt.connect(
  "tls://bd32be4c22d54fb2ba2fef3f2258929b.s1.eu.hivemq.cloud:8883",
  {
    username: "admin",
    password: "#5%y*DefsiuqRw",
  }
);

client.on("connect", () => {
  const lockTopic = "locks/+/state";
  _MQTTSubscribeToTopic(lockTopic);
});

client.on("message", async (topic, message) => {
  logger.log("Received an MQTT message");
  logger.log("topic is", topic);
  logger.log("message is", message.toString());

  const match = topic.match(/^locks\/([^/]+)\/state$/);
  if (match) {
    const lockId = match[1];
    const oldValue = await _getDatabase(`locks/${lockId}/state`);
    const newValue = message.toString();
    if (
      (typeof oldValue === "string" || oldValue instanceof String) &&
      oldValue !== newValue
    ) {
      logger.log(`MQTT message wants to set from ${oldValue} to ${newValue}.`);
      await _setDatabase(`/locks/${lockId}/state`, newValue);
    }
  } else {
    logger.log("Did nothing.");
  }
});

// Functions

export const handleLockUpdate = onValueUpdated(
  { ref: "/locks/{lockId}/state" },
  async (event) => {
    const snapshotBefore = event.data.before;
    const snapshotAfter = event.data.after;
    const oldValue: string = snapshotBefore.val();
    const newValue: string = snapshotAfter.val();
    if (oldValue !== newValue) {
      logger.log("Detected lock state change:", oldValue, "->", newValue);
      await _sendUserNotification({
        title: "The Lock state changed!",
        body: `The Lock's state is now ${newValue}`,
      });
      _MQTTPublishToTopic(
        `locks/${event.params.lockId}/state`,
        newValue.toString()
      );
    }
  }
);

// Utils

const _getDatabase = async (path: string) => {
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

const _setDatabase = async (path: string, value: unknown) => {
  const ref = admin.database().ref(path);
  return ref.set(value, (err) => {
    if (!err) {
      logger.log(`Successfully updated db path "${path}" with value ${value}`);
    } else {
      logger.error(`Set database failed: ${err.message}.`);
    }
  });
};

const _sendUserNotification = async (information: {
  title: string;
  body: string;
}) => {
  const token = (await _getDatabase("FCMToken")) as string;
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

const _MQTTSubscribeToTopic = (topic: string) => {
  client.subscribe(topic, (err) => {
    if (!err) {
      logger.log(`Successfully subscribed to ${topic}.`);
    } else {
      logger.error(`MQTT subscription failed: ${err.message}.`);
    }
  });
};

const _MQTTPublishToTopic = (topic: string, message: string, qos: QoS = 1) => {
  client.publish(topic, message, { qos }, (err) => {
    if (!err) {
      logger.log(
        `Successfully published to ${topic} with message "${message}" and QoS ${qos}`
      );
    } else {
      logger.error(`Failed to publish to ${topic}: ${err.message}`);
    }
  });
};
