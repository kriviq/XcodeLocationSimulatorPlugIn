//
//  NSObject+Swizzling.h
//  XcodeLocationSim
//
//  Created by Ivan Yanakiev on 7/27/16.
//  Copyright © 2016 Kriviq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Swizzling)

+ (void)swizzleWithOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL) swizzledSelector isClassMethod:(BOOL)isClassMethod;

@end
