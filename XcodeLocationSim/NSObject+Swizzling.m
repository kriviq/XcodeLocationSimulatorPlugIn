//
//  NSObject+Swizzling.m
//  XcodeLocationSim
//
//  Created by Ivan Yanakiev on 7/27/16.
//  Copyright © 2016 Kriviq. All rights reserved.
//

#import "NSObject+Swizzling.h"
// 1
#import <objc/runtime.h>

@implementation NSObject (Swizzling)

+ (void)swizzleWithOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL) swizzledSelector isClassMethod:(BOOL)isClassMethod
{
    Class cls = [self class];
    
    Method originalMethod;
    Method swizzledMethod;
    
    // 2
    if (isClassMethod) {
        originalMethod = class_getClassMethod(cls, originalSelector);
        swizzledMethod = class_getClassMethod(cls, swizzledSelector);
    } else {
        originalMethod = class_getInstanceMethod(cls, originalSelector);
        swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    }
    
    // 3
    if (!originalMethod) {
        NSLog(@"Error: originalMethod is nil, did you spell it incorrectly? %@", originalMethod);
        return;
    }
    
    // 4
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

@end
