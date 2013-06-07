//
//  NSDictionaryToNSValueTransformer.m
//  NightCoreData
//
//  Created by stephenliu on 13-5-23.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "NSDictionaryToNSValueTransformer.h"

@implementation NSDictionaryToNSValueTransformer

+ (Class)transformedValueClass
{
    return [NSDictionary class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end