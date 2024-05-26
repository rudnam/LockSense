import * as mqtt from "mqtt";
import * as logger from "firebase-functions/logger";
import { defineString } from "firebase-functions/params";

type QoS = 0 | 1 | 2;

const mqttBrokerUrl = defineString("MQTT_BROKER_URL");
const mqttUsername = defineString("MQTT_USERNAME");
const mqttPassword = defineString("MQTT_PASSWORD");

const client = mqtt.connect(mqttBrokerUrl.value(), {
  username: mqttUsername.value(),
  password: mqttPassword.value(),
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
