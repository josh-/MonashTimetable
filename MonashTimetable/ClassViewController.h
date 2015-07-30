//
//  ClassViewController.h
//  MonashTimetable
//
//  Created by Josh Parnham on 26/07/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

@import Cocoa;

#import "UniversityClass.h"

@interface ClassViewController : NSViewController

@property (copy) NSString *classTitle;
@property (copy) NSString *classDuration;
@property (copy) NSString *classLocation;
@property (copy) NSString *classDescription;
@property (copy) NSColor *classColor;
@property (copy) NSString *unitCode;

@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet NSTextField *durationLabel;
@property (weak) IBOutlet NSTextField *locationLabel;
@property (weak) IBOutlet NSTextField *descriptionLabel;
@property (weak) IBOutlet NSColorWell *unitColorWell;

- (instancetype)initWithUniversityClass:(UniversityClass *)class NS_DESIGNATED_INITIALIZER;

@end
