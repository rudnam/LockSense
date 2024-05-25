const unlockTimers = new Map();
const lockTimers = new Map();

type timerType = "lock" | "unlock";

const get = (type: timerType, key: unknown) => {
  return type === "unlock" ? unlockTimers.get(key) : lockTimers.get(key);
};

const set = (type: timerType, key: unknown, value: unknown) => {
  return type === "unlock"
    ? unlockTimers.set(key, value)
    : lockTimers.set(key, value);
};

const remove = (type: timerType, key: unknown) => {
  return type === "unlock" ? unlockTimers.delete(key) : lockTimers.delete(key);
};

const has = (type: timerType, key: unknown) => {
  return type === "unlock" ? unlockTimers.has(key) : lockTimers.has(key);
};

export default {
  set,
  remove,
  has,
  get,
};
