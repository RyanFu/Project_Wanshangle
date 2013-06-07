//
//  SystemDataUpdater.m
//  common
//
//  Created by huishow on 4/14/12.
//  Copyright (c) 2012 Tsinghua. All rights reserved.
//

#import "SystemDataUpdater.h"

@implementation SystemDataUpdater

- (void) dealloc {
    [_updaterArray release];
    [super dealloc];
}

- (id) initWithUpdaterArray:(NSArray*) updaterArray {
    self = [super initWithVersion:@"10000"];
    if (self) {
        _updaterArray = updaterArray;
        [_updaterArray retain];
    }
    
    return self;
}

- (BOOL) canUpdate {
    return YES;
}

// return the latest version
- (void) doUpdate{

    for (AbstractSystemDataUpdater* updater in _updaterArray) {
            if ([updater canUpdate]) {
                [updater doUpdate];
            }
        }  
}

@end
