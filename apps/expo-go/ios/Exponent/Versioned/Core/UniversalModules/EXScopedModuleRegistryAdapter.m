// Copyright © 2018 650 Industries. All rights reserved.

#import "EXScopedModuleRegistry.h"

#import "EXScopedModuleRegistryAdapter.h"
#import "EXSensorsManagerBinding.h"
#import "EXConstantsBinding.h"
#import "EXUnversioned.h"
#import "EXScopedFontLoader.h"
#import "EXScopedSecureStore.h"
#import "EXScopedPermissions.h"
#import "EXScopedLocalAuthentication.h"
#import "EXScopedErrorRecoveryModule.h"

#import "EXScopedReactNativeAdapter.h"
#import "EXExpoUserNotificationCenterProxy.h"
/*
#import "EXScopedNotificationsEmitter.h"
#import "EXScopedNotificationsHandlerModule.h"
#import "EXScopedNotificationBuilder.h"
#import "EXScopedNotificationSchedulerModule.h"
#import "EXScopedNotificationPresentationModule.h"
#import "EXScopedNotificationCategoriesModule.h"
 */
#import "EXScopedServerRegistrationModule.h"

#if __has_include(<EXTaskManager/EXTaskManager.h>)
#import <EXTaskManager/EXTaskManager.h>
#endif

#import <ExpoModulesCore-Swift.h>

@implementation EXScopedModuleRegistryAdapter

- (EXModuleRegistry *)moduleRegistryForParams:(NSDictionary *)params
                  forExperienceStableLegacyId:(NSString *)experienceStableLegacyId
                                     scopeKey:(NSString *)scopeKey
                                     manifest:(EXManifestsManifest *)manifest
                           withKernelServices:(NSDictionary *)kernelServices
{
  EXModuleRegistry *moduleRegistry = [self.moduleRegistryProvider moduleRegistry];

#if __has_include(<EXConstants/EXConstantsService.h>)
  EXConstantsBinding *constantsBinding = [[EXConstantsBinding alloc] initWithParams:params];
  [moduleRegistry registerInternalModule:constantsBinding];
#endif

if (params[@"fileSystemDirectories"]) {
  // Override the FileSystem module with custom document and cache directories
  NSString *documentDirectory = params[@"fileSystemDirectories"][@"documentDirectory"];
  NSString *cachesDirectory = params[@"fileSystemDirectories"][@"cachesDirectory"];
  NSString *applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject;
  EXFileSystemLegacyUtilities *fileSystemModule = [[EXFileSystemLegacyUtilities alloc] initWithDocumentDirectory:documentDirectory cachesDirectory:cachesDirectory applicationSupportDirectory:applicationSupportDirectory];
  
  [moduleRegistry registerInternalModule:fileSystemModule];
}

  EXScopedReactNativeAdapter *reactNativeAdapter = [[EXScopedReactNativeAdapter alloc] init];
  [moduleRegistry registerInternalModule:reactNativeAdapter];

  EXExpoUserNotificationCenterProxy *userNotificationCenter = [[EXExpoUserNotificationCenterProxy alloc] initWithUserNotificationCenter:kernelServices[EX_UNVERSIONED(@"EXUserNotificationCenter")]];
  [moduleRegistry registerInternalModule:userNotificationCenter];

#if __has_include(<ExpoModulesCore/EXPermissionsService.h>)
  EXScopedPermissions *permissionsModule = [[EXScopedPermissions alloc] initWithScopeKey:scopeKey andConstantsBinding:constantsBinding];
  [moduleRegistry registerExportedModule:permissionsModule];
  [moduleRegistry registerInternalModule:permissionsModule];
#endif

#if __has_include(<EXTaskManager/EXTaskManager.h>)
  // TODO: Make scoped task manager when adding support for bare React Native
  EXTaskManager *taskManagerModule = [[EXTaskManager alloc] initWithScopeKey:scopeKey];
  [moduleRegistry registerInternalModule:taskManagerModule];
  [moduleRegistry registerExportedModule:taskManagerModule];
#endif

  // TODO: rework the new Swift Notification code for ExpoGo

/*
#if __has_include(<EXNotifications/EXNotificationsEmitter.h>)
  EXScopedNotificationsEmitter *notificationsEmmitter = [[EXScopedNotificationsEmitter alloc] initWithScopeKey:scopeKey];
  [moduleRegistry registerExportedModule:notificationsEmmitter];
#endif

#if __has_include(<EXNotifications/EXNotificationsHandlerModule.h>)
  EXScopedNotificationsHandlerModule *notificationsHandler = [[EXScopedNotificationsHandlerModule alloc] initWithScopeKey:scopeKey];
  [moduleRegistry registerExportedModule:notificationsHandler];
#endif

#if __has_include(<EXNotifications/EXNotificationsHandlerModule.h>)
  EXScopedNotificationBuilder *notificationsBuilder = [[EXScopedNotificationBuilder alloc] initWithScopeKey:scopeKey
                                                                                                  andConstantsBinding:constantsBinding];
  [moduleRegistry registerInternalModule:notificationsBuilder];
#endif

#if __has_include(<EXNotifications/EXNotificationSchedulerModule.h>)
  EXScopedNotificationSchedulerModule *schedulerModule = [[EXScopedNotificationSchedulerModule alloc] initWithScopeKey:scopeKey];
  [moduleRegistry registerExportedModule:schedulerModule];
#endif

#if __has_include(<EXNotifications/EXNotificationPresentationModule.h>)
  EXScopedNotificationPresentationModule *notificationPresentationModule = [[EXScopedNotificationPresentationModule alloc] initWithScopeKey:scopeKey];
  [moduleRegistry registerExportedModule:notificationPresentationModule];
#endif

#if __has_include(<EXNotifications/EXNotificationCategoriesModule.h>)
  EXScopedNotificationCategoriesModule *scopedCategoriesModule = [[EXScopedNotificationCategoriesModule alloc] initWithScopeKey:scopeKey];
  [moduleRegistry registerExportedModule:scopedCategoriesModule];
  [EXScopedNotificationCategoriesModule maybeMigrateLegacyCategoryIdentifiersForProjectWithExperienceStableLegacyId:experienceStableLegacyId
                                                                                                           scopeKey:scopeKey];
#endif
 */

#if __has_include(<EXNotifications/EXServerRegistrationModule.h>)
  EXScopedServerRegistrationModule *serverRegistrationModule = [[EXScopedServerRegistrationModule alloc] initWithScopeKey:scopeKey];
  [moduleRegistry registerExportedModule:serverRegistrationModule];
#endif

  return moduleRegistry;
}

@end
