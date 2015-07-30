//
//  CredentialsManager.m
//  MonashTimetable
//
//  Created by Josh Parnham on 8/05/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

#import "CredentialsManager.h"

#import "SSKeychain.h"

@implementation CredentialsManager

- (void)authenticateCredentials:(NSString *)username password:(NSString *)password
{
    username = [self.class normalisedUsername:username];
    
    NSURL *monashUrl = [NSURL URLWithString:@"https://my.monash.edu.au"];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *myMonashDataTask = [urlSession dataTaskWithURL:monashUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:response.URL];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
        
        NSString *authenticationBodyString = [NSString stringWithFormat:@"AuthMethod=FormsAuthentication&Kmsi=true&Password=%@&UserName=Monash\\%@", [password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSData *postBody = [authenticationBodyString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:postBody];
        
        NSURLSessionDataTask *cookieDataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *portalAuthenticationCookie = ((NSHTTPURLResponse *)response).allHeaderFields[@"Set-Cookie"];
            
            if (portalAuthenticationCookie) {
                [self storeCredentials:username password:password];
                [self storeToken:portalAuthenticationCookie];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthorizationStatusDidChange" object:nil];
                    });
            }
            else {
                NSLog(@"Unable to authenticate with the specified credentials.");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthorizationDidFail" object:nil];
                });
            }
        }];
        [cookieDataTask resume];
    }];
    [myMonashDataTask resume];
}

- (void)storeCredentials:(NSString *)username password:(NSString *)password
{
    [SSKeychain setPassword:password forService:@"Monash" account:username];
}

- (void)storeToken:(NSString *)token
{
    [SSKeychain setPassword:token forService:@"MonashPortalAuthentication" account:@"com.joshparnham.Monash"];
}

#pragma mark - Class methods

+ (NSString *)normalisedUsername:(NSString *)username
{
    NSMutableString *normalisedUsername = [username mutableCopy];
    
    NSRange emailRange = [normalisedUsername rangeOfString:@"@"];
    if (!(emailRange.location == NSNotFound)) {
        [normalisedUsername deleteCharactersInRange:NSMakeRange(emailRange.location, (normalisedUsername.length - emailRange.location))];
    }
    
    NSRange backslashRange = [normalisedUsername rangeOfString:@"\\"];
    if (!(backslashRange.location == NSNotFound)) {
        [normalisedUsername deleteCharactersInRange:NSMakeRange(0, backslashRange.location+1)];
    }
    
    return (NSString *)normalisedUsername;
}

+ (BOOL)userLoggedIn
{
    NSArray *accounts = [SSKeychain accountsForService:@"Monash"];
    if (accounts) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)validPortalAuthentication
{
    NSString *portalAuthenticationCookie = [SSKeychain passwordForService:@"MonashPortalAuthentication" account:@"com.joshparnham.Monash"];
    if (portalAuthenticationCookie) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (NSString *)portalAuthentication
{
    return [SSKeychain passwordForService:@"MonashPortalAuthentication" account:@"com.joshparnham.Monash"];
}

@end
