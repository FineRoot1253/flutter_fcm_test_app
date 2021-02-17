#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#include "FlutterDownloaderPlugin.h"
@import UIKit;
@import Firebase;

@implementation AppDelegate

void registerPlugins(NSObject<FlutterPluginRegistry>* registry) {
  if (![registry hasPlugin:@"FlutterDownloaderPlugin"]) {
     [FlutterDownloaderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterDownloaderPlugin"]];
  }
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];

    if (@available(iOS 10.0, *)) {
       [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
    }

    [GeneratedPluginRegistrant registerWithRegistry:self];
    
    [FlutterDownloaderPlugin setPluginRegistrantCallback:registerPlugins];

    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
;
}

@end
