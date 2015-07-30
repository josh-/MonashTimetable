//
//  Created by Frank Gregor on 21/12/14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright © 2014 Frank Gregor, <phranck@cocoanaut.com>
 http://cocoanaut.mit-license.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the “Software”), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <Availability.h>
#import "CCNStatusItem.h"
#import "CCNStatusItemDropView.h"
#import "CCNStatusItemWindowController.h"


static NSString *const CCNStatusItemFrameKeyPath = @"statusItem.button.window.frame";
static NSString *const CCNStatusItemWindowConfigurationPinnedPath = @"windowConfiguration.pinned";


@interface NSStatusBarButton (Tools)
@end
@implementation NSStatusBarButton (Tools)
- (void)rightMouseDown:(NSEvent *)theEvent {}
@end



#pragma mark - CCNStatusItemView
#pragma mark -

@interface CCNStatusItem () <NSWindowDelegate> {
    id _globalDragEventMonitor;
    BOOL _proximityDragCollisionHandled;
    NSBezierPath *_proximityDragCollisionArea;
    NSInteger _pbChangeCount;
}
@property (strong) NSStatusItem *statusItem;
@property (assign) CCNStatusItemPresentationMode presentationMode;
@property (assign, nonatomic) BOOL isStatusItemWindowVisible;
@property (strong) CCNStatusItemDropView *dropView;
@property (strong, nonatomic) CCNStatusItemWindowController *statusItemWindowController;
@end

@implementation CCNStatusItem

#pragma mark - Initialization

+ (instancetype)sharedInstance {
    static dispatch_once_t _onceToken;
    __strong static CCNStatusItem *_sharedInstance;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[[self class] alloc] initSingleton];
    });
    return _sharedInstance;
}

- (instancetype)init {
    NSString *exceptionMessage = [NSString stringWithFormat:@"You must NOT init '%@' manually! Use class method 'sharedInstance' instead.", [self className]];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:exceptionMessage userInfo:nil];
}

- (instancetype)initSingleton {
    self = [super init];
    if (self) {
        _globalDragEventMonitor = nil;
        _proximityDragCollisionHandled = NO;

        _pbChangeCount = [NSPasteboard pasteboardWithName:NSDragPboard].changeCount;

        self.statusItem = nil;
        self.presentationMode = CCNStatusItemPresentationModeUndefined;
        self.isStatusItemWindowVisible = NO;
        self.statusItemWindowController = nil;
        self.windowConfiguration = [CCNStatusItemWindowConfiguration defaultConfiguration];
        self.appearsDisabled = NO;
        self.enabled = YES;

        self.dropTypes = @[NSFilenamesPboardType];
        self.dropHandler = nil;
        self.proximityDragDetectionEnabled = NO;
        self.proximityDragZoneDistance = 23.0;
        self.proximityDragDetectionHandler = nil;

        // We need to observe that because when an status bar item has been removed from the status bar
        // and OS X reorganize all items, we must recalculate our _proximityDragCollisionArea.
        [self addObserver:self forKeyPath:CCNStatusItemFrameKeyPath options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:CCNStatusItemWindowConfigurationPinnedPath options:NSKeyValueObservingOptionPrior|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:CCNStatusItemFrameKeyPath];
    [self removeObserver:self forKeyPath:CCNStatusItemWindowConfigurationPinnedPath];

    _statusItem = nil;
    _statusItemWindowController = nil;
    _windowConfiguration = nil;
    _dropHandler = nil;
    _proximityDragDetectionHandler = nil;
    _proximityDragCollisionArea = nil;
}

- (void)configureWithImage:(NSImage *)itemImage {
    [itemImage setTemplate:YES];

    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    NSStatusBarButton *button = self.statusItem.button;
    button.target = self;
    button.action = @selector(handleStatusItemButtonAction:);
    button.image = itemImage;
}

- (void)configureWithView:(NSView *)itemView {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSWidth(itemView.frame)];

    NSStatusBarButton *button = self.statusItem.button;
    button.frame = itemView.frame;
    [button addSubview:itemView];
    itemView.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);
}

- (void)configureProximityDragCollisionArea {
    NSRect statusItemFrame = self.statusItem.button.window.frame;
    NSRect collisionFrame = NSInsetRect(statusItemFrame, -_proximityDragZoneDistance, -_proximityDragZoneDistance);
    _proximityDragCollisionArea = [NSBezierPath bezierPathWithRoundedRect:collisionFrame xRadius:NSWidth(collisionFrame)/2 yRadius:NSHeight(collisionFrame)/2];
}

- (void)configureDropView {
    [self.dropView removeFromSuperview];
    self.dropView = nil;

    if (!self.dropHandler) {
        return;
    };

    NSStatusBarButton *button = self.statusItem.button;
    NSRect buttonWindowFrame = button.window.frame;
    NSRect statusItemFrame = NSMakeRect(0.0, 0.0, NSWidth(buttonWindowFrame), NSHeight(buttonWindowFrame));
    self.dropView = [[CCNStatusItemDropView alloc] initWithFrame:statusItemFrame];
    self.dropView.statusItem = self;
    self.dropView.dropTypes = self.dropTypes;
    self.dropView.dropHandler = self.dropHandler;
    [button addSubview:self.dropView];
    self.dropView.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);
}

#pragma mark - Creating and Displaying a StatusBarItem

- (void)presentStatusItemWithImage:(NSImage *)itemImage contentViewController:(NSViewController *)contentViewController {
    [self presentStatusItemWithImage:itemImage contentViewController:contentViewController dropHandler:nil];
}

- (void)presentStatusItemWithImage:(NSImage *)itemImage contentViewController:(NSViewController *)contentViewController dropHandler:(CCNStatusItemDropHandler)dropHandler {
    if (self.presentationMode != CCNStatusItemPresentationModeUndefined) return;

    [self configureWithImage:itemImage];
    [self configureProximityDragCollisionArea];

    self.dropHandler = dropHandler;
    self.presentationMode = CCNStatusItemPresentationModeImage;
    self.statusItemWindowController = [[CCNStatusItemWindowController alloc] initWithConnectedStatusItem:self
                                                                                   contentViewController:contentViewController
                                                                                     windowConfiguration:self.windowConfiguration];
}

- (void)presentStatusItemWithView:(NSView *)itemView contentViewController:(NSViewController *)contentViewController {
    [self presentStatusItemWithView:itemView contentViewController:contentViewController dropHandler:nil];
}

- (void)presentStatusItemWithView:(NSView *)itemView contentViewController:(NSViewController *)contentViewController dropHandler:(CCNStatusItemDropHandler)dropHandler {
    if (self.presentationMode != CCNStatusItemPresentationModeUndefined) return;

    [self configureWithView:itemView];
    [self configureProximityDragCollisionArea];

    self.dropHandler = dropHandler;
    self.presentationMode = CCNStatusItemPresentationModeCustomView;
    self.statusItemWindowController = [[CCNStatusItemWindowController alloc] initWithConnectedStatusItem:self
                                                                                   contentViewController:contentViewController
                                                                                     windowConfiguration:self.windowConfiguration];
}

- (void)updateContentViewController:(NSViewController *)contentViewController {
    [self.statusItemWindowController updateContenetViewController:contentViewController];
}

#pragma mark - Button Action Handling

- (void)handleStatusItemButtonAction:(id)sender {
    if (self.isStatusItemWindowVisible) {
        [self dismissStatusItemWindow];
    } else {
        [self showStatusItemWindow];
    }
}

#pragma mark - Custom Accessors

- (BOOL)isStatusItemWindowVisible {
    return (self.statusItemWindowController ? self.statusItemWindowController.windowIsOpen : NO);
}

- (void)setWindowConfiguration:(CCNStatusItemWindowConfiguration *)configuration {
    _windowConfiguration = configuration;
    self.statusItem.button.toolTip = configuration.toolTip;
}

- (BOOL)isDarkMode {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain];
    id style = [dict objectForKey:@"AppleInterfaceStyle"];
    return ( style && [style isKindOfClass:[NSString class]] && NSOrderedSame == [style caseInsensitiveCompare:@"dark"] );
}

- (void)setAppearsDisabled:(BOOL)appearsDisabled {
    self.statusItem.button.appearsDisabled = appearsDisabled;
}

- (BOOL)appearsDisabled {
    return self.statusItem.button.appearsDisabled;
}

- (void)setEnabled:(BOOL)enabled {
    self.statusItem.button.enabled = enabled;
}

- (BOOL)enabled {
    return self.statusItem.button.enabled;
}

- (void)setProximityDragDetectionEnabled:(BOOL)proximityDraggingDetectionEnabled {
    if (_proximityDragDetectionEnabled != proximityDraggingDetectionEnabled) {
        _proximityDragDetectionEnabled = proximityDraggingDetectionEnabled;

        if (_proximityDragDetectionEnabled && !self.windowConfiguration.isPinned) {
            [self configureProximityDragCollisionArea];
            [self enableDragEventMonitor];
        }
        else {
            [self disableDragEventMonitor];
        }
    }
}

- (void)setProximityDragZoneDistance:(NSInteger)proximityDragZoneDistance {
    if (_proximityDragZoneDistance != proximityDragZoneDistance) {
        _proximityDragZoneDistance = proximityDragZoneDistance;
        [self configureProximityDragCollisionArea];
    }
}

- (void)setDropHandler:(CCNStatusItemDropHandler)dropHandler {
    _dropHandler = [dropHandler copy];
    [self configureDropView];
}

#pragma mark - Helper

- (void)enableDragEventMonitor {
    if (_globalDragEventMonitor) return;

    __weak typeof(self) wSelf = self;
    _globalDragEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDraggedMask handler:^(NSEvent *event) {
        NSPoint eventLocation = [event locationInWindow];
        if ([_proximityDragCollisionArea containsPoint:eventLocation]) {
            // This is for detection if files has been dragged. If it happens the NSPasteboard's changeCount will be incremented.
            // Dragging a window will keep that changeCount untouched.
            // (Thank you Matthias aka @eternalstorms Gansrigler for that smart hint!).
            NSInteger currentChangeCount = [NSPasteboard pasteboardWithName:NSDragPboard].changeCount;
            if (_pbChangeCount == currentChangeCount) {
                return;
            }

            if (!_proximityDragCollisionHandled) {
                if (wSelf.proximityDragDetectionHandler) {
                    wSelf.proximityDragDetectionHandler(wSelf, eventLocation, CCNProximityDragStatusEntered);
                    _proximityDragCollisionHandled = YES;
                    _pbChangeCount = currentChangeCount;
                }
            }
        }
        else {
            if (_proximityDragCollisionHandled) {
                if (wSelf.proximityDragDetectionHandler) {
                    wSelf.proximityDragDetectionHandler(wSelf, eventLocation, CCNProximityDragStatusExited);
                    _proximityDragCollisionHandled = NO;
                    _pbChangeCount--;
                }
            }
        }
    }];
}

- (void)disableDragEventMonitor {
    [NSEvent removeMonitor:_globalDragEventMonitor];
    _globalDragEventMonitor = nil;
}


#pragma mark - Handling the Status Item Window

- (void)showStatusItemWindow {
    [self.statusItemWindowController showStatusItemWindow];
}

- (void)dismissStatusItemWindow {
    [self.statusItemWindowController dismissStatusItemWindow];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:CCNStatusItemFrameKeyPath]) {
        [self configureProximityDragCollisionArea];
    }
    else if ([keyPath isEqualToString:CCNStatusItemWindowConfigurationPinnedPath]) {
        if ([change[NSKeyValueChangeOldKey] integerValue] == NSOffState) {
            [self disableDragEventMonitor];
        }
        else {
            [self dismissStatusItemWindow];
            if (self.proximityDragDetectionEnabled) {
                [self enableDragEventMonitor];
            }
        }
    }
}

@end




#pragma mark - Deprecated

@implementation CCNStatusItem (CCNStatusItemDeprecated)

+ (void)presentStatusItemWithImage:(NSImage *)itemImage contentViewController:(NSViewController *)contentViewController {
    [[self class] presentStatusItemWithImage:itemImage contentViewController:contentViewController dropHandler:nil];
}

+ (void)presentStatusItemWithImage:(NSImage *)itemImage contentViewController:(NSViewController *)contentViewController dropHandler:(CCNStatusItemDropHandler)dropHandler {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    if (sharedItem.presentationMode == CCNStatusItemPresentationModeUndefined) {
        sharedItem.dropHandler = dropHandler;
        [sharedItem configureWithImage:itemImage];
        [sharedItem configureProximityDragCollisionArea];
        sharedItem.presentationMode = CCNStatusItemPresentationModeImage;
        sharedItem.statusItemWindowController = [[CCNStatusItemWindowController alloc] initWithConnectedStatusItem:sharedItem
                                                                                             contentViewController:contentViewController
                                                                                               windowConfiguration:sharedItem.windowConfiguration];
    }
}

+ (void)presentStatusItemWithView:(NSView *)itemView contentViewController:(NSViewController *)contentViewController {
    [[self class] presentStatusItemWithView:itemView contentViewController:contentViewController dropHandler:nil];
}

+ (void)presentStatusItemWithView:(NSView *)itemView contentViewController:(NSViewController *)contentViewController dropHandler:(CCNStatusItemDropHandler)dropHandler {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    if (sharedItem.presentationMode == CCNStatusItemPresentationModeUndefined) {
        sharedItem.dropHandler = dropHandler;
        [sharedItem configureWithView:itemView];
        [sharedItem configureProximityDragCollisionArea];
        sharedItem.presentationMode = CCNStatusItemPresentationModeCustomView;
        sharedItem.statusItemWindowController = [[CCNStatusItemWindowController alloc] initWithConnectedStatusItem:sharedItem
                                                                                             contentViewController:contentViewController
                                                                                               windowConfiguration:sharedItem.windowConfiguration];
    }
}

+ (void)setWindowConfiguration:(CCNStatusItemWindowConfiguration *)configuration {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    sharedItem.windowConfiguration = configuration;
}

@end

