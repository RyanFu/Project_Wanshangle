//
//  UncaughtExceptionHandler.m
//  UncaughtExceptions
//
//  Created by Matt Gallagher on 2010/05/25.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "WSLUncaughtExceptionHandler.h"
#import "SIAlertView.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

NSString * const WSLUncaughtExceptionHandlerSignalExceptionName = @"WSLUncaughtExceptionHandlerSignalExceptionName";
NSString * const WSLUncaughtExceptionHandlerSignalKey = @"WSLUncaughtExceptionHandlerSignalKey";
NSString * const WSLUncaughtExceptionHandlerAddressesKey = @"WSLUncaughtExceptionHandlerAddressesKey";

volatile int32_t WSLUncaughtExceptionCount = 0;
const int32_t WSLUncaughtExceptionMaximum = 10;

const NSInteger WSLUncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger WSLUncaughtExceptionHandlerReportAddressCount = 5;

@implementation WSLUncaughtExceptionHandler

+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (
         i = WSLUncaughtExceptionHandlerSkipAddressCount;
         i < WSLUncaughtExceptionHandlerSkipAddressCount +
         WSLUncaughtExceptionHandlerReportAddressCount;
         i++)
    {
	 	[backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
	if (anIndex == 0)
	{
        dismissed = YES;
	}
    
}

- (void)validateAndSaveCriticalApplicationData
{
	
}

- (void)handleException:(NSException *)exception
{
	[self validateAndSaveCriticalApplicationData];
	
//	UIAlertView *alert =
//    [[[UIAlertView alloc]
//      initWithTitle:NSLocalizedString(@"Unhandled exception", nil)
//      message:[NSString stringWithFormat:NSLocalizedString(
//                                                           @"You can try to continue but the application may be unstable.\n\n"
//                                                           @"Debug details follow:\n%@\n%@", nil),
//               [exception reason],
//               [[exception userInfo] objectForKey:WSLUncaughtExceptionHandlerAddressesKey]]
//      delegate:self
//      cancelButtonTitle:NSLocalizedString(@"Quit", nil)
//      otherButtonTitles:NSLocalizedString(@"Continue", nil), nil]
//     autorelease];
//	[alert show];
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"程序崩溃了"]
                                                     andMessage:[NSString stringWithFormat:NSLocalizedString(@"You can try to continue but the application may be unstable.\n\n"@"Debug details follow:\n%@\n%@", nil),
                                                                 [exception reason],
                                                                 [[exception userInfo] objectForKey:WSLUncaughtExceptionHandlerAddressesKey]]];
    [alertView addButtonWithTitle:@"退出"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              dismissed = YES;
                          }];
    [alertView addButtonWithTitle:@"继续"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    alertView.titleFont = [UIFont boldSystemFontOfSize:17];
    alertView.messageFont = [UIFont systemFontOfSize:12];
    
    [alertView show];
    [alertView release];
    
	
	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
	
	while (!dismissed)
	{
		for (NSString *mode in (NSArray *)allModes)
		{
			CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
		}
	}
	
	CFRelease(allModes);
    
	NSSetUncaughtExceptionHandler(NULL);
	signal(SIGABRT, SIG_DFL);
	signal(SIGILL, SIG_DFL);
	signal(SIGSEGV, SIG_DFL);
	signal(SIGFPE, SIG_DFL);
	signal(SIGBUS, SIG_DFL);
	signal(SIGPIPE, SIG_DFL);
	
	if ([[exception name] isEqual:WSLUncaughtExceptionHandlerSignalExceptionName])
	{
		kill(getpid(), [[[exception userInfo] objectForKey:WSLUncaughtExceptionHandlerSignalKey] intValue]);
	}
	else
	{
		[exception raise];
	}
}

@end

void HandleException(NSException *exception)
{
	int32_t exceptionCount = OSAtomicIncrement32(&WSLUncaughtExceptionCount);
	if (exceptionCount > WSLUncaughtExceptionMaximum)
	{
		return;
	}
	
	NSArray *callStack = [WSLUncaughtExceptionHandler backtrace];
	NSMutableDictionary *userInfo =
    [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
	[userInfo
     setObject:callStack
     forKey:WSLUncaughtExceptionHandlerAddressesKey];
	
	[[[[WSLUncaughtExceptionHandler alloc] init] autorelease]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException
      exceptionWithName:[exception name]
      reason:[exception reason]
      userInfo:userInfo]
     waitUntilDone:YES];
}

void SignalHandler(int signal)
{
	int32_t exceptionCount = OSAtomicIncrement32(&WSLUncaughtExceptionCount);
	if (exceptionCount > WSLUncaughtExceptionMaximum)
	{
		return;
	}
	
	NSMutableDictionary *userInfo =
    [NSMutableDictionary
     dictionaryWithObject:[NSNumber numberWithInt:signal]
     forKey:WSLUncaughtExceptionHandlerSignalKey];
    
	NSArray *callStack = [WSLUncaughtExceptionHandler backtrace];
	[userInfo
     setObject:callStack
     forKey:WSLUncaughtExceptionHandlerAddressesKey];
	
	[[[[WSLUncaughtExceptionHandler alloc] init] autorelease]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException
      exceptionWithName:WSLUncaughtExceptionHandlerSignalExceptionName
      reason:
      [NSString stringWithFormat:
       NSLocalizedString(@"Signal %d was raised.", nil),
       signal]
      userInfo:
      [NSDictionary
       dictionaryWithObject:[NSNumber numberWithInt:signal]
       forKey:WSLUncaughtExceptionHandlerSignalKey]]
     waitUntilDone:YES];
}

void InstallWSLUncaughtExceptionHandler()
{
	NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGQUIT, SignalHandler);
	signal(SIGILL, SignalHandler);
	signal(SIGTRAP, SignalHandler);
	signal(SIGABRT, SignalHandler);
	signal(SIGEMT, SignalHandler);
	signal(SIGFPE, SignalHandler);
	signal(SIGBUS, SignalHandler);
	signal(SIGSEGV, SignalHandler);
	signal(SIGSYS, SignalHandler);
	signal(SIGPIPE, SignalHandler);
	signal(SIGALRM, SignalHandler);
	signal(SIGXCPU, SignalHandler);
	signal(SIGXFSZ, SignalHandler);
    
    //	signal(SIGABRT, SignalHandler);
    //	signal(SIGILL, SignalHandler);
    //	signal(SIGSEGV, SignalHandler);
    //	signal(SIGFPE, SignalHandler);
    //	signal(SIGBUS, SignalHandler);
    //	signal(SIGPIPE, SignalHandler);
}

