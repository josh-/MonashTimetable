//
//  TimetableViewController.h
//  MonashTimetable
//
//  Created by Josh Parnham on 8/05/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

@import Cocoa;
@import ScheduleKit;

#import "TimetableManager.h"

@interface TimetableViewController : NSViewController <SCKWeekViewDelegate, SCKEventManagerDataSource, SCKEventManagerDelegate, TimetableManagerDelegate>

@property (weak) IBOutlet SCKEventManager *weekEventManager;
@property IBOutlet SCKWeekView *weekView;

@property (weak) IBOutlet NSButton *statusButton;

- (IBAction)refreshTimetable:(id)sender;
- (IBAction)signOut:(id)sender;

@end
