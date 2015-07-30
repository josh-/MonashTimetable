//
//  TimetableManager.m
//  MonashTimetable
//
//  Created by Josh Parnham on 8/05/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

#import "TimetableManager.h"

#import "CredentialsManager.h"
#import "MXLCalendarManager.h"
#import "SSKeychain.h"

#import "NSFileManager+ApplicationSupport.h"

#define TIMETABLE_FILENAME @"timetable.ics"

@implementation TimetableManager

- (void)manageTimetable
{
    NSString *filepath = [[NSFileManager applicationSupportDirectory] stringByAppendingPathComponent:TIMETABLE_FILENAME];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        [self processTimetableAtPath:filepath];
    }
    else {
        [self downloadTimetable];
    }
}

- (void)downloadTimetable
{
    if ([self.delegate respondsToSelector:@selector(timetableManagerDidStartDownloadingTimetable)]) {
        [self.delegate timetableManagerDidStartDownloadingTimetable];
    }
    
    if ([CredentialsManager validPortalAuthentication]) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://my.monash.edu.au/json/app/"]];
        
        [request setValue:[CredentialsManager portalAuthentication] forHTTPHeaderField:@"Cookie"];
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSError *jsonError;
            NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            if (!jsonError) {
                NSString *timetableICalFeedURL = appData[@"timetableICalFeedUrl"];
                
                NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:[NSURL URLWithString:timetableICalFeedURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (error) {
                        NSLog(@"%@", error.localizedDescription);
                    }
                    
                    NSString *filepath = [[NSFileManager applicationSupportDirectory] stringByAppendingPathComponent:TIMETABLE_FILENAME];
                    NSError *writeError;
                    [data writeToFile:filepath options:NSDataWritingAtomic error:&writeError];
                    if (!writeError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([self.delegate respondsToSelector:@selector(timetableManagerDidFinishDownloadingTimetable)]) {
                                [self.delegate timetableManagerDidFinishDownloadingTimetable];
                            }
                            [self processTimetableAtPath:filepath];
                        });
                    }
                    else {
                        NSLog(@"Error writing ICS file to filepath.");
                    }
                }];
                [dataTask resume];
            }
            else {
                NSLog(@"Parsing JSON returned an error. Signing out.");
                [self signOut];
            }
        }];
        [dataTask resume];
    }
    else {
        NSLog(@"Nil MonashPortalAuthentication cookie. Signing out.");
        // TODO: Regenerage portalAuthenticationCookie based on stored credentials
        [self signOut];
    }
}

- (void)processTimetableAtPath:(NSString *)path
{
    NSMutableArray *classArray = [[NSMutableArray alloc] init];
    
    MXLCalendarManager *calendarManager = [[MXLCalendarManager alloc] init];
    [calendarManager scanICSFileAtLocalPath:path withCompletionHandler:^(MXLCalendar *calendar, NSError *error)
     {
         if (!error) {
             for (MXLCalendarEvent *event in calendar.events) {
                 NSNumber *duration = [NSNumber numberWithInt:([event.eventEndDate timeIntervalSinceDate:event.eventStartDate])/60];
                 
                 UniversityClass *class = [[UniversityClass alloc] initWithUser:nil title:event.eventSummary duration:duration scheduledDate:event.eventStartDate location:event.eventLocation unitTitle:event.eventDescription];
                 [classArray addObject:class];
             }
             if ([self.delegate respondsToSelector:@selector(timetableManagerClassesDidBecomeAvailable:)]) {
                 [self.delegate timetableManagerClassesDidBecomeAvailable:classArray];
             }
         }
         else {
             NSLog(@"Error parsing ICS file. Signing out.");
             [self signOut];
         }
     }];
}

- (void)signOut
{
    // Delete credentials and authentication cookie
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    NSArray *accounts = [query fetchAll:nil];
    for (id account in accounts) {
        SSKeychainQuery *usernamePasswordQuery = [[SSKeychainQuery alloc] init];
        usernamePasswordQuery.service = @"Monash";
        usernamePasswordQuery.account = [account valueForKey:@"acct"];
        [usernamePasswordQuery deleteItem:nil];
    }
    [SSKeychain deletePasswordForService:@"MonashPortalAuthentication" account:@"com.joshparnham.Monash"];
    
    // Remove timetable ICS file
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:[[NSFileManager applicationSupportDirectory] stringByAppendingPathComponent:TIMETABLE_FILENAME] error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    // Clear unit colors
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthorizationStatusDidChange" object:nil];
    });
}

@end
