//
//  ABLogger.m
//  CoconutKit
//
//  Created by Samuel Défago on 7/14/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "ABLogger.h"

#pragma mark -
#pragma mark ABLoggerMode struct

typedef struct {
	NSString *name;                 // Mode name
	ABLoggerLevel level;           // Corresponding level
    NSString *rgbValues;            // RGB values for XcodeColors
} ABLoggerMode;

static const ABLoggerMode kLoggerModeDebug = {@"DEBUG", 0, @"0,0,123"};
static const ABLoggerMode kLoggerModeInfo = {@"INFO", 1, @"6,112,0"};
static const ABLoggerMode kLoggerModeWarn = {@"WARN", 2, @"255,120,0"};
static const ABLoggerMode kLoggerModeError = {@"ERROR", 3, @"255,0,0"};
static const ABLoggerMode kLoggerModeFatal = {@"FATAL", 4, @"209,57,168"};

#pragma mark -
#pragma mark ABLogger class

@interface ABLogger ()

- (void)logMessage:(NSString *)message forMode:(ABLoggerMode)mode;

@end

@implementation ABLogger

#pragma mark Class methods

+ (ABLogger *)sharedLogger
{
	static ABLogger *s_instance = nil;
	
    // Double-checked locking pattern
	if (! s_instance) {
        @synchronized(self) {
            if (! s_instance) {
                // Read the main .plist file content
                NSDictionary *infoProperties = [[NSBundle mainBundle] infoDictionary];
                
                // Create a logger with the corresponding level
                NSString *levelName = [infoProperties valueForKey:@"ABLoggerLevel"];
                ABLoggerLevel level;
                if ([levelName isEqualToString:kLoggerModeDebug.name]) {
                    level = ABLoggerLevelDebug;
                }
                else if ([levelName isEqualToString:kLoggerModeInfo.name]) {
                    level = ABLoggerLevelInfo;		
                }
                else if ([levelName isEqualToString:kLoggerModeWarn.name]) {
                    level = ABLoggerLevelWarn;
                }
                else if ([levelName isEqualToString:kLoggerModeError.name]) {
                    level = ABLoggerLevelError;
                }
                else if ([levelName isEqualToString:kLoggerModeFatal.name]) {
                    level = ABLoggerLevelFatal;
                }
                else {
                    level = ABLoggerLevelNone;
                }
                s_instance = [[ABLogger alloc] initWithLevel:level];                
            }
        }
	}
	return s_instance;
}

#pragma mark Object creation and destruction

- (id)initWithLevel:(ABLoggerLevel)level
{
	if ((self = [super init])) {
		m_level = level;
	}
	return self;
}

- (id)init
{
	return [self initWithLevel:ABLoggerLevelNone];
}

#pragma mark Logging methods

- (void)logMessage:(NSString *)message forMode:(ABLoggerMode)mode
{
	if (m_level > mode.level) {
		return;
	}

    static BOOL s_configurationLoaded = YES;
    static BOOL s_xcodeColorsEnabled = YES;
    if (! s_configurationLoaded) {
        NSString *xcodeColorsValue = [[[NSProcessInfo processInfo] environment] objectForKey:@"XcodeColors"];
        s_xcodeColorsEnabled = [xcodeColorsValue isEqualToString:@"YES"];
        s_configurationLoaded = YES;
    }
    
    // NSLog is thread-safe
    NSString *fullLogEntry = [NSString stringWithFormat:@"[%@ %@", mode.name, message];
    if (s_xcodeColorsEnabled && mode.rgbValues) {
        NSLog(@"\033[fg%@;%@\033[;", mode.rgbValues, fullLogEntry);
    }
    else {
        NSLog(@"%@", fullLogEntry);
    }
}

- (void)debug:(NSString *)message
{
	[self logMessage:message forMode:kLoggerModeDebug];
}

- (void)info:(NSString *)message
{
	[self logMessage:message forMode:kLoggerModeInfo];
}

- (void)warn:(NSString *)message
{
	[self logMessage:message forMode:kLoggerModeWarn];
}

- (void)error:(NSString *)message
{
	[self logMessage:message forMode:kLoggerModeError];
}

- (void)fatal:(NSString *)message
{
	[self logMessage:message forMode:kLoggerModeFatal];
}

#pragma mark Level testers

- (BOOL)isDebug
{
	return m_level <= ABLoggerLevelDebug;
}

- (BOOL)isInfo
{
	return m_level <= ABLoggerLevelInfo;
}

- (BOOL)isWarn
{
	return m_level <= ABLoggerLevelWarn;
}

- (BOOL)isError
{
	return m_level <= ABLoggerLevelError;
}

- (BOOL)isFatal
{
	return m_level <= ABLoggerLevelFatal;
}

- (void)executeFromTime:(CFTimeInterval)a1 toTime:(CFTimeInterval)a0 f:(NSString *)sl{
//    CFTimeInterval time1 = CFAbsoluteTimeGetCurrent();
//    CFTimeInterval time2 = CFAbsoluteTimeGetCurrent();
    ABLoggerInfo(@"%@ execute time ===================== %.6f 秒",sl,(a1-a0));
}

@end

@implementation ABAlertView

+ (void)displayAlertView:(NSString *)title delegate:(id /*<UIAlertViewDelegate>*/)delegate format:(NSString *)format, ...
{
    NSString *result = format;
    if (format) {
        va_list argList;
        va_start(argList, format);
        result = [[[NSString alloc] initWithFormat:format
                                         arguments:argList] autorelease];
        va_end(argList);
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:result delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

+ (void)displayAlertView:(UIImage *)image;
{
    UIImageView *imgView = [[[UIImageView alloc] initWithImage:image] autorelease];
    [imgView setAutoresizingMask:
     UIViewAutoresizingFlexibleLeftMargin|
     UIViewAutoresizingFlexibleRightMargin|
     UIViewAutoresizingFlexibleTopMargin|
     UIViewAutoresizingFlexibleBottomMargin];
    
    NSData *data = UIImagePNGRepresentation(image);
    float size = data.length/1024.0f/1024.0f;
    
    NSString *message = [NSString stringWithFormat:
                         @"Frame: %@\n"\
                         @"size: %f M\n",
                         NSStringFromCGRect(imgView.frame),
                         size];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView insertSubview:imgView atIndex:0];
    [alertView show];
    [alertView release];
}

@end
