import { onValueUpdated } from "firebase-functions/v2/database";
import { setGlobalOptions } from "firebase-functions/v2/options";

import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

import mqttService from "./services/mqtt";
import timerService from "./services/lockTimer";
import utils from "./utils";
import { LockCommand } from "./types";

const lockTimeout = 15; // Time (in seconds) to wait for locking/unlocking acknowledgement

setGlobalOptions({ region: "asia-southeast1" });
admin.initializeApp();

export const handleLockUpdate = onValueUpdated(
  { ref: "/locks/{lockId}/status" },
  async (event) => {
    const lockId = event.params.lockId;
    const snapshotBefore = event.data.before;
    const snapshotAfter = event.data.after;
    const oldValue: string = snapshotBefore.val();
    const newValue: string = snapshotAfter.val();

    if (
      !utils.isValidLockStatus(oldValue) ||
      !utils.isValidLockStatus(newValue)
    ) {
      logger.error(
        `Invalid lock status detected. oldValue: ${oldValue}, newValue: ${newValue}`
      );
      return;
    }

    const fromApp =
      (oldValue === "unlocked" && newValue === "locking") ||
      (oldValue === "locked" && newValue === "unlocking");

    if (oldValue !== newValue) {
      logger.log(
        `Detected lock status change for ${lockId}: ${oldValue} -> ${newValue}`
      );
      const lockData = (await utils.getDatabase(`/locks/${lockId}`)) as {
        [key: string]: unknown;
      };
      const lockName = lockData["name"] as string;
      const lockOwnerId = lockData["ownerId"] as string;
      const sharedUserIdsObj =
        lockData["sharedUserIds"] ?? ({} as { [key: string]: boolean });
      const sharedUserIds = Object.keys(sharedUserIdsObj);

      if (fromApp) {
        const command = newValue === "locking" ? "lock" : "unlock";
        mqttService.publish(`locks/${lockId}/command`, command);
      }

      const message = {
        title: `${lockName}'s status changed!`,
        body: `${lockName} is now ${newValue}`,
      };

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
            await utils.notifyUsers([lockOwnerId, ...sharedUserIds], message);
          }
          break;
        case "locked":
          clearTimer("lock", lockId);
          if (oldValue !== "unlocking") {
            await utils.notifyUsers([lockOwnerId, ...sharedUserIds], message);
          }
          break;
        default:
          logger.error(`Received undefined lock status: ${newValue}`);
      }
    }
  }
);

const startTimer = (command: LockCommand, lockId: string) => {
  const timer = setTimeout(async () => {
    logger.log(
      `${utils.capitalize(
        command
      )} confirmation not received in time for lock ${lockId}. Cancelling ${command} attempt.`
    );
    mqttService.publish(
      `locks/${lockId}/command`,
      command === "unlock" ? "lock" : "unlock"
    );
    mqttService.publish(
      `locks/${lockId}/status`,
      command === "unlock" ? "locked" : "unlocked"
    );
    timerService.remove(command, lockId);
  }, lockTimeout * 1000);
  logger.log(`Starting ${command} attempt for lock ${lockId}...`);
  timerService.set(command, lockId, timer);
};

const clearTimer = (command: LockCommand, lockId: string) => {
  if (timerService.has(command, lockId)) {
    logger.log(
      `${utils.capitalize(
        command
      )} confirmation received. Clearing timer for ${command}.`
    );
    clearTimeout(timerService.get(command, lockId));
    timerService.remove(command, lockId);
  }
};
