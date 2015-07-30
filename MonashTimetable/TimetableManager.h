//
//  TimetableManager.h
//  MonashTimetable
//
//  Created by Josh Parnham on 8/05/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

@import Foundation;

#import "UniversityClass.h"

@protocol TimetableManagerDelegate <NSObject>

- (void)timetableManagerDidStartDownloadingTimetable;
- (void)timetableManagerDidFinishDownloadingTimetable;

/** Called when the timetable has finished being parsed and an array of UniversityClass objects is available. */
- (void)timetableManagerClassesDidBecomeAvailable:(NSArray *)classes;

@end

@interface TimetableManager : NSObject

@property (weak, nonatomic) id<TimetableManagerDelegate> delegate;

/** Checks if a timetable has already been downloaded. If so, starts processing it. If no timetable is found on disk, it triggers a download of the timetable. */
- (void)manageTimetable;

/** Downloads a user's timetable and caches it to disk. */
- (void)downloadTimetable;

/** Parses a ICS file and creates an array of UniversityClass objects that are sent to the delegate method.
 @see timetableManagerClassesDidBecomeAvailable:
 @param path A NSString filepath of a valid ICS file. */
- (void)processTimetableAtPath:(NSString *)path;

/** Removes a users credentials, authentication token, timetable file and unit colors. */
- (void)signOut;

@end
