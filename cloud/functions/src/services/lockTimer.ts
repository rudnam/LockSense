import { LockCommand } from "../types";

const unlockTimers = new Map();
const lockTimers = new Map();

const get = (command: LockCommand, key: unknown) => {
  return command === "unlock" ? unlockTimers.get(key) : lockTimers.get(key);
};

const set = (command: LockCommand, key: unknown, value: unknown) => {
  return command === "unlock"
    ? unlockTimers.set(key, value)
    : lockTimers.set(key, value);
};

const remove = (command: LockCommand, key: unknown) => {
  return command === "unlock"
    ? unlockTimers.delete(key)
    : lockTimers.delete(key);
};

const has = (command: LockCommand, key: unknown) => {
  return command === "unlock" ? unlockTimers.has(key) : lockTimers.has(key);
};

export default {
  set,
  remove,
  has,
  get,
};
