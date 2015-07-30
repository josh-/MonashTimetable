//
//  UniversityClass.m
//  MonashTimetable
//
//  Created by Josh Parnham on 28/06/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

#import "UniversityClass.h"

@implementation UniversityClass

- (instancetype)initWithUser:(id<SCKUser>)user title:(NSString *)title duration:(NSNumber *)duration scheduledDate:(NSDate *)scheduledDate location:(NSString *)location unitTitle:(NSString *)unitTitle
{
    self = [super init];
    if (self) {
        self.eventType = SCKEventTypeDefault;
        self.patient = nil;
        
        self.title = title;
        self.duration = duration;
        self.scheduledDate = scheduledDate;
        self.location = location;
        self.unitTitle = unitTitle;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithUser:nil title:nil duration:nil scheduledDate:nil location:nil unitTitle:nil];
}

#pragma mark - Methods

- (NSString *)unitCode
{
    if (self.title) {
        // Should match regex: ([A-Z]){3}([0-9]){4}
        return [self.title componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]][0];
    }
    return nil;
}

@end
