//
//  AppDelegate.h
//  MessageSender
//
//  Created by Neil Singh on 8/30/16.
//  Copyright © 2016 Neil Singh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TableWindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property IBOutlet TableWindow* contacts;
@property IBOutlet NSTextView* message;
@property IBOutlet NSTextField* messageLabel;
@property IBOutlet NSProgressIndicator* progress;

- (IBAction) importContacts:(id)sender;
- (IBAction) sendMessage:(id)sender;

@end

