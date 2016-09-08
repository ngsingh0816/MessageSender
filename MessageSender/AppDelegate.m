//
//  AppDelegate.m
//  MessageSender
//
//  Created by Neil Singh on 8/30/16.
//  Copyright © 2016 Neil Singh. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

@synthesize contacts;
@synthesize message;
@synthesize messageLabel;
@synthesize progress;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	[ [ contacts tableColumns ][0] setIdentifier:@"First" ];
	[ [ contacts tableColumns ][1] setIdentifier:@"Last" ];
	[ [ contacts tableColumns ][2] setIdentifier:@"Phone" ];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (IBAction) importContacts:(id)sender {
	NSOpenPanel* openPanel = [ NSOpenPanel openPanel ];
	[ openPanel setAllowedFileTypes:@[ @"csv" ] ];
	[ openPanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
		if (result != NSFileHandlingPanelOKButton)
			return;
		
		NSString* fileData = [ [ NSString alloc ] initWithContentsOfURL:[ openPanel URLs ][0] encoding:NSASCIIStringEncoding error:nil ];
		NSArray* lines = [ fileData componentsSeparatedByString:@"\n" ];
		
		if ([ lines count ] < 2)
			return;
		
		NSMutableArray* items = [ NSMutableArray array ];
		for (unsigned long z = 1; z < [ lines count ]; z++) {
			NSMutableArray* line = [ NSMutableArray arrayWithArray:[ lines[z] componentsSeparatedByString:@"," ] ];
			if ([ line count ] < 3)
				continue;
			if ([ line[2] length ] == 0 || ([ line[0] length ] == 0 && [ line[1] length ] == 0))
				continue;
			
			unsigned long pos = [ line[0] rangeOfString:@" " ].location;
			if (pos != NSNotFound) {
				if ([ line[1] length ] == 0)
					line[1] = [ line[0] substringFromIndex:pos + 1 ];
				line[0] = [ line[0] substringToIndex:pos ];
			}
			[ items addObject:@{ @"First" : line[0], @"Last" : line[1], @"Phone" : line[2] } ];
		}
		
		[ contacts setItems:items ];
	} ];
}

- (IBAction) sendMessage:(id)sender {
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Confirm"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setMessageText:@"Confirm sending messages?"];
	[alert setInformativeText:[ NSString stringWithFormat:@"If you press confirm, you will be sending %lu messages. Make sure everything is right.", [ contacts numberOfRowsInTableView:contacts ] ]];
	[alert setAlertStyle:NSWarningAlertStyle];
	
	[ progress setDoubleValue:0 ];
	[ progress setMaxValue:[ [ contacts items ] count ] ];
	[ alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
		NSMutableArray* items = [ contacts items ];
		for (unsigned long z = 0; z < [ items count ]; z++) {
			NSMutableString* formattedString = [ NSMutableString stringWithString:[ message string ] ];
			NSDictionary* item = items[z];
			if ([ item[@"Phone"] length ] == 0)
				continue;
			[ formattedString replaceOccurrencesOfString:@"%first" withString:item[@"First"] options:0 range:NSMakeRange(0, [ formattedString length ]) ];
			[ formattedString replaceOccurrencesOfString:@"%last" withString:item[@"Last"] options:0 range:NSMakeRange(0, [ formattedString length ]) ];
			
			NSString* script = [ NSString stringWithFormat:@"tell application \"Messages\"\n\
								\tsend \"%@\" to buddy \"%@\" of service \"SMS\"\n\
								end tell", formattedString, item[@"Phone"] ];
			NSAppleScript* scriptObject = [ [ NSAppleScript alloc ] initWithSource:script ];
			NSDictionary* error = nil;
			[ scriptObject executeAndReturnError:&error ];
			if (error)
				NSLog(@"%@ - %@ %@, %@", error, item[@"First"], item[@"Last"], item[@"Phone"]);
			
			[ messageLabel setStringValue:[ NSString stringWithFormat:@"Messages %lu/%lu", z+1, [ items count ] ] ];
			[ progress setDoubleValue:z+1 ];
			
			sleep(1);
		}
	} ];
}

@end
