//
//  AbstractSystemDataUpdater.m
//  common
//
//  Created by huishow on 4/14/12.
//  Copyright (c) 2012 Tsinghua. All rights reserved.
//

#import "AbstractSystemDataUpdater.h"

#import "common.h"

//static const char* _fileName = "codesaver.data";
static const NSString* _versionFileName = @"version.data";

@implementation AbstractSystemDataUpdater

- (id) initWithVersion:(NSString*) version{
    self = [super init];
    
    if (self) {
        _currentVersion = version;
        [_currentVersion retain];
    }
    
    return self;
}

- (void) dealloc {
    [_currentVersion release];
    [super dealloc];
}

@synthesize currentVersion = _currentVersion;

- (NSString*) getDiskDataVersion {
    NSString* versionFilePath = getDocumentsFilePath(_versionFileName);
    NSString* diskDataVersion = _currentVersion;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:versionFilePath]) {
        diskDataVersion = [[[NSString alloc] initWithContentsOfFile:versionFilePath encoding:NSUTF8StringEncoding error:nil] autorelease];
    }else{
        // build version file , if it does not exist
        [self syncDiskDataVersion];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:NewApp];
    }
    return diskDataVersion;
}

- (void) syncDiskDataVersion{
    NSString * versionFilePath = getDocumentsFilePath(_versionFileName);
    [_currentVersion writeToFile:versionFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (BOOL) canUpdate {
    ABLoggerDebug(@"_currentVerson is %@,[self getDiskDataVersion] is %@",_currentVersion,[self getDiskDataVersion]);
    ABLoggerDebug(@"%d",[_currentVersion compare:[self getDiskDataVersion]] > 0);
    return [_currentVersion compare:[self getDiskDataVersion]] > 0;
}

// return the latest version
- (void) doUpdate{
    assert(0);
}

@end
