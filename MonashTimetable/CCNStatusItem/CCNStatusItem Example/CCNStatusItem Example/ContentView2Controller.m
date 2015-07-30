//
//  ContentView2Controller.m
//  CCNStatusItem Example
//
//  Created by im61 on 4/25/15.
//  Copyright (c) 2015 cocoa:naut. All rights reserved.
//

#import "ContentView2Controller.h"

@interface ContentView2Controller ()

@end

@implementation ContentView2Controller

+ (instancetype)viewController {
    return [[[self class] alloc] initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (IBAction)quitButtonAction:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (CGSize)preferredContentSize {
    return self.view.frame.size;
}

@end
