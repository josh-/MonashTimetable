//
//  LoginViewController.m
//  MonashTimetable
//
//  Created by Josh Parnham on 8/05/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

#import "LoginViewController.h"
#import "CredentialsManager.h"

@implementation LoginViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authorizationDidFail) name:@"AuthorizationDidFail" object:nil];
    self.view.window.initialFirstResponder = self.usernameTextField;
}

#pragma mark - Methods

- (IBAction)login:(NSButton *)sender
{
    [self setUserIsLoggingIn:YES];
    
    CredentialsManager *credentialsManager = [[CredentialsManager alloc] init];
    [credentialsManager authenticateCredentials:self.usernameTextField.stringValue password:self.passwordTextField.stringValue];
}

- (void)setUserIsLoggingIn:(BOOL)loggingIn
{
    self.loginButton.enabled = !loggingIn;
    
    self.usernameTextField.enabled = !loggingIn;
    self.passwordTextField.enabled = !loggingIn;
    
    self.progressIndicator.hidden = !loggingIn;
    
    if (loggingIn) {
        [self.progressIndicator startAnimation:nil];
    }
    else {
        [self.progressIndicator stopAnimation:nil];
    }
}

#pragma mark - Notification response

- (void)authorizationDidFail
{
    [self setUserIsLoggingIn:NO];
    [self.passwordTextField becomeFirstResponder];
}

#pragma mark - Text delegate

- (void)controlTextDidChange:(NSNotification *)notification
{
    if (self.usernameTextField.stringValue.length && self.passwordTextField.stringValue.length) {
        self.loginButton.enabled = YES;
    }
    else {
        self.loginButton.enabled = NO;
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
{
    if (commandSelector == @selector(insertNewline:)) {
        // Perform login when user presses "return"
        if (self.usernameTextField.stringValue.length > 0 && self.passwordTextField.stringValue.length > 0) {
            [self login:self];
        }
        return YES;
    }
    else if (commandSelector == @selector(insertTab:)) {
        // Hack to prevent "this method is supposed to only be invoked on top level items" exception
        [self.passwordTextField becomeFirstResponder];
        return YES;
    }
    return NO;
}

@end
