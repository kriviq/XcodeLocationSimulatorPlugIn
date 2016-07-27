//
//  XcodeHeaders.h
//  XcodeLocationSim
//
//  Created by iyanakiev on 27/7/16.
//  Copyright © 2016 Kriviq. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IDEWorkspaceTabController, NSArray, NSMenu, NSString;

@class DVTFilePath, NSArray, NSMutableArray, NSNumber, NSString;

@class IDELocationScenario;

@interface IDELocation : NSObject
{
    NSNumber *_latitude;
    NSNumber *_longitude;
    IDELocationScenario *_scenario;
}

@property(readonly) IDELocationScenario *scenario; // @synthesize scenario=_scenario;
@property(readonly) NSNumber *longitude; // @synthesize longitude=_longitude;
@property(readonly) NSNumber *latitude; // @synthesize latitude=_latitude;
- (void).cxx_destruct;
- (id)description;
- (id)initWithLatitude:(id)arg1 longitude:(id)arg2;

@end


@interface IDELocationScenario : NSObject
{
    NSString *_identifier;
    NSArray *_locations;
    BOOL _autorepeat;
    NSNumber *_speed;
    DVTFilePath *_filePath;
    BOOL _hasLoadedContent;
    BOOL _valid;
    BOOL _isCurrentLocation;
}

+ (id)builtInScenarioWithIdentifier:(id)arg1;
+ (id)defaultScenarios;
+ (id)currentLocationScenario;
@property(readonly) BOOL isCurrentLocationScenario; // @synthesize isCurrentLocationScenario=_isCurrentLocation;
@property(readonly) DVTFilePath *filePath; // @synthesize filePath=_filePath;
@property(readonly) NSString *identifier; // @synthesize identifier=_identifier;
@property(readonly) NSNumber *speed; // @synthesize speed=_speed;
@property(readonly) BOOL autorepeat; // @synthesize autorepeat=_autorepeat;
- (void).cxx_destruct;
@property(readonly, getter=isDefaultScenario) BOOL defaultScenario;
- (id)description;
@property(readonly) BOOL isValid;
@property(readonly) NSString *name;
@property(readonly) NSArray *locations; // @dynamic locations;
- (id)_locationsFromReferencedGPXFileWithError:(id *)arg1;
- (id)initWithWorkspace:(id)arg1 referencingFilePath:(id)arg2;
- (id)initWithIdentifier:(id)arg1 referencingFilePath:(id)arg2;
- (id)initWithIdentifier:(id)arg1 locations:(id)arg2 speed:(id)arg3 autorepeat:(BOOL)arg4;
- (id)initWithIdentifier:(id)arg1 locations:(id)arg2;

// Remaining properties
@property(readonly) NSMutableArray *mutableLocations; // @dynamic mutableLocations;

@end

@interface IDESchemeOptionMenuController : NSObject <NSMenuDelegate>
{
    BOOL _validateMenuItems;
    int _extraItems;
    IDEWorkspaceTabController *_tabController;
    id _itemWasSelectedCallback;
    id _menuWasUpdatedCallback;
    id _willAddFileCallback;
    id _didAddFilesCallback;
    id _additionContext;
    NSMenu *_menu;
    id _enabledCallback;
    NSArray *_itemsForFilesInWorkspace;
    NSArray *_defaultItems;
    NSString *_menuTitle;
    NSString *_doNothingItemTitle;
    id _doNothingItemRepresentedObject;
    NSString *_uti;
}

@property(readonly) NSString *uti; // @synthesize uti=_uti;
@property(readonly) id doNothingItemRepresentedObject; // @synthesize doNothingItemRepresentedObject=_doNothingItemRepresentedObject;
@property(readonly) NSString *doNothingItemTitle; // @synthesize doNothingItemTitle=_doNothingItemTitle;
@property(readonly) NSString *menuTitle; // @synthesize menuTitle=_menuTitle;
@property(readonly) NSArray *defaultItems; // @synthesize defaultItems=_defaultItems;
@property(readonly) NSArray *itemsForFilesInWorkspace; // @synthesize itemsForFilesInWorkspace=_itemsForFilesInWorkspace;
@property(copy) id enabledCallback; // @synthesize enabledCallback=_enabledCallback;
@property(retain) id additionContext; // @synthesize additionContext=_additionContext;
@property(copy) id didAddFilesCallback; // @synthesize didAddFilesCallback=_didAddFilesCallback;
@property(copy) id willAddFileCallback; // @synthesize willAddFileCallback=_willAddFileCallback;
@property(copy) id menuWasUpdatedCallback; // @synthesize menuWasUpdatedCallback=_menuWasUpdatedCallback;
@property(copy) id itemWasSelectedCallback; // @synthesize itemWasSelectedCallback=_itemWasSelectedCallback;
@property(retain, nonatomic) IDEWorkspaceTabController *tabController; // @synthesize tabController=_tabController;
@property(nonatomic) int extraItems; // @synthesize extraItems=_extraItems;
@property BOOL validateMenuItems; // @synthesize validateMenuItems=_validateMenuItems;
//- (void).cxx_destruct;
- (void)attachToMenu:(id)arg1;
- (void)menuNeedsUpdate:(id)arg1;
- (void)_updateMenu:(id)arg1;
- (void)newFile:(id)arg1;
- (void)addFile:(id)arg1;
- (void)selectItem:(id)arg1;
- (void)_selectItemWithRepresentedObject:(id)arg1;
- (BOOL)validateMenuItem:(id)arg1;
- (id)_buildMenu;
- (id)_filesInWorkspaceMatchingUTI;
- (unsigned long long)_indexOfIconItem;
- (unsigned long long)_indexOfDoNothingItem;
- (unsigned long long)_indexOfNoneItem;
- (id)init;

@end

@interface IDESimulateLocationMenuController : IDESchemeOptionMenuController
{
}

- (id)uti;
- (id)doNothingItemRepresentedObject;
- (id)doNothingItemTitle;
- (id)defaultItems;
- (id)itemsForFilesInWorkspace;
- (id)_locationScenarioWithFilePath:(id)arg1;
- (id)menuTitle;
- (id)init;

+ (id)class;

@end
