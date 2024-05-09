import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getDatabase, ref, onValue, set } from "firebase/database";

const firebaseConfig = {
  apiKey: "AIzaSyDeKlhdHIejMWg6XfevnuiLfdIULbSd_7A",
  authDomain: "locksense-c23a8.firebaseapp.com",
  databaseURL:
    "https://locksense-c23a8-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "locksense-c23a8",
  storageBucket: "locksense-c23a8.appspot.com",
  messagingSenderId: "903369669754",
  appId: "1:903369669754:web:56f2bf16f36cc053b24fc3",
  measurementId: "G-59LX25PBD7",
};

const app = initializeApp(firebaseConfig);
const _analytics = getAnalytics(app);
const db = getDatabase(app);

const addListener = (path: string, callback: (data: any) => void) => {
  const pathRef = ref(db, path);
  onValue(pathRef, (snapshot) => {
    const data = snapshot.val();
    callback(data);
  });
};

const writeData = (path: string, newData: any) => {
  const pathRef = ref(db, path);
  set(pathRef, newData);
};

const firebaseService = {
  addListener,
  writeData,
};

export default firebaseService;
