import * as mqtt from "mqtt";
import * as logger from "firebase-functions/logger";
import utils from "../utils";

type QoS = 0 | 1 | 2;

const client = mqtt.connect(
  "tls://bd32be4c22d54fb2ba2fef3f2258929b.s1.eu.hivemq.cloud:8883",
  {
    username: "admin",
    password: "#5%y*DefsiuqRw",
  }
);

client.on("connect", () => {
  const lockTopic = "locks/+/state";
  subscribe(lockTopic);
});

client.on("message", async (topic, message) => {
  logger.log("Received an MQTT message");
  logger.log("topic is", topic);
  logger.log("message is", message.toString());

  const match = topic.match(/^locks\/([^/]+)\/state$/);
  if (match) {
    const lockId = match[1];
    const oldValue = await utils.getDatabase(`locks/${lockId}/state`);
    const newValue = message.toString();

    if (
      (typeof oldValue === "string" || oldValue instanceof String) &&
      oldValue !== newValue
    ) {
      logger.log(`MQTT message wants to set from ${oldValue} to ${newValue}.`);
      await utils.setDatabase(`/locks/${lockId}/state`, newValue);
    }
  } else {
    logger.log("Did nothing.");
  }
});

const subscribe = (topic: string) => {
  client.subscribe(topic, (err) => {
    if (!err) {
      logger.log(`Successfully subscribed to ${topic}.`);
    } else {
      logger.error(`MQTT subscription failed: ${err.message}.`);
    }
  });
};

const publish = (topic: string, message: string, qos: QoS = 1) => {
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

export default { subscribe, publish };
