//
//  MyApplication.h
//  
//
//  Created by Yuki on 2020/12/01.
//
//

#import <Cocoa/Cocoa.h>

@interface MyApplication : NSApplication
{
	BOOL enabled;
}

- (BOOL)isEnabled;
- (void)setEnabled: (BOOL)newEnabled;

- (BOOL)isSandboxed;

@end
