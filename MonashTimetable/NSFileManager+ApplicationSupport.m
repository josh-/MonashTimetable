//
//  NSFileManager+ApplicationSupport.m
//  MonashTimetable
//
//  Created by Josh Parnham on 26/07/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

#import "NSFileManager+ApplicationSupport.h"

@implementation NSFileManager (NSFileManager_ApplicationSupport)

+ (NSString *)appBundleName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
}

+ (NSString *)applicationSupportDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportPath = [paths[0] stringByAppendingPathComponent:[NSFileManager appBundleName]];
    
    BOOL directory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:applicationSupportPath isDirectory:&directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:applicationSupportPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [paths[0] stringByAppendingPathComponent:[NSFileManager appBundleName]];
}

@end
