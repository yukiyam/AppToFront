//
//  AppDelegate.m
//  AppToFront
//
//  Created by Yuki on 1/12/2020.
//

#import "AppDelegate.h"
#import "MyApplication.h"

#import <AvailabilityMacros.h>

static OSStatus HandleAppSwitchEvent(EventHandlerRef caller, EventRef event, void *userData);
static OSErr SendActivateToPID(pid_t pid);
static OSErr SendActivateToPSN(const ProcessSerialNumber *psn);
static Boolean ShouldFire(void);

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// NSWorkspaceDidActivateApplicationNotification is available from 10.6
#ifndef __LP64__
	EventTypeSpec eventTypes[] = {
		{ kEventClassApplication,  kEventAppFrontSwitched },
	};
	OSStatus st;
	st = InstallApplicationEventHandler(NewEventHandlerUPP(HandleAppSwitchEvent), 1, eventTypes, (void*)self, NULL);
#elif defined(MAC_OS_X_VERSION_10_6)
	if (NSWorkspaceDidActivateApplicationNotification)
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(gotActivateNotification:) name: NSWorkspaceDidActivateApplicationNotification object: nil];
	else {
		NSRunCriticalAlertPanel(@"This application does not function in 64-bit mode on this system.", @"Open Get Info panel in Finder and turn on 'Open in 32-bit mode'.", @"Quit", nil, nil);
		[NSApp terminate: self];
	}
#else
#error "64-bit build requires Mac OS X SDK > 10.6."
#endif
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver: self];
}


#if defined(MAC_OS_X_VERSION_10_6)
- (void)gotActivateNotification: (NSNotification *)notification
{
	if (ShouldFire()) {
		NSDictionary *userInfo = [notification userInfo];
		NSRunningApplication *app = [userInfo objectForKey: NSWorkspaceApplicationKey];
		if ([NSApp isSandboxed]) {
			[app activateWithOptions: NSApplicationActivateAllWindows + NSApplicationActivateIgnoringOtherApps];
		}
		else {
			//SendActivateToPID([app processIdentifier]);
			[app activateWithOptions: NSApplicationActivateAllWindows + NSApplicationActivateIgnoringOtherApps];
		}
	}
}
#endif

@end


static OSStatus HandleAppSwitchEvent(EventHandlerRef caller, EventRef event, void *userData)
{
	OSStatus st = noErr;
#ifndef __LP64__
	ProcessSerialNumber psn;
	EventParamType outType;
	ByteCount outSize;
	
	if (ShouldFire()) {
		st = GetEventParameter(event, kEventParamProcessID, typeProcessSerialNumber, &outType, sizeof(psn), &outSize, &psn);
		if (st == noErr) {
			SendActivateToPSN(&psn);
		}
	}
#endif
	return st;
}


static Boolean ShiftKeyDown(void)
{
	if ([NSEvent respondsToSelector: @selector(modifierFlags)])
		return ([NSEvent modifierFlags] & NSShiftKeyMask) != 0;
	else
		return (GetCurrentKeyModifiers() & shiftKey) != 0;
}

static Boolean OptionKeyDown(void)
{
	if ([NSEvent respondsToSelector: @selector(modifierFlags)])
		return ([NSEvent modifierFlags] & NSAlternateKeyMask) != 0;
	else
		return (GetCurrentKeyModifiers() & optionKey) != 0;
}

static Boolean ShouldFire(void)
{
	return [NSApp isEnabled] && ! ShiftKeyDown();
}


static OSErr SendActivate(const AEAddressDesc *target)
{
	AppleEvent ae;
	AppleEvent reply;
	OSErr err, err2;
	// tell app "xxx" to activate
	err = AECreateAppleEvent(kAEMiscStandards, kAEActivate, target, kAutoGenerateReturnID, kAnyTransactionID, &ae);
	if (err == noErr) {
#if 0
		err = AESendMessage(&ae, &reply, kAEWaitReply, 30);
		if (err == noErr) {
			Handle h;
			err2 = AEPrintDescToHandle(&reply, &h);
			if (err2 == noErr) {
				NSString *s = [[NSString alloc] initWithBytes: *h length: GetHandleSize(h) encoding: NSMacOSRomanStringEncoding];
				NSLog(@"%@", s);
                [s release];
			}
			DisposeHandle(h);
		}
#else
		err = AESendMessage(&ae, &reply, kAENoReply, kAEDefaultTimeout);
#endif
		err2 = AEDisposeDesc(&reply);
		err2 = AEDisposeDesc(&ae);
	}
	return err;
}

static OSErr SendActivateToPID(pid_t pid)
{
	OSErr err, err2;
	AEDesc target;
	err = AECreateDesc(typeKernelProcessID, &pid, sizeof(pid), &target);
	if (err == noErr) {
		err = SendActivate(&target);
		err2 = AEDisposeDesc(&target);
	}
	return err;
}

static OSErr SendActivateToPSN(const ProcessSerialNumber *psn)
{
	OSErr err, err2;
	AEDesc target;
	err = AECreateDesc(typeProcessSerialNumber, psn, sizeof(ProcessSerialNumber), &target);
	if (err == noErr) {
		err = SendActivate(&target);
		err2 = AEDisposeDesc(&target);
	}
	return err;
}
