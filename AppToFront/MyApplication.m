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


- (BOOL)isSandboxed
{
	OSStatus        err;
	SecCodeRef      me;
	CFDictionaryRef dynamicInfo;
	BOOL sandboxed = NO;

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
	
	return sandboxed;
}


@end
