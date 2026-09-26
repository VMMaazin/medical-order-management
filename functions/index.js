const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Cloud Function to create a Medical Representative account securely.
 * Executed server-side via Firebase Admin SDK so the logged-in admin's
 * client session is never altered or replaced.
 */
exports.createMedicalRep = onCall(async (request) => {
  // 1. Verify caller is authenticated
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Authentication required. Please sign in as an administrator."
    );
  }

  const callerUid = request.auth.uid;
  const db = admin.firestore();

  // 2. Verify caller is an active administrator in Firestore
  const callerDoc = await db.collection("users").doc(callerUid).get();
  if (!callerDoc.exists) {
    throw new HttpsError(
      "permission-denied",
      "Caller user profile not found in system."
    );
  }

  const callerData = callerDoc.data();
  if (callerData.role !== "admin" || callerData.active !== true) {
    throw new HttpsError(
      "permission-denied",
      "Access denied. Only active administrators can provision medical representatives."
    );
  }

  // 3. Extract and validate input data
  const data = request.data || {};
  const name = typeof data.name === "string" ? data.name.trim() : "";
  const email = typeof data.email === "string" ? data.email.trim().toLowerCase() : "";
  const phone = typeof data.phone === "string" ? data.phone.trim() : "";
  const password = typeof data.password === "string" ? data.password : "";

  if (!name) {
    throw new HttpsError("invalid-argument", "Representative full name is required.");
  }

  const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  if (!email || !emailRegex.test(email)) {
    throw new HttpsError("invalid-argument", "A valid email address is required.");
  }

  // Indian phone validation (10 digits, optional country code)
  const cleanedPhone = phone.replace(/[\s\-()]/g, "");
  const phoneRegex = /^(?:(?:\+?91)|0)?[6-9]\d{9}$/;
  if (!phone || !phoneRegex.test(cleanedPhone)) {
    throw new HttpsError(
      "invalid-argument",
      "A valid 10-digit Indian phone number is required."
    );
  }

  if (!password || password.length < 8) {
    throw new HttpsError(
      "invalid-argument",
      "Temporary password must be at least 8 characters long."
    );
  }

  // 4. Create Firebase Authentication account via Admin SDK
  let userRecord;
  try {
    userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: name,
    });
  } catch (authErr) {
    console.error("Auth creation error:", authErr);
    if (authErr.code === "auth/email-already-exists") {
      throw new HttpsError(
        "already-exists",
        "An account with this email address already exists."
      );
    }
    if (authErr.code === "auth/invalid-password") {
      throw new HttpsError(
        "invalid-argument",
        "The temporary password does not meet security requirements."
      );
    }
    throw new HttpsError(
      "internal",
      authErr.message || "Failed to create authentication account."
    );
  }

  const newUid = userRecord.uid;

  // 5. Create users/{UID} profile document in Firestore
  try {
    await db.collection("users").doc(newUid).set({
      name: name,
      email: email,
      phone: phone,
      role: "medical_rep",
      active: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (firestoreErr) {
    console.error("Firestore creation error, rolling back auth user:", firestoreErr);
    // Rollback: delete the newly created Auth user to avoid orphaned unlinked state
    try {
      await admin.auth().deleteUser(newUid);
    } catch (cleanupErr) {
      console.error("Rollback failed for auth UID:", newUid, cleanupErr);
    }

    throw new HttpsError(
      "internal",
      "Failed to create representative profile in database. The authentication account has been rolled back."
    );
  }

  // 6. Return success response to Flutter admin client
  return {
    success: true,
    uid: newUid,
    message: "Medical representative account provisioned successfully.",
  };
});
