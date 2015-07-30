//
//  ContentViewController.m
//  CCNStatusItemView Example
//
//  Created by Frank Gregor on 28.12.14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

#import "ContentViewController.h"
#import "ContentView2Controller.h"
#import "CCNStatusItem.h"
#import "AppDelegate.h"

@interface ContentViewController ()
@end

@implementation ContentViewController

+ (instancetype)viewController {
    return [[[self class] alloc] initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (IBAction)quitButtonAction:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (IBAction)switchContentViewControllerAction:(id)sender {
    [[CCNStatusItem sharedInstance] updateContentViewController:[ContentView2Controller viewController]];
}

- (CGSize)preferredContentSize {
    return self.view.frame.size;
}

@end
