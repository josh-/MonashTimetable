//
//  LaunchManager.m
//  MonashTimetable
//
//  Created by Josh Parnham on 28/07/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

#import "LaunchManager.h"

@implementation LaunchManager

- (NSURL *)appURL
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

- (BOOL)launchAtLogin
{
    return [JPLaunchAtLoginManager willStartAtLogin:[self appURL]];
}

- (void)setLaunchAtLogin:(BOOL)launchAtLogin
{
    [JPLaunchAtLoginManager setStartAtLogin:[self appURL] enabled:launchAtLogin];
}

@end
