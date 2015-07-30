//
//  UnitColorManager.h
//  MonashTimetable
//
//  Created by Josh Parnham on 28/07/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

@import Cocoa;

@interface UnitColorManager : NSObject

+ (NSColor *)colorForUnitCode:(NSString *)unitCode;
+ (void)storeColor:(NSColor *)color forUnitCode:(NSString *)unitCode;

@end
