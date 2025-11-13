const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { getFirestore } = require('firebase-admin/firestore');

const firestore = getFirestore();
const NOTIFICATIONS_COLLECTION = 'Notifications';
const PRESCRIPTIONS_COLLECTION = 'Prescriptions';

/**
 * Cloud Function that triggers when a prescription is updated
 * Creates a notification when prescription status changes to 'verified'
 */
exports.onPrescriptionVerified = onDocumentUpdated(
    `${PRESCRIPTIONS_COLLECTION}/{prescriptionId}`,
    async (event) => {
        try {
            const beforeData = event.data.before.data();
            const afterData = event.data.after.data();
            const prescriptionId = event.params.prescriptionId;

            // Check if status changed to 'verified'
            const wasVerified = beforeData.status === 'verified';
            const isNowVerified = afterData.status === 'verified';

            // Only trigger if status just changed to verified
            if (wasVerified || !isNowVerified) {
                console.log('Prescription not newly verified, skipping notification');
                return null;
            }

            console.log(`📋 Prescription ${prescriptionId} was verified, creating notification...`);

            // Get prescription details
            const userId = afterData.userId;
            const patientName = afterData.patientName || 'Patient';
            const source = afterData.source || 'mobile'; // Default to mobile if not set

            if (!userId) {
                console.error('No userId found in prescription data');
                return null;
            }

            // Create notification message based on source
            let notificationTitle = '✅ Prescription Verified';
            let notificationBody = '';

            if (source === 'website') {
                notificationBody = `Your prescription for ${patientName} has been verified and is available. To place an order, please download our mobile app from Google Play Store.`;
            } else {
                notificationBody = `Your prescription for ${patientName} has been verified and the products are now available. You can now proceed with your order.`;
            }

            // Create notification document
            const notificationData = {
                title: notificationTitle,
                body: notificationBody,
                senderId: 'admin',
                recipientIds: [userId],
                type: 'prescription_verified',
                createdAt: firestore.FieldValue.serverTimestamp(),
                seenBy: {},
                route: '/prescriptions',
                routeId: prescriptionId,
                isBroadcast: false,
                isSent: false
            };

            // Add notification to Firestore
            const notificationRef = await firestore
                .collection(NOTIFICATIONS_COLLECTION)
                .add(notificationData);

            console.log(`✅ Notification created: ${notificationRef.id} for user ${userId}`);
            console.log(`📱 Source: ${source} | Message: "${notificationBody}"`);

            return { success: true, notificationId: notificationRef.id };

        } catch (error) {
            console.error('❌ Error in onPrescriptionVerified:', error);
            // Don't throw error to avoid retries
            return { success: false, error: error.message };
        }
    }
);
