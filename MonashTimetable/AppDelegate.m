//
//  AppDelegate.m
//  MonashTimetable
//
//  Created by Josh Parnham on 7/05/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

#import "AppDelegate.h"

#import "LoginViewController.h"
#import "TimetableViewController.h"

#import "CredentialsManager.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) TimetableViewController *timetableViewController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self addObservations];
    
    self.statusItem = [CCNStatusItem sharedInstance];
    [self presentViewController];
}

#pragma mark - Methods

- (void)addObservations
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authorizationStatusChanged) name:@"AuthorizationStatusDidChange" object:nil];
}

- (void)presentViewController
{
    NSImage *iconImage = [NSImage imageNamed:@"StatusIcon"];
    [iconImage setSize:NSMakeSize(16, 16)];
    
    if ([CredentialsManager userLoggedIn]) {
        [self.statusItem presentStatusItemWithImage:iconImage contentViewController:self.timetableViewController];
    }
    else {
        [self.statusItem presentStatusItemWithImage:iconImage contentViewController:self.loginViewController];
        [self.statusItem showStatusItemWindow];
    }
}

#pragma mark - Notification response

- (void)authorizationStatusChanged
{
    if ([CredentialsManager userLoggedIn]) {
        [self.statusItem updateContentViewController:self.timetableViewController];
    }
    else {
        [self.statusItem updateContentViewController:self.loginViewController];
    }
}

#pragma mark - Getters

- (TimetableViewController *)timetableViewController
{
    if (!_timetableViewController) {
        _timetableViewController = [[TimetableViewController alloc] init];
        _timetableViewController.preferredContentSize = NSMakeSize(500, 500);
    }
    return _timetableViewController;
}

- (LoginViewController *)loginViewController
{
    if (!_loginViewController) {
        _loginViewController = [[LoginViewController alloc] init];
        _loginViewController.preferredContentSize = NSMakeSize(300, 250);
    }
    return _loginViewController;
}

@end
