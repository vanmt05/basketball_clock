//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<connectivity_plus/FLTConnectivityPlusPlugin.h>)
#import <connectivity_plus/FLTConnectivityPlusPlugin.h>
#else
@import connectivity_plus;
#endif

#if __has_include(<network_info_plus/FLTNetworkInfoPlusPlugin.h>)
#import <network_info_plus/FLTNetworkInfoPlusPlugin.h>
#else
@import network_info_plus;
#endif

#if __has_include(<wakelock/WakelockPlugin.h>)
#import <wakelock/WakelockPlugin.h>
#else
@import wakelock;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FLTConnectivityPlusPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTConnectivityPlusPlugin"]];
  [FLTNetworkInfoPlusPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTNetworkInfoPlusPlugin"]];
  [WakelockPlugin registerWithRegistrar:[registry registrarForPlugin:@"WakelockPlugin"]];
}

@end
