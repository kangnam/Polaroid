const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
	response.send("Hello from Firebase!");
});

// exports.observeFollowing = functions.database.ref('/following/{uid}/{followingId}').onCreate(event => {



// 	var uid = event.params.uid;
// 	var followingId = event.params.followingId

// 	console.log('User: ' + uid + ' is following: ' + followingId);

// 	return admin.database().ref('/users/' + followingId).once('value', snapshot => {
// 		var userWeAreFollowing = snapshot.val();

// 		var payload = {
// 			notification: {
// 				title: 'You have a new follower',
// 				body: 'XYZ is now following you'
// 			},
// 			token: userWeAreFollowing.fcmToken
// 		};

// 		admin.messaging().send(payload)
//   			.then((response) => {
//     			console.log('Successfully sent message:', response);
//   			})
//   		.catch((error) => {
//     		console.log('Error sending message:', error);
//   		});

// 	})


// })

// exports.sendPushNotifications = functions.https.onRequest((request, response) => {
// 	response.send('Attempting to send push notifications...');

// 	var uid = 'AbbFITOphyMQICudXQ8dRvvYdfx1';

// 	return admin.database().ref('/users/' + uid).once('value', snapshot => {

// 		var user = snapshot.val();
// 		console.log('User username:' + user.username + ' User fcmToken:' + user.fcmToken);

// 		var payload = {
// 			notification: {
// 		    	title: 'notification title',
// 		    	body: 'notification body'
// 			},
// 			token: user.fcmToken
// 		};


// 		admin.messaging().send(payload)
//   			.then((response) => {
//     			console.log('Successfully sent message:', response);
//   			})
//   		.catch((error) => {
//     		console.log('Error sending message:', error);
//   		});
// 	})
// })