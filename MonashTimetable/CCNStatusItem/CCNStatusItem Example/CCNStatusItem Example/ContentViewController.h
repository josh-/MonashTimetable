//
//  ContentViewController.h
//  CCNStatusItemView Example
//
//  Created by Frank Gregor on 28.12.14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ContentViewController : NSViewController

+ (instancetype)viewController;

@property (weak) IBOutlet NSButton *quitButton;
@property (weak) IBOutlet NSTabView *tabview;

- (IBAction)quitButtonAction:(id)sender;

@end
