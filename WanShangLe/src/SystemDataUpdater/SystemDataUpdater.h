//
//  SystemDataUpdater.h
//  common
//
//  Created by huishow on 4/14/12.
//  Copyright (c) 2012 Tsinghua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AbstractSystemDataUpdater.h"

@interface SystemDataUpdater : AbstractSystemDataUpdater {
@private
    NSArray* _updaterArray;
}

- (id) initWithUpdaterArray:(NSArray*) updaterArray;
@end
