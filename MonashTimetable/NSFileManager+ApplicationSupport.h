//
//  NSFileManager+ApplicationSupport.h
//  MonashTimetable
//
//  Created by Josh Parnham on 26/07/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSFileManager (NSFileManager_ApplicationSupport)

+ (NSString *)applicationSupportDirectory;

@end
