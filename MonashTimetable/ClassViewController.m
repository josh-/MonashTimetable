//
//  ClassViewController.m
//  MonashTimetable
//
//  Created by Josh Parnham on 26/07/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

#import "ClassViewController.h"

#import "UnitColorManager.h"

@implementation ClassViewController

- (instancetype)initWithUniversityClass:(UniversityClass *)class
{
    // This call may not work on pre-Yosemite systems – see comments on API
    self = [super initWithNibName:nil bundle:[NSBundle mainBundle]];
    if (self) {
        if (class) {
            self.classTitle = class.title;
            self.classDuration = [NSString stringWithFormat:@"%@ Minutes", [class.duration stringValue]];
            self.classLocation = class.location;
            self.classDescription = class.unitTitle;
            self.unitCode = class.unitCode;
        }
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithUniversityClass:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithUniversityClass:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.stringValue = self.classTitle ? self.classTitle : @"";
    self.durationLabel.stringValue = self.classDuration ? self.classDuration : @"";
    self.locationLabel.stringValue = self.classLocation ? self.classLocation : @"";
    self.descriptionLabel.stringValue = self.classDescription ? self.classDescription : @"";
}

#pragma mark - Getters

- (NSColor *)classColor
{
    return [UnitColorManager colorForUnitCode:self.unitCode];
}

#pragma mark - Setters

- (void)setClassColor:(NSColor *)sender
{
    [UnitColorManager storeColor:sender forUnitCode:self.unitCode];
}

@end