//
//  LocationSImulationDelegate.m
//  XcodeLocationSim
//
//  Created by iyanakiev on 8/8/16.
//  Copyright © 2016 Kriviq. All rights reserved.
//

#import "LocationSImulationDelegate.h"
#import "XcodeHeaders.h"

@interface LocationSImulationDelegate ()

@property (nonatomic, strong) NSArray *locations;

@end


@implementation LocationSImulationDelegate

- (instancetype)initWithSimulator:(id)locationSimulator {
    self = [super init];
    if (self) {
        _locationSimulator = locationSimulator;
        [self loadLocations];
    }
    
    return self;
}

- (void)loadLocations {
    NSMutableArray *locations = [NSMutableArray new];
    if (self.locationSimulator) {
        for (id scenario in [self.locationSimulator itemsForFilesInWorkspace]) {
            //TODO: CHANGE THE CRITERIA FOR SEARCHING - remove the STZ part
            if ([(NSString *)[scenario valueForKey:@"identifier"] containsString:@"StZ"]) {
                [locations addObject:scenario];
            }
        }
    }
    
    //TODO: Sort locations by name?
    
    self.locations = locations.copy;
}

-(void)startMoving {
    //TOOD: Move the location alternation code to this class
}

@end
