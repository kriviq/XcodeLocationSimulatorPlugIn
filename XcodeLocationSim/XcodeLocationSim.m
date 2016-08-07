//
//  XcodeLocationSim.m
//  XcodeLocationSim
//
//  Created by Ivan Yanakiev on 7/26/16.
//  Copyright © 2016 Kriviq. All rights reserved.
//

#import "XcodeLocationSim.h"
#import "XcodeHeaders.h"
#import "NSObject+Swizzling.h"
#import <objc/runtime.h>

//NSObject+logProperties.h
@interface NSObject (logProperties)
- (void) logProperties;
@end

@implementation NSObject (logProperties)

- (void) logProperties {
    
    NSLog(@"----------------------------------------------- Properties for object %@", self);
    
    @autoreleasepool {
        unsigned int numberOfProperties = 0;
        objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
        for (NSUInteger i = 0; i < numberOfProperties; i++) {
            objc_property_t property = propertyArray[i];
            NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
            NSLog(@"Property %@ Value: %@", name, [self valueForKey:name]);
        }
        free(propertyArray);
    }
    NSLog(@"-----------------------------------------------");
}

@end

@interface XcodeLocationSim ()

@property (nonatomic, strong) NSMutableSet *notifications;
@property (nonatomic, strong) id locationSimulatorDelegate;
@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) id currentLocationScenario;
@property (nonatomic, assign) CGFloat lonitudeStep;
@property (nonatomic, assign) CGFloat latitudeStep;
@property (nonatomic, assign) id workloadLocationScenario;

@property (nonatomic, copy) NSNumber *currentLatitude;
@property (nonatomic, copy) NSNumber *currentLongitude;

@end

static XcodeLocationSim *sharedPlugin;

@implementation XcodeLocationSim

#pragma mark - Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    NSArray *allowedLoaders = [plugin objectForInfoDictionaryKey:@"me.delisa.XcodePluginBase.AllowedLoaders"];
    if ([allowedLoaders containsObject:[[NSBundle mainBundle] bundleIdentifier]]) {
        sharedPlugin = [[self alloc] initWithBundle:plugin];
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        _bundle = bundle;
        // NSApp may be nil if the plugin is loaded from the xcodebuild command line tool
        if (NSApp && !NSApp.mainMenu) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationDidFinishLaunching:)
                                                         name:NSApplicationDidFinishLaunchingNotification
                                                       object:nil];
            self.notifications = [NSMutableSet new];
            [self observeAllEvents];
            
        } else {
            [self initializeAndLog];
        }
    }
    return self;
}
- (void)observeAllEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(somethingHappened:) name:nil object:nil];
}

- (void)somethingHappened:(NSNotification *)notification {
//    NSLog(@"event - %@, %@", notification.name, [notification.object class]);
//    
//    if ([notification.name isEqualToString:@"NSMenuDidChangeItemNotification"]) {
//        NSLog(@"notification object - %@", notification.object);
//    }
    if (![self.notifications containsObject:notification.name]) {
        NSLog(@"event - %@, %@", notification.name, [notification.object class]);
        [self.notifications addObject:notification.name];
        
        if ([notification.object class] == [NSMenu class]) {
            NSMenu *menuItem = (NSMenu *)notification.object;
            
            NSLog(@"Menu Items %@", menuItem.itemArray);
            NSLog(@"Menu Delegate %@", menuItem.delegate);
            if (menuItem.delegate) {
                NSLog(@"delegate is %@", menuItem.delegate);
                if ([menuItem.delegate isKindOfClass:NSClassFromString(@"IDESimulateLocationMenuController")]) {
                    NSLog(@"We got a class we want %@", menuItem);
                    self.locationSimulatorDelegate = menuItem.delegate;
                    [self extractCityLocations];

                }
            }
        }
    }
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    [self initializeAndLog];
}

- (void)initializeAndLog
{
    NSString *name = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *version = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *status = [self initialize] ? @"loaded successfully" : @"failed to load";
    NSLog(@"🔌 Plugin %@ %@ %@", name, version, status);
}

#pragma mark - Implementation

- (BOOL)initialize
{
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Do Action" action:@selector(doMenuAction) keyEquivalent:@""];
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
        return YES;
    } else {
        return NO;
    }
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    [self.notifications removeAllObjects];
    if (self.locationSimulatorDelegate) {
        [self extractCityLocations];
        [self startMovingFromLocation:0];
    }
}

static NSInteger currentIndex;

- (void)startMovingFromLocation:(NSInteger)locationIndex {
    currentIndex = locationIndex;
    self.currentLocationScenario = self.locations[currentIndex];
    if (currentIndex >= self.locations.count) {
        return;
    }
    [self.locationSimulatorDelegate _selectItemWithRepresentedObject:self.currentLocationScenario];
    stepCount = 0;
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(goToNextLocation:)
                                   userInfo:self.locations[currentIndex + 1]
                                    repeats:YES];
}


static NSInteger stepCount;
static BOOL oddStep;

- (void)goToNextLocation:(NSTimer *)timer {
    id targetLocationScenario = timer.userInfo;
    if (stepCount >= 1000) {
        [timer invalidate];
        [self.locationSimulatorDelegate _selectItemWithRepresentedObject:targetLocationScenario];
        [self startMovingFromLocation:(currentIndex + 1)];

    }
    
    
    id nextLocationScenario = self.locations[currentIndex + 1];
    id customizedLocationScenario = oddStep ? nextLocationScenario : self.currentLocationScenario;//self.locations[currentIndex];
    oddStep = !oddStep;
    id customizedLocation = [[customizedLocationScenario valueForKey:@"locations"] firstObject];
    
    //Calculate the step - extract it! - In the future the step should be set according to runining/cycling/walking scenario
    if (stepCount == 0) {
        CGFloat meterDifference = 0.00000003;
        
        id currentLocation = [[self.currentLocationScenario valueForKey:@"locations"] firstObject];
        id targetLocation = [[targetLocationScenario valueForKey:@"locations"] firstObject];
        
        NSNumber *currentLongitude = [currentLocation valueForKey:@"longitude"];
        NSNumber *targetLongitude = [targetLocation valueForKey:@"longitude"];
        
        self.lonitudeStep = meterDifference;////([targetLongitude floatValue] - [currentLongitude floatValue]) / 10.f;
        
        NSNumber *currentLatitude = [currentLocation valueForKey:@"latitude"];
        NSNumber *targetLatitude = [targetLocation valueForKey:@"latitude"];
        
        self.latitudeStep = meterDifference;//([targetLatitude floatValue] - [currentLatitude floatValue]) / 10.f;
        
        self.currentLatitude = [customizedLocation valueForKey:@"latitude"];
        self.currentLongitude = [customizedLocation valueForKey:@"longitude"];;
    }

//    NSNumber *currentLongitude = [customizedLocation valueForKey:@"longitude"];
    
    self.currentLongitude = [NSNumber numberWithFloat:([self.currentLongitude floatValue] + (self.lonitudeStep  * stepCount))];
    [customizedLocation setValue:self.currentLongitude forKey:@"longitude"];

//    NSNumber *currentLatitude = [customizedLocation valueForKey:@"latitude"];
    self.currentLatitude = [NSNumber numberWithFloat:[self.currentLatitude floatValue] + (self.latitudeStep * stepCount)];
    [customizedLocation setValue:self.currentLatitude forKey:@"latitude"];
    ++stepCount;

    [self.locationSimulatorDelegate _selectItemWithRepresentedObject:customizedLocationScenario];
}

- (void)goToLocation:(NSTimer *)timer {
    if (currentIndex >= self.locations.count) {
        [timer invalidate];
        return;
    }
    id customizedLocationScenario = self.locations[currentIndex];
    id customizedLocation = [[customizedLocationScenario valueForKey:@"locations"] firstObject];
    NSNumber *currentLongitude = [customizedLocation valueForKey:@"longitude"];
    [customizedLocation setValue:[NSNumber numberWithFloat:([currentLongitude floatValue] + 0.5f)] forKey:@"longitude"];
    
    [self.locationSimulatorDelegate _selectItemWithRepresentedObject:customizedLocationScenario];
    ++currentIndex;
}

- (void)extractCityLocations {
    NSMutableArray *locations = [NSMutableArray new];
    if (self.locationSimulatorDelegate) {
        
        for (id scenario in [self.locationSimulatorDelegate itemsForFilesInWorkspace]) {
            if ([(NSString *)[scenario valueForKey:@"identifier"] containsString:@"StZ"]) {
                [locations addObject:scenario];
            }
            else if ([(NSString *)[scenario valueForKey:@"identifier"] containsString:@"WorkloadLocation"]) {
                self.workloadLocationScenario = scenario;
            }
        }
    }
    
    self.locations = locations.copy;
}

@end

@interface NSObject ()

// 3
//- (id)initWithIcon:(id)arg1 message:(id)arg2 parentWindow:(id)arg3 duration:(double)arg4;
@end


// 4
@implementation NSObject (ReverseEngineerHelper)

// 5
+ (void)load
{
    static dispatch_once_t onceToken;
    
    // 6
    dispatch_once(&onceToken, ^{
        
        // 7
//        [NSClassFromString(@"IDESimulateLocationMenuController") swizzleWithOriginalSelector:@selector(selectItem:) swizzledSelector:@selector(RE_selectItem:) isClassMethod:NO];
        
//        [NSClassFromString(@"IDESimulateLocationMenuController") swizzleWithOriginalSelector:@selector(_selectItemWithRepresentedObject:) swizzledSelector:@selector(RE_selectItemWithRepresentedObject:) isClassMethod:NO];
    });
}

- (void)RE_selectItem:(id)arg1 {
    NSLog(@"swizzled RE_selectItem with arg %@", arg1);
}

- (void)RE_selectItemWithRepresentedObject:(id)arg1 {
    NSLog(@"_selectItemWithRepresentedObject item with arg %@", arg1);
}

//// 8
//- (id)Rayrolling_initWithIcon:(id)icon message:(id)message parentWindow:(id)window duration:(double)duration
//{
//    // 9
//    NSLog(@"Swizzle success! %@", self);
//    
//    // 10
//    return [self Rayrolling_initWithIcon:icon message:message parentWindow:window duration:duration];
//}

@end

