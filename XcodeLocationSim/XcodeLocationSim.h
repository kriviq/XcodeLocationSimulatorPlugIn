//
//  XcodeLocationSim.h
//  XcodeLocationSim
//
//  Created by Ivan Yanakiev on 7/26/16.
//  Copyright © 2016 Kriviq. All rights reserved.
//

#import <AppKit/AppKit.h>

@protocol LocationSimulationDelegate <NSObject>

@required

- (void)startMoving;

@end

@interface XcodeLocationSim : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;

@property (nonatomic, strong) id <LocationSimulationDelegate> locationDelegate;

@end