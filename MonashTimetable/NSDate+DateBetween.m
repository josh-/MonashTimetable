//
//  NSDate+DateBetween.m
//  MonashTimetable
//
//  Created by Josh Parnham on 24/07/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

#import "NSDate+DateBetween.h"

@implementation NSDate (NSDate_DateBetween)

// From http://stackoverflow.com/a/1072993/446039
+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
}

@end
