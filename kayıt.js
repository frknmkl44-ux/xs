<script type="module">
  // Import the functions you need from the SDKs you need
  import { initializeApp } from "https://www.gstatic.com/firebasejs/12.1.0/firebase-app.js";
  import { getAnalytics } from "https://www.gstatic.com/firebasejs/12.1.0/firebase-analytics.js";
  // TODO: Add SDKs for Firebase products that you want to use
  // https://firebase.google.com/docs/web/setup#available-libraries

  // Your web app's Firebase configuration
  // For Firebase JS SDK v7.20.0 and later, measurementId is optional
  const firebaseConfig = 
    apiKey: "AIzaSyBU9WJTICrspV3T_LORVf8z7hx3m1IavHI",
    authDomain: "kurye-1db2f.firebaseapp.com",
    projectId: "kurye-1db2f",
    storageBucket: "kurye-1db2f.firebasestorage.app",
    messagingSenderId: "742259280712",
    appId: "1:742259280712:web:64a5483db9adc509d7c17d",
    measurementId: "G-7YEZF6WHRG"
  ;

  // Initialize Firebase
  const app = initializeApp(firebaseConfig);
  const analytics = getAnalytics(app);
</script>
// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyBU9WJTICrspV3T_LORVf8z7hx3m1IavHI",
  authDomain: "kurye-1db2f.firebaseapp.com",
  projectId: "kurye-1db2f",
  storageBucket: "kurye-1db2f.firebasestorage.app",
  messagingSenderId: "742259280712",
  appId: "1:742259280712:web:64a5483db9adc509d7c17d",
  measurementId: "G-7YEZF6WHRG"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);

