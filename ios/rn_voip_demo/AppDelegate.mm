#import "AppDelegate.h"
#import <Firebase.h>
#import <RNCallKeep/RNCallKeep.h>
#import <PushKit/PushKit.h>
#import <React/RCTBundleURLProvider.h>
#import "RNFBMessagingModule.h"
#import "RNVoipPushNotificationManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [FIRApp configure];
  [RNCallKeep setup:@{
    @"appName": @"RN VoIP Demo",
    @"maximumCallGroups": @3,
    @"maximumCallsPerCallGroup": @1,
    @"supportsVideo": @NO,
  }];


  self.moduleName = @"rn_voip_demo";
  // You can add your custom initial props in the dictionary below.
  // They will be passed down to the ViewController used by React Native.
  self.initialProps = @{};
    
  [RNVoipPushNotificationManager voipRegistration];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  [FIRMessaging messaging].APNSToken = deviceToken;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
  return [self bundleURL];
}

- (NSURL *)bundleURL
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
  return [RNCallKeep application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

#pragma mark - PushKit

/* Add PushKit delegate method */

// Handle updated push credentials
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type {
  // Register VoIP push token (a property of PKPushCredentials) with server
  [RNVoipPushNotificationManager didUpdatePushCredentials:credentials forType:(NSString *)type];
}

// Handle incoming pushes
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type {
  // Process the received push
  [RNVoipPushNotificationManager didReceiveIncomingPushWithPayload:payload forType:(NSString *)type];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion {
  NSString *uuid = [[[NSUUID UUID] UUIDString] lowercaseString];
  NSString *callerName = @"Caller Name";
  NSString *handle = @"Caller Handle";

  
  [RNVoipPushNotificationManager addCompletionHandler:uuid completionHandler:completion];
  [RNVoipPushNotificationManager didReceiveIncomingPushWithPayload:payload forType:(NSString *)type];
  
  [RNCallKeep reportNewIncomingCall: uuid
                             handle: handle
                         handleType: @"generic"
                           hasVideo: YES
                localizedCallerName: callerName
                    supportsHolding: YES
                       supportsDTMF: YES
                   supportsGrouping: YES
                 supportsUngrouping: YES
                        fromPushKit: YES
                            payload: nil
              withCompletionHandler: completion];
  
  completion();
}

@end
