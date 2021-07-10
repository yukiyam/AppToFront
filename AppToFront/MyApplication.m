//
//  MyApplication.m
//  
//
//  Created by Yuki on 2020/12/01.
//
//

#import "MyApplication.h"

@implementation MyApplication

- (instancetype)init
{
	self = [super init];
	if (self) {
		enabled = YES;
	}
	return self;
}

#pragma mark -

- (BOOL)isEnabled
{
	return enabled;
}

- (void)setEnabled: (BOOL)newEnabled
{
	enabled = newEnabled;
}


// assuming not sandboxed on systems < 10.7
- (BOOL)isSandboxed
{
	BOOL sandboxed = NO;
#if defined(MAC_OS_X_VERSION_10_7)
	OSStatus        err;
	SecCodeRef      me;
	CFDictionaryRef dynamicInfo;

	if (kSecCodeInfoEntitlementsDict == nil)	// requires 10.7
		return NO;
	
	err = SecCodeCopySelf(kSecCSDefaultFlags, &me);
	if (err == errSecSuccess) {
		err = SecCodeCopySigningInformation(me, (SecCSFlags) kSecCSDynamicInformation, &dynamicInfo);
		if (err == errSecSuccess) {
			CFDictionaryRef entitlementsDict;
#ifdef DEBUG
			NSLog(@"%@", dynamicInfo);
#endif
			if (CFDictionaryGetValueIfPresent(dynamicInfo, kSecCodeInfoEntitlementsDict, (const void **)&entitlementsDict)) {
				CFStringRef key = CFSTR("com.apple.security.app-sandbox");
				CFBooleanRef b = kCFBooleanFalse;
				sandboxed = CFDictionaryGetValueIfPresent(entitlementsDict, key, (const void **)&b) && CFBooleanGetValue(b);
			}
			CFRelease(dynamicInfo);
		}
		CFRelease(me);
	}
#endif
	
	return sandboxed;
}


@end
