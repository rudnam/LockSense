export type NotificationType =
  | "unlocked"
  | "locked"
  | "error"
  | "warning"
  | "default";

export type LockStatus =
  | "unlocked"
  | "locked"
  | "unlocking"
  | "locking"
  | "vibrating";

export type LockCommand = "unlock" | "lock";
