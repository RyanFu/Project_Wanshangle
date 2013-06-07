//
//  AbstractSystemDataUpdater.h
//  common
//
//  Created by huishow on 4/14/12.
//  Copyright (c) 2012 Tsinghua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AbstractSystemDataUpdater : NSObject {
    
@protected NSString* _currentVersion;
    
}

@property(nonatomic, readonly) NSString* currentVersion;

- (id) initWithVersion:(NSString*) version ;

- (NSString*) getDiskDataVersion;
- (void) syncDiskDataVersion;

- (BOOL) canUpdate;
//- (NSArray*)getOldCodeRecord;
// return the latest version
- (void) doUpdate;

@end
