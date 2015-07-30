//
//  CredentialsManager.h
//  MonashTimetable
//
//  Created by Josh Parnham on 8/05/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

@import Foundation;

@interface CredentialsManager : NSObject

- (void)authenticateCredentials:(NSString *)username password:(NSString *)password;

+ (NSString *)normalisedUsername:(NSString *)username;
+ (BOOL)userLoggedIn;
+ (BOOL)validPortalAuthentication;
+ (NSString *)portalAuthentication;

@end
