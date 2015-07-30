//
//  UniversityClass.h
//  MonashTimetable
//
//  Created by Josh Parnham on 28/06/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

@import Foundation;
@import ScheduleKit;

@interface UniversityClass : NSObject <SCKEvent>

- (instancetype)initWithUser:(id<SCKUser>)user title:(NSString *)title duration:(NSNumber *)duration scheduledDate:(NSDate *)scheduledDate location:(NSString *)location unitTitle:(NSString *)unitTitle;

@property SCKEventType eventType;
@property id<SCKUser> user;
@property id patient;
@property NSString *title;
@property NSNumber *duration;
@property NSDate *scheduledDate;
@property NSString *location;
@property NSString *unitTitle;

@property (readonly) NSString *unitCode;

@end
