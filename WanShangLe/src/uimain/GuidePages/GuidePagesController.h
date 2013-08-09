//
//  GuidePagesController.h
//  Gaopeng
//
//  Created by yuqiang on 11-11-22.
//  Copyright 2011年 GP. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  display guide pages
 ***/
@interface GuidePagesController : UIViewController {
    
@private
    id _delegate;
    SEL _selector;
    
}

@property(nonatomic, assign) id delegate;
@property(nonatomic, assign) SEL selector;

- (id) init;

@end
