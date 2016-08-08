//
//  LocationSImulationDelegate.h
//  XcodeLocationSim
//
//  Created by iyanakiev on 8/8/16.
//  Copyright © 2016 Kriviq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XcodeLocationSim.h"

@interface LocationSImulationDelegate : NSObject <LocationSimulationDelegate>

@property (nonatomic, strong) id locationSimulator;

- (instancetype)initWithSimulator:(id)locationSimulator;

@end
