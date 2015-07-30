//
//  TimetableViewController.m
//  MonashTimetable
//
//  Created by Josh Parnham on 8/05/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

#import "TimetableViewController.h"

#import "ClassViewController.h"
#import "UniversityClass.h"
#import "UnitColorManager.h"

#import "NSDate+DateBetween.h"
#import "NSGeometry+Additions.h"
#import "NSEvent+KeyCodes.h"

@interface TimetableViewController ()

@property (strong, nonatomic) NSArray *classes;

@property (strong, nonatomic) TimetableManager *timetableManager;

@end

@implementation TimetableViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSEvent *(^monitorHandler)(NSEvent *);
        monitorHandler = ^NSEvent *(NSEvent *event){
            switch (event.keyCode) {
                // Handle left & right keys to move the weekView between weeks
                case NSEventKeyCodeLeft:
                    [self.weekView decreaseWeekOffset:self];
                    break;
                case NSEventKeyCodeRight:
                    [self.weekView increaseWeekOffset:self];
                    break;
                // Handle ⌘+ & ⌘- to magnify and shrink the weekview
                case NSEventKeyCodeEquals:
                    if (event.modifierFlags & NSCommandKeyMask) {
                        [self.weekView increaseZoomFactor:self];
                    }
                    break;
                case NSEventKeyCodeMinus:
                    if (event.modifierFlags & NSCommandKeyMask) {
                        [self.weekView decreaseZoomFactor:self];
                    }
                    break;
                default:
                    break;
            }
            return event;
        };
        
        id eventMonitor __unused = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:monitorHandler];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithNibName:nil bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.weekEventManager.view = self.weekView;
//    ((SCKWeekView *)self.view).eventManager = self.weekEventManager;
    self.weekView.eventManager = self.weekEventManager;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *weekBeginning;
    [calendar rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&weekBeginning interval:nil forDate:[NSDate date]];
    NSDate *weekEnding = [calendar dateByAddingUnit:NSCalendarUnitWeekOfYear value:1 toDate:weekBeginning options:0];
    
    self.weekEventManager.view.startDate = weekBeginning;
    self.weekEventManager.view.endDate = weekEnding;
    
    self.weekEventManager.dataSource = self;
    self.weekEventManager.delegate = self;
    
    [self.weekEventManager reloadData];
    
    ((SCKWeekView *)self.weekEventManager.view).delegate = self;
    
    ((SCKWeekView *)self.weekEventManager.view).colorMode = SCKEventColorModeAskForEachEvent;
    
    self.timetableManager = [[TimetableManager alloc] init];
    self.timetableManager.delegate = self;
    [self.timetableManager manageTimetable];
}

#pragma mark - Actions

- (IBAction)changeWeekOffset:(id)sender
{
    switch (((NSSegmentedControl*)sender).selectedSegment) {
        case 0:
            [self.weekView decreaseWeekOffset:sender];
            break;
        case 1:
            [self.weekView increaseWeekOffset:sender];
            break;
    }
}

- (IBAction)refreshTimetable:(id)sender
{
    [self.timetableManager downloadTimetable];
}

- (IBAction)signOut:(id)sender;
{
    [self.timetableManager signOut];
}

#pragma mark - Week view delegate
- (NSInteger)dayStartHourForWeekView:(SCKWeekView*)wView
{
    return 8;
}

- (NSInteger)dayEndHourForWeekView:(SCKWeekView*)wView
{
    return 20;
}

#pragma mark - Event manager data source
- (NSArray *)eventManager:(SCKEventManager *)eM requestsEventsBetweenDate:(NSDate*)sD andDate:(NSDate*)eD
{
    NSMutableArray *classesToDisplay = [[NSMutableArray alloc] init];
    for (UniversityClass *class in self.classes) {
        if ([NSDate date:class.scheduledDate isBetweenDate:sD andDate:eD]) {
            [classesToDisplay addObject:class];
        }
    }
    return classesToDisplay;
}

- (NSColor *)eventManager:(SCKEventManager *)eM colorForEvent:(id <SCKEvent>)event
{
    return [UnitColorManager colorForUnitCode:((UniversityClass *)event).unitCode];
}

#pragma mark - Event manager delegate

- (void)eventManager:(SCKEventManager *)eM didDoubleClickEvent:(id<SCKEvent>)e
{
    NSPopover *popover = [[NSPopover alloc] init];
    ClassViewController *classViewController = [[ClassViewController alloc] initWithUniversityClass:e];
    popover.contentViewController = classViewController;
    popover.behavior = NSPopoverBehaviorTransient;
    
    NSPoint mouseLocation = [NSEvent mouseLocation];
    NSPoint windowLocation = NSPointFromRect([[self.weekView window] convertRectFromScreen:NSRectFromPoint(mouseLocation)]);
    NSPoint viewLocation = [self.weekView convertPoint:windowLocation fromView:nil];
    if(NSPointInRect(viewLocation, [self.weekView bounds])) {
        [popover showRelativeToRect:NSMakeRect(viewLocation.x, viewLocation.y, 10, 10) ofView:self.weekView preferredEdge:NSMaxXEdge];
    }
}

- (BOOL)eventManager:(SCKEventManager *)eM shouldChangeLengthOfEvent:(id <SCKEvent>)e fromValue:(NSInteger)oV toValue:(NSInteger)fV
{
    return NO;
}

- (BOOL)eventManager:(SCKEventManager *)eM shouldChangeDateOfEvent:(id <SCKEvent>)e fromValue:(NSDate*)oD toValue:(NSDate*)fD
{
    return NO;
}

- (BOOL)eventManager:(SCKEventManager *)eM shouldAllowChangesToEvent:(id <SCKEvent>)e
{
    return NO;
}

#pragma mark - Timetable manager delegate

- (void)timetableManagerDidStartDownloadingTimetable
{
    self.statusButton.title = @"Downloading Timetable...";
}

- (void)timetableManagerDidFinishDownloadingTimetable
{
    self.statusButton.title = @"";
}

- (void)timetableManagerClassesDidBecomeAvailable:(NSArray *)classes
{
    self.classes = classes;
    
    [self.weekEventManager reloadData];
}

@end
