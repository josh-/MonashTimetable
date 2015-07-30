//
//  NSDate+DateBetween.h
//  MonashTimetable
//
//  Created by Josh Parnham on 24/07/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSDate (NSDate_DateBetween)

+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;

@end
