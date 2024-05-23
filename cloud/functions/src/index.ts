import { onValueUpdated } from "firebase-functions/v2/database";
import { setGlobalOptions } from "firebase-functions/v2/options";

import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import * as mqtt from "mqtt";

// Setup

setGlobalOptions({ region: "asia-southeast1" });
admin.initializeApp();

// MQTT

const client = mqtt.connect("mqtt:broker.mqtt-dashboard.com");

client.on("connect", () => {
  const ldrTopic = "device/ldr";
  _MQTTSubscribeToTopic(ldrTopic);
});

client.on("message", async (topic, message) => {
  logger.log("Received an MQTT message");
  logger.log("topic is", topic);
  logger.log("message is", message.toString());

  if (topic === "device/ldr") {
    const value = parseInt(message.toString());
    await _updateDatabase("/photoresistor/state", value);
  }
});

// Functions

export const handleLedUpdate = onValueUpdated(
  { ref: "/led/state" },
  async (event) => {
    const snapshot = event.data.after;
    const value: number = snapshot.val();
    logger.log("Detected led state change.");
    logger.log("The new data value is", value);
    await _sendUserNotification({
      title: "The LED value changed!",
      body: `The LED's value is now ${value}`,
    });
    _MQTTPublishToTopic("device/led", value.toString());
  }
);

// Utils

const _updateDatabase = async (path: string, value: unknown) => {
  const ref = admin.database().ref(path);
  return ref.set(value, (err) => {
    if (!err) {
      logger.log(`Successfully updated db path "${path}" with value ${value}`);
    } else {
      logger.error(`Update database failed: ${err.message}.`);
    }
  });
};

const _sendUserNotification = async (information: {
  title: string;
  body: string;
}) => {
  const ref = admin.database().ref("FCMToken");
  return ref.once(
    "value",
    (snap) => {
      const payload = {
        token: snap.val(),
        notification: {
          title: information.title,
          body: information.body,
        },
      };

      admin.messaging().send(payload);
      logger.log(
        `Successfully sent push notification, title: ${information.title}`
      );
    },
    (errorObject) => {
      logger.error(`The read failed: ${errorObject.message}.`);
    }
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

const _MQTTPublishToTopic = (topic: string, message: string) => {
  client.publish(topic, message);
  logger.log(`Successfully published to ${topic} with message "${message}"`);
};
