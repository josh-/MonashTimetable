//
//  UnitColorManager.m
//  MonashTimetable
//
//  Created by Josh Parnham on 28/07/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

#import "UnitColorManager.h"

#import "NSColor+DefaultColor.h"

@implementation UnitColorManager

+ (NSColor *)colorForUnitCode:(NSString *)unitCode
{
    NSData *colorArchive = [[NSUserDefaults standardUserDefaults] dataForKey:unitCode];
    if (colorArchive != nil) {
        return (NSColor *)[NSUnarchiver unarchiveObjectWithData:colorArchive];
    }
    return [NSColor defaultClassColor];
}

+ (void)storeColor:(NSColor *)color forUnitCode:(NSString *)unitCode
{
    NSData *colorArchive = [NSArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorArchive forKey:unitCode];
}

@end
