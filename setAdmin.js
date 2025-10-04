const admin = require("firebase-admin");
const serviceAccount = require("./lib/presentation/admin/serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

//this is where you put the uid of the user you want to make an admin.
const uid = "hnFGuYNx3ANH240II4msi53KTg12";

async function setAdmin() {
  try {
    await admin.auth().setCustomUserClaims(uid, { admin: true });
    console.log(`User ${uid} is now an admin.`);
  } catch (error) {
    console.error("Error setting admin claim:", error);
  }
}

setAdmin();