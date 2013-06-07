//
//  ABLogger.h
//  CoconutKit
//
//  Created by Samuel Défago on 7/14/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Logging macros. Only active if AB_LOGGER is added to your configuration preprocessor flags (-DAB_LOGGER)
 */
#ifdef AB_LOGGER

#define XCODE_COLORS_ESCAPE_MAC @"\033["
#define XCODE_COLORS_ESCAPE_IOS @"\033["

#if TARGET_OS_IPHONE
#define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_IOS
#else
#define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_MAC
#endif

#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color

//运行时间
#define Elapsed_Time CFAbsoluteTimeGetCurrent()
#define ElapsedTime(time2,time1) ABLoggerInfo(@"elapsed time = %0.6fs",time2-time1)


// Note the ## in front of __VA_ARGS__ to support 0 variable arguments
#define ABLoggerDebug(format, ...)	[[ABLogger sharedLogger] debug:[NSString stringWithFormat:@"- Line:%d] %s - %@",__LINE__, __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]]]
#define ABLoggerInfo(format, ...)	[[ABLogger sharedLogger] info:[NSString stringWithFormat:@"- Line:%d] %s - %@",__LINE__, __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]]]
#define ABLoggerWarn(format, ...)	[[ABLogger sharedLogger] warn:[NSString stringWithFormat:@"- Line:%d] %s - %@",__LINE__, __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]]]
#define ABLoggerError(format, ...)	[[ABLogger sharedLogger] error:[NSString stringWithFormat:@"- Line:%d] %s - %@",__LINE__, __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]]]
#define ABLoggerFatal(format, ...)	[[ABLogger sharedLogger] fatal:[NSString stringWithFormat:@"- Line:%d] %s - %@",__LINE__, __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]]]

#define ABLoggerAlert(format, ...) { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#define ABLoggerMethod() ABLoggerInfo(@"%s",[ [ [ [NSString alloc] initWithBytes:__FILE__ length:strlen(__FILE__) encoding:NSUTF8StringEncoding] lastPathComponent] UTF8String ]);
#define ABLoggerSeparatorBold() NSLog(XCODE_COLORS_ESCAPE @"fg255,120,0;" XCODE_COLORS_ESCAPE @"bg255,190,0;"@"────────────────────────────────────────────────────────────────────────────" XCODE_COLORS_RESET);
#define ABLoggerSeparator()  NSLog(XCODE_COLORS_ESCAPE @"fg255,120,0;" @"────────────────────────────────────────────────────────────────────────────" XCODE_COLORS_RESET);

/***************************--Debug Specific Types--***************************************/
#define ABLogger_object( arg ) ABLoggerInfo( @"Object: %@", arg );
#define ABLogger_int( arg ) ABLoggerInfo( @"integer: %i", arg );
#define ABLogger_float( arg ) ABLoggerInfo( @"float: %f", arg );
#define ABLogger_rect( arg ) ABLoggerInfo( @"CGRect ( %f, %f, %f, %f)", arg.origin.x, arg.origin.y, arg.size.width, arg.size.height );
#define ABLogger_point( arg ) ABLoggerInfo( @"CGPoint ( %f, %f )", arg.x, arg.y );
#define ABLogger_size( arg ) ABLoggerInfo( @"CGSize ( %f, %f )", arg.width, arg.height );
#define ABLogger_bool( arg )   ABLoggerInfo( @"Boolean: %@", ( arg == YES ? @"YES" : @"NO" ) );
#define ABLogger_retainCount( arg ) ABLoggerInfo( @"retainCount: %d",[arg retainCount]);
    
#else

//运行时间
#define Elapsed_Time
#define ElapsedTime(time2,time1)

#define ABLoggerDebug(format, ...)
#define ABLoggerInfo(format, ...)
#define ABLoggerWarn(format, ...)
#define ABLoggerError(format, ...)
#define ABLoggerFatal(format, ...)
#define ABLoggerAlert(format, ...)

#define ABLoggerMethod() 
#define ABLoggerSeparator() 
#define ABLoggerSeparatorBold()

/***************************--Debug Specific Types--***************************************/
#define ABLogger_object( arg ) 
#define ABLogger_int( arg ) 
#define ABLogger_float( arg ) 
#define ABLogger_rect( arg ) 
#define ABLogger_point( arg ) 
#define ABLogger_size( arg ) 
#define ABLogger_bool( arg )

#endif

/**
 * Logging levels
 */
typedef enum {
	ABLoggerLevelEnumBegin = 0,
	// Values
	ABLoggerLevelAll = ABLoggerLevelEnumBegin,
	ABLoggerLevelDebug = ABLoggerLevelAll,
	ABLoggerLevelInfo,
	ABLoggerLevelWarn,
	ABLoggerLevelError,
	ABLoggerLevelFatal,
	ABLoggerLevelNone,
	// End of values
	ABLoggerLevelEnumEnd = ABLoggerLevelNone,
    ABLoggerLevelEnumSize = ABLoggerLevelEnumEnd - ABLoggerLevelEnumBegin
} ABLoggerLevel;

/**
 * Basic logging facility writing to the console. Thread-safe
 *
 * To enable logging, you can use either the release or debug version of this library, the logging code exists in both
 * (the linker ensures that you do not pay for it if your do not actually use it). To add logging to your project,
 * use the logging macros above. Those will strip off the logging code for your release builds. Debug builds with
 * logging enabled must be configured as follows:
 *   - in your project target settings, add -DAB_LOGGER to the "Other C flags" parameter. This disables logging code
 *     stripping
 *   - add an ABLoggerLevel setting to your project main .plist file, with one of the following values (DEBUG, INFO,
 *     WARN, ERROR or FATAL). This sets the logging level to apply
 *
 * ABLogger supports XcodeColors (see https://github.com/robbiehanson/XcodeColors for the active fork), an Xcode plugin
 * adding colors to the Xcode debugging console. Simply install the plugin and set an environment variable called 
 * 'XcodeColors' to YES to enable it for your project.
 *
 * Designated initializer: -initWithLevel:
 */

@interface ABLogger : NSObject {
@private
	ABLoggerLevel m_level;
}

/**
 * Singleton instance fetcher
 */
+ (ABLogger *)sharedLogger;

- (id)initWithLevel:(ABLoggerLevel)level;

/**
 * Logging functions; should never be called directly, use the macros instead
 */
- (void)debug:(NSString *)message;
- (void)info:(NSString *)message;
- (void)warn:(NSString *)message;
- (void)error:(NSString *)message;
- (void)fatal:(NSString *)message;

/**
 * Level testers
 */
- (BOOL)isDebug;
- (BOOL)isInfo;
- (BOOL)isWarn;
- (BOOL)isError;
- (BOOL)isFatal;

@end

@interface ABAlertView : NSObject
+ (void)displayAlertView:(NSString *)title delegate:(id /*<UIAlertViewDelegate>*/)delegate format:(NSString *)format, ...;
+ (void)displayAlertView:(UIImage *)image;
@end