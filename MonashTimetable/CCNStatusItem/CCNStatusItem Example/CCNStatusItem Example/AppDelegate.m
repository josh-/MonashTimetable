//
//  Created by Frank Gregor on 28.12.14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

#import "AppDelegate.h"
#import "CCNStatusItem.h"
#import "CCNStatusItemWindowConfiguration.h"
#import "ContentViewController.h"


@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *appearsDisabledCheckbox;
@property (weak) IBOutlet NSButton *disableCheckbox;
@property (weak) IBOutlet NSButton *proximityDetectionCheckbox;
@property (weak) IBOutlet NSButton *dragAndDropCheckbox;
@property (weak) IBOutlet NSButton *pinPopoverCheckbox;
@property (weak) IBOutlet NSSlider *proximityDragZoneDistanceSlider;
@property (weak) IBOutlet NSTextField *currentpProximityDragZoneDistanceTextField;
@property (weak) IBOutlet NSMatrix *presentationTransitionRadios;

@property (assign) BOOL proximityDetectionEnabled;
@property (readwrite, assign) NSInteger proximitySliderValue;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // configure the status item
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    sharedItem.windowConfiguration.presentationTransition = CCNPresentationTransitionSlideAndFade;
    sharedItem.proximityDragDetectionHandler = [self proximityDragDetectionHandler];
    [sharedItem presentStatusItemWithImage:[NSImage imageNamed:@"statusbar-icon"]
                     contentViewController:[ContentViewController viewController]
                               dropHandler:nil];
    
    
    // restore GUI elements
    // (this is an excerpt from the example app)
    self.proximitySliderValue = sharedItem.proximityDragZoneDistance;
    self.appearsDisabledCheckbox.state = (sharedItem.appearsDisabled ? NSOnState : NSOffState);
    self.disableCheckbox.state = (sharedItem.enabled ? NSOffState : NSOnState);
    [self.presentationTransitionRadios selectCellAtRow:(NSInteger)sharedItem.windowConfiguration.presentationTransition column:0];
}

- (CCNStatusItemProximityDragDetectionHandler)proximityDragDetectionHandler {
    return ^(CCNStatusItem *item, NSPoint eventLocation, CCNStatusItemProximityDragStatus dragStatus) {
        switch (dragStatus) {
            case CCNProximityDragStatusEntered:
                [item showStatusItemWindow];
                break;

            case CCNProximityDragStatusExited:
                [item dismissStatusItemWindow];
                break;
        }
    };
}

- (IBAction)appearsDisabledCheckboxAction:(id)sender {
    [CCNStatusItem sharedInstance].appearsDisabled = (self.appearsDisabledCheckbox.state == NSOnState);
}

- (IBAction)disableCheckboxAction:(id)sender {
    [CCNStatusItem sharedInstance].enabled = (self.disableCheckbox.state == NSOffState);
}

- (IBAction)proximityDetectionCheckboxAction:(NSButton *)proximityDetectionCheckbox {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    sharedItem.proximityDragDetectionEnabled = (proximityDetectionCheckbox.state == NSOnState);
}

- (IBAction)dragAndDropCheckboxAction:(NSButton *)dragAndDropCheckbox {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    if (dragAndDropCheckbox.state == NSOnState) {
        sharedItem.dropHandler = ^(CCNStatusItem *sharedItem, NSString *pasteboardType, NSArray *droppedObjects) {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Dropped Objects";
            __block NSMutableString *objects = [NSMutableString new];
            [droppedObjects enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
                [objects appendFormat:@"%@. %@\n\n", @(idx+1), path];
            }];
            alert.informativeText = objects;
            [alert runModal];
        };
    }
    else {
        sharedItem.dropHandler = nil;
    }
}

- (IBAction)pinPopoverCheckboxAction:(NSButton *)pinPopoverCheckbox {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    sharedItem.windowConfiguration.pinned = (pinPopoverCheckbox.state == NSOnState);
}

- (IBAction)proximityDragZoneDistanceSliderAction:(NSSlider *)proximityDragZoneDistanceSlider {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    sharedItem.proximityDragZoneDistance = self.proximitySliderValue;
}

- (IBAction)presentationTransitionRadiosAction:(NSMatrix *)presentationTransitionRadios {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    sharedItem.windowConfiguration.presentationTransition = (CCNPresentationTransition)presentationTransitionRadios.selectedRow;
}

@end
