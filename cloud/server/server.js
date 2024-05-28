require("dotenv").config();
const mqtt = require("mqtt");
const axios = require("axios");
const getAccessToken = require("./googleAuth");

const client = mqtt.connect(process.env.MQTT_BROKER_URL, {
  username: process.env.MQTT_USERNAME,
  password: process.env.MQTT_PASSWORD,
});

client.on("connect", () => {
  console.log("Connected to MQTT broker");

  const statusTopic = "locks/+/status";
  client.subscribe(statusTopic, (err) => {
    if (err) {
      console.error("Failed to subscribe to topic:", err);
    }
  });
  console.log(`Successfully subscribed to ${statusTopic}.`);
});

client.on("message", async (topic, message) => {
  console.log(
    `Received an MQTT message. Topic is ${topic}. Message is ${message.toString()}`
  );

  const match = topic.match(/^locks\/([^/]+)\/status$/);
  if (match) {
    const lockId = match[1];
    const payload = message.toString();

    if (!isValidLockStatus(payload)) {
      console.error(`Invalid lock status detected. payload: ${payload}`);
      return;
    }

    const firebaseUrl = `${process.env.FIREBASE_BASE_URL}/locks/${lockId}/status.json`;
    const data = `"${payload}"`;

    try {
      const token = await getAccessToken();
      await axios.put(firebaseUrl, data, {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });
      console.log("Data updated successfully");
    } catch (error) {
      console.error("Error updating data:", error);
    }
  }
});

const isValidLockStatus = (str) => {
  return ["unlocked", "locked", "unlocking", "locking"].includes(str);
};
