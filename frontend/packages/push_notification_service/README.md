# push_notificaton_service

A service for firebase push notifications:

Push notification service handles all the operations related to firebase push notifications.
This service checks for permissions to display the push notification. Token is required to send
the push notification from server so this also saves it, refreshes it and delete old token if
necessary in the databse. This service helps displaying the push notification in various states
of the application which are defined below.


## Firebase Console Configurations
Before using this service, Firebase cloud messaging should be setup in the conosle. Details can
be found from [here](https://firebase.flutter.dev/docs/messaging/notifications/)

## Permissions
- requestPermission: `Checks permissions for receving push notifications.`
- requestIOSPermissions: `Asks for platform specific permissions i.e iOS.`

## Working with Tokens
- getToken: `Get the token of the currently logged in user.`
- deleteToken: `Deletes the token of the user.`
- onTokenRefresh: `Listens to token and updates app about token change.`

## Receiving Push Notifications
- onMessage: `When app is running in foreground and FCM is received.`
- onMessageOpenedApp: `When app is running in background and FCM is recevied.`
- onTerminatedApp: `When app is in terminated state and FCM is received.`
