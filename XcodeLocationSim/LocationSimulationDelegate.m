//
//  LocationSImulationDelegate.m
//  XcodeLocationSim
//
//  Created by iyanakiev on 8/8/16.
//  Copyright © 2016 Kriviq. All rights reserved.
//

#import "LocationSimulationDelegate.h"
#import "XcodeHeaders.h"
#import <MapKit/MapKit.h>

@interface LocationSimulationDelegate ()

@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, assign) CGPoint currentCoordinates;
@property (nonatomic, assign) CGPoint targetCoordinates;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) CGFloat refreshRate;

@property (nonatomic, assign) BOOL oddStep;
@property (nonatomic, assign) CGFloat step;

@end


@implementation LocationSimulationDelegate

- (instancetype)initWithSimulator:(id)locationSimulator {
    self = [super init];
    if (self) {
        _locationSimulator = locationSimulator;
        _step = 0.000001;
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
        
        self.refreshRate = 0.5f;
    }
    
    //TODO: Sort locations by name?
    
    self.locations = locations.copy;
}

-(void)startMoving {
    //TOOD: Move the location alternation code to this class
    
    [self goToNextLocation];
}

- (void)goToNextLocation {
    //Run a loop that will go from point to point
    if (self.currentIndex == self.locations.count) {
        //TODO: Do something to point out that we've arrived
        NSLog(@"We are at the end of our journey");
    }
    
    self.currentCoordinates = [self coordinatesFromScenario:self.locations[self.currentIndex]];
    self.targetCoordinates = [self coordinatesFromScenario:self.locations[self.currentIndex + 1]];
    
    [NSTimer scheduledTimerWithTimeInterval:self.refreshRate
                                     target:self
                                   selector:@selector(takeNextStep:)
                                   userInfo:nil
                                    repeats:YES];
}

- (BOOL)atTargetLocation {
//    return NO;
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:self.currentCoordinates.x longitude:self.currentCoordinates.y];
    CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:self.targetCoordinates.x longitude:self.targetCoordinates.y];
    CLLocationDistance metersDistance = [currentLocation distanceFromLocation:targetLocation];
//    NSLog(@"distance is %f", metersDistance);
    return metersDistance <= 50;
//    CGFloat distance = sqrtf(powf(self.targetCoordinates.x - self.currentCoordinates.x, 2) + powf(self.targetCoordinates.y - self.currentCoordinates.y, 2));
//    return distance <= 3 * self.step;
}

- (void)takeNextStep:(NSTimer *)timer {
    //TODO: In this if check if we have arrived at the next stop and continue the journey on
    if ([self atTargetLocation]) {
        //TODO: Fix the target scenario location if needed
        [timer invalidate];
        ++self.currentIndex;
        [self goToNextLocation];
    }
    
    id customizedLocationScenario = self.oddStep ? self.locations[self.currentIndex + 1] : self.locations[self.currentIndex];
    self.oddStep = !self.oddStep;
    id customizedLocation = [[customizedLocationScenario valueForKey:@"locations"] firstObject];
    
    CGPoint nextCoordinates = [self nextStep];
    [customizedLocation setValue:[NSNumber numberWithFloat:nextCoordinates.x] forKey:@"longitude"];
    [customizedLocation setValue:[NSNumber numberWithFloat:nextCoordinates.y] forKey:@"latitude"];
    
    [self.locationSimulator _selectItemWithRepresentedObject:customizedLocationScenario];

    self.currentCoordinates = nextCoordinates;
}

- (CGPoint)nextStep {
    CGPoint direction;
    
    direction.x = self.targetCoordinates.x - self.currentCoordinates.x;
    direction.y = self.targetCoordinates.y - self.currentCoordinates.y;
    
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:self.currentCoordinates.x longitude:self.currentCoordinates.y];
    CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:self.targetCoordinates.x longitude:self.targetCoordinates.y];
    CLLocationDistance metersDistance = [currentLocation distanceFromLocation:targetLocation];
//    CGFloat distance = sqrtf(powf(self.targetCoordinates.x - self.currentCoordinates.x, 2) + powf(self.targetCoordinates.y - self.currentCoordinates.y, 2));
    
    direction.x = direction.x / metersDistance;
    direction.y = direction.y / metersDistance;
    
    //TODO: The distance added should be calculated according to the speed we want to move with!
    return CGPointMake(self.currentCoordinates.x + (direction.x * 0.000001), self.currentCoordinates.y + (direction.y + 0.000001));
}

- (CGPoint)coordinatesFromScenario:(id)locationScenario {
    id location = [[locationScenario valueForKey:@"locations"] firstObject];
    NSNumber *longitude = [location valueForKey:@"longitude"];
    NSNumber *latitude = [location valueForKey:@"latitude"];
    
    return CGPointMake([longitude floatValue], [latitude floatValue]);
}

@end
