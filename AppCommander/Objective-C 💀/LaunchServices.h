//
//  LaunchServicesPrivate.h
//  Santander
//
//  Created by Serena on 15/08/2022.
//

#ifndef LaunchServicesPrivate_h
#define LaunchServicesPrivate_h

#define UIKIT_AVAILABLE __has_include(<UIKit/UIKit.h>)

#if UIKIT_AVAILABLE
@import UIKit;
#elif __has_include(<AppKit/AppKit.h>)
@import AppKit;
#endif

NS_ASSUME_NONNULL_BEGIN

@interface LSApplicationProxy : NSObject
@property (readonly, nonatomic) NSString *applicationType;

@property (getter=isBetaApp, readonly, nonatomic) BOOL betaApp;
@property (getter=isDeletable, readonly, nonatomic) BOOL deletable;
@property (getter=isRestricted, readonly, nonatomic) BOOL restricted;
@property (getter=isContainerized, readonly, nonatomic) BOOL containerized;
@property (getter=isAdHocCodeSigned, readonly, nonatomic) BOOL adHocCodeSigned;
@property (getter=isAppStoreVendable, readonly, nonatomic) BOOL appStoreVendable;
@property (getter=isLaunchProhibited, readonly, nonatomic) BOOL launchProhibited;
@property (nonatomic, readonly) NSString *canonicalExecutablePath API_AVAILABLE(ios(10.3));

@property (nonatomic, readonly) NSString *applicationIdentifier;
@property (nonatomic, readonly) NSString *vendorName   API_AVAILABLE(ios(7.0));
@property (nonatomic, readonly) NSString *itemName     API_AVAILABLE(ios(7.1));
@property (nonatomic, readonly) NSDate *registeredDate API_AVAILABLE(ios(9.0));
@property (nonatomic, readonly) NSString *sourceAppIdentifier API_AVAILABLE(ios(8.2));


@property (nonatomic, readonly) NSArray <NSNumber *> *deviceFamily  API_AVAILABLE(ios(8.0));
@property (nonatomic, readonly) NSArray <NSString *> *activityTypes API_AVAILABLE(ios(10.0));

@property (readonly, nonatomic) NSSet <NSString *> *claimedURLSchemes;
@property (readonly, nonatomic) NSString *teamID;
@property (copy, nonatomic) NSString *sdkVersion;
@property (readonly, nonatomic) NSDictionary <NSString *, id> *entitlements;
@property (readonly, nonatomic) NSURL* _Nullable bundleContainerURL;

+ (LSApplicationProxy*)applicationProxyForIdentifier:(id)identifier;
- (NSString *)applicationIdentifier;
- (NSURL *)containerURL;
- (NSURL *)bundleURL;
- (NSString *)localizedName;
- (NSData *)iconDataForVariant:(id)variant;
- (NSData *)iconDataForVariant:(id)variant withOptions:(id)options;
@end


@interface LSApplicationWorkspace
+ (instancetype) defaultWorkspace;
- (NSArray <LSApplicationProxy *> *)allInstalledApplications;
- (NSArray <LSApplicationProxy *> *)allApplications;
- (BOOL)openApplicationWithBundleID:(NSString *)arg0 ;
- (BOOL)uninstallApplication:(NSString *)arg0 withOptions:(_Nullable id)arg1 error:(NSError **)arg2 usingBlock:(_Nullable id)arg3;
@end

#endif /* LaunchServicesPrivate_h */

NS_ASSUME_NONNULL_END
