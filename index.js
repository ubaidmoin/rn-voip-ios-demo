/**
 * @format
 */

import {AppRegistry, Platform} from 'react-native';
import App from './App';
import RNCallKeep from 'react-native-callkeep';
import VoipPushNotification from 'react-native-voip-push-notification';
import {name as appName} from './app.json';

const handleIncomingCall = async () => {};

const handleDecline = () => {};

const options = {
  ios: {
    appName: 'RN VoIP Demo',
  },
  android: {
    alertTitle: 'Permissions required',
    alertDescription: 'This application needs to access your phone accounts',
    cancelButton: 'Cancel',
    okButton: 'ok',
    imageName: 'phone_account_icon',
    // Required to get audio in background when using Android 11
    foregroundService: {
      channelId: 'com.example.rn-voip-demo',
      channelName: 'Foreground service for my app',
      notificationTitle: 'My app is running on background',
      notificationIcon: 'Path to the resource icon of the notification',
    },
  },
};

RNCallKeep.setup(options).then(accepted => {});

RNCallKeep.addEventListener('answerCall', async () => handleIncomingCall());
RNCallKeep.addEventListener('endCall', async () => handleDecline());

if (Platform.OS === 'ios') {
  VoipPushNotification.registerVoipToken();

  // Register event listener for VoIP push notifications
  VoipPushNotification.addEventListener('register', token => {
    // Save token for later use
    console.log('token', token);
  });

  VoipPushNotification.addEventListener('notification', notification => {
    // Handle incoming VoIP push notification
    handleIncomingCall();
  });

  VoipPushNotification.addEventListener('didLoadWithEvents', events => {
    console.log(events);
    if (!events || !Array.isArray(events) || events.length < 1) {
      return;
    }
    for (let voipPushEvent of events) {
      let {name, data} = voipPushEvent;
      if (
        name === VoipPushNotification.RNVoipPushRemoteNotificationReceivedEvent
      ) {
      }
    }
  });
}

const AppFake = () => {
  return null;
};

function HeadlessCheck({isHeadless}) {
  if (isHeadless) {
    return <AppFake />;
    /* Notice this component, it is not the App Component but a different one*/
  }

  return <App />;
}

AppRegistry.registerComponent(appName, () => HeadlessCheck);
