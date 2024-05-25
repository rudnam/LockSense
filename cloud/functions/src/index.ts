import { onValueUpdated } from "firebase-functions/v2/database";
import { setGlobalOptions } from "firebase-functions/v2/options";

import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

import mqttService from "./services/mqtt";
import utils from "./utils";

setGlobalOptions({ region: "asia-southeast1" });
admin.initializeApp();

export const handleLockUpdate = onValueUpdated(
  { ref: "/locks/{lockId}/state" },
  async (event) => {
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

      if (!["unlocking", "locking"].includes(oldValue)) {
        mqttService.publish(
          `locks/${event.params.lockId}/state`,
          newValue.toString()
        );
      }
    }
  }
);
