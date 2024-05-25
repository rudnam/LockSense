import { onValueUpdated } from "firebase-functions/v2/database";
import { setGlobalOptions } from "firebase-functions/v2/options";

import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

import mqttService from "./services/mqtt";
import timerService from "./services/timer";
import utils from "./utils";

const lockTimeout = 30; // Time (in seconds) to wait for locking/unlocking acknowledgement

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

    if (oldValue !== newValue) {
      logger.log("Detected lock state change:", oldValue, "->", newValue);
      await utils.sendNotification({
        title: "The Lock state changed!",
        body: `The Lock's state is now ${newValue}`,
      });

      // Only publish if change came from the app
      if (
        (oldValue === "unlocked" && newValue === "locking") ||
        (oldValue === "locked" && newValue === "unlocking")
      ) {
        mqttService.publish(`locks/${lockId}/state`, newValue.toString());
      }

      switch (newValue) {
        case "unlocking":
          {
            const timer = setTimeout(async () => {
              logger.log(
                `Unlock confirmation not received for lock ${lockId}. Reverting to locked state.`
              );
              mqttService.publish(`locks/${lockId}/state`, "locked");
              timerService.remove("unlock", lockId);
            }, lockTimeout * 1000);
            logger.log("Starting timer for unlocked state...");
            timerService.set("unlock", lockId, timer);
          }
          break;
        case "locking":
          {
            const timer = setTimeout(async () => {
              logger.log(
                `Lock confirmation not received for lock ${lockId}. Reverting to unlocked state.`
              );
              mqttService.publish(`locks/${lockId}/state`, "unlocked");
              timerService.remove("lock", lockId);
            }, lockTimeout * 1000);
            logger.log("Starting timer for locked state...");
            timerService.set("lock", lockId, timer);
          }
          break;
        case "unlocked":
          {
            if (timerService.has("unlock", lockId)) {
              logger.log("Clearing timer for unlocked state");
              clearTimeout(timerService.get("unlock", lockId));
              timerService.remove("unlock", lockId);
            }
          }
          break;
        case "locked":
          {
            if (timerService.has("lock", lockId)) {
              logger.log("Clearing timer for locked state");
              clearTimeout(timerService.get("lock", lockId));
              timerService.remove("lock", lockId);
            }
          }
          break;
        default:
          logger.error(`Received undefined lock state: ${newValue}`);
      }
    }
  }
);
