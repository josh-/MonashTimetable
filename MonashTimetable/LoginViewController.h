//
//  LoginViewController.h
//  MonashTimetable
//
//  Created by Josh Parnham on 8/05/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

@import Cocoa;

@interface LoginViewController : NSViewController <NSTextFieldDelegate>

@property (weak) IBOutlet NSTextField *usernameTextField;
@property (weak) IBOutlet NSTextField *passwordTextField;
@property (weak) IBOutlet NSButton *loginButton;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

- (IBAction)login:(id)sender;

@end
