import { onValueUpdated } from "firebase-functions/v2/database";
import { setGlobalOptions } from "firebase-functions/v2/options";

import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

import mqttService from "./services/mqtt";
import timerService, { timerType } from "./services/timer";
import utils from "./utils";

const lockTimeout = 15; // Time (in seconds) to wait for locking/unlocking acknowledgement

setGlobalOptions({ region: "asia-southeast1" });
admin.initializeApp();

export const handleLockUpdate = onValueUpdated(
  { ref: "/locks/{lockId}/state" },
  async (event) => {
    const lockId = event.params.lockId;
    const snapshotBefore = event.data.before;
    const snapshotAfter = event.data.after;
    const oldValue: string = snapshotBefore.val();
    const newValue: string = snapshotAfter.val();
    const fromApp =
      (oldValue === "unlocked" && newValue === "locking") ||
      (oldValue === "locked" && newValue === "unlocking");

    if (oldValue !== newValue) {
      logger.log(
        `Detected lock state change for ${lockId}: ${oldValue} -> ${newValue}`
      );
      const lockData = (await utils.getDatabase(`/locks/${lockId}`)) as {
        [key: string]: unknown;
      };
      const lockName = lockData["name"] as string;
      const lockOwnerId = lockData["ownerId"] as string;

      if (fromApp) {
        mqttService.publish(`locks/${lockId}/state`, newValue.toString());
      }

      switch (newValue) {
        case "unlocking":
          startTimer("unlock", lockId);
          break;
        case "locking":
          startTimer("lock", lockId);
          break;
        case "unlocked":
          clearTimer("unlock", lockId);
          if (oldValue !== "locking") {
            await utils.sendNotification(lockOwnerId, {
              title: `${lockName}'s state changed!`,
              body: `${lockName} is now ${newValue}`,
            });
          }
          break;
        case "locked":
          clearTimer("lock", lockId);
          if (oldValue !== "unlocking") {
            await utils.sendNotification(lockOwnerId, {
              title: `${lockName}'s state changed!`,
              body: `${lockName} is now ${newValue}`,
            });
          }
          break;
        default:
          logger.error(`Received undefined lock state: ${newValue}`);
      }
    }
  }
);

const startTimer = (type: timerType, lockId: string) => {
  const timer = setTimeout(async () => {
    logger.log(
      `${utils.capitalize(
        type
      )} confirmation not received in time for lock ${lockId}. Cancelling ${type} attempt.`
    );
    mqttService.publish(
      `locks/${lockId}/state`,
      type === "unlock" ? "locked" : "unlocked"
    );
    timerService.remove(type, lockId);
  }, lockTimeout * 1000);
  logger.log(`Starting ${type} attempt for lock ${lockId}...`);
  timerService.set(type, lockId, timer);
};

const clearTimer = (type: timerType, lockId: string) => {
  if (timerService.has(type, lockId)) {
    logger.log(
      `${utils.capitalize(
        type
      )} confirmation received. Clearing timer for ${type}.`
    );
    clearTimeout(timerService.get(type, lockId));
    timerService.remove(type, lockId);
  }
};
