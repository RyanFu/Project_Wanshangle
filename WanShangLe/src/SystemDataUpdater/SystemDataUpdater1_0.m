//
//  SystemDataUpdater1_0.m
//  uimain
//
//  Created by huishow on 4/14/12.
//  Copyright (c) 2012 Tsinghua. All rights reserved.
//

#import "SystemDataUpdater1_0.h"
@implementation SystemDataUpdater1_0

- (id) init {
    self = [super initWithVersion:AppVersion];
    return self;
}

- (BOOL) canUpdate {
    // we call getDiskDataVersion to build a version.data file
    [self getDiskDataVersion];
    
    // we do not need to do any update work
    return NO;
}

// return the latest version
- (void) doUpdate{
    assert(0);
}

@end
