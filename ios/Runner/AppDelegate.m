#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "FlutterLocalNotificationsPlugin.h"
#include "FlutterDownloaderPlugin.h"
@import UIKit;
@import Firebase;

@implementation AppDelegate

void registerPlugins(NSObject<FlutterPluginRegistry>* registry) {
    NSLog(@"Registry : %@" , [registry description]);
  if (![registry hasPlugin:@"FlutterDownloaderPlugin"]) {
     [FlutterDownloaderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterDownloaderPlugin"]];
  }else [GeneratedPluginRegistrant registerWithRegistry:registry];
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];

    if (@available(iOS 10.0, *)) {
       [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
    }
    

    [GeneratedPluginRegistrant registerWithRegistry:self];
    
    @try {
        [FlutterLocalNotificationsPlugin setPluginRegistrantCallback:registerPlugins];
    } @catch(NSException *theException) {
        NSLog(@"An exception occurred: %@", theException.name);
        NSLog(@"Here are some details: %@", theException.reason);
    }
    
    [FlutterDownloaderPlugin setPluginRegistrantCallback:registerPlugins];

    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];

}

@end
