//
//  XcodeLocationSim.m
//  XcodeLocationSim
//
//  Created by Ivan Yanakiev on 7/26/16.
//  Copyright © 2016 Kriviq. All rights reserved.
//

#import "XcodeLocationSim.h"
#import "XcodeHeaders.h"

@interface XcodeLocationSim ()

@property (nonatomic, strong) NSMutableSet *notifications;
@property (nonatomic, strong) id locationSimulatorDelegate;

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
        [self.locationSimulatorDelegate selectItem:nil];
    }
    
    
//    NSAlert *alert = [[NSAlert alloc] init];
//    [alert setMessageText:@"Hello, World"];
//    [alert runModal];
}

- (IDELocationScenario*)customLocationScenario {
    
    return nil;
}

@end
