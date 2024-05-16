//
//  HTTPService.m
//  Cindex
//
//  Created by Peter Lennie on 6/12/08; modified 5/7/18
//  Copyright 2008 Indexing Research. All rights reserved.
//

#import "HTTPService.h"
#import "PreferencesController.h"
#import "commandutils.h"

#define kUpdateLastCheck @"lastUpdateCheck"

static NSString * _urlstring = @"https://opencindex.com/.well-known/cinmac.json";

@implementation HTTPService

- (void)check:(id)sender {
	NSDate * lastCheck = [[NSUserDefaults standardUserDefaults] objectForKey:kUpdateLastCheck];
	NSTimeInterval secs = [[NSUserDefaults standardUserDefaults] integerForKey:kUpdateCheckInterval] * 86400;	// seconds between checks
	BOOL checkNow = g_prefs.gen.autoupdate && (!lastCheck || [[NSDate date] timeIntervalSinceDate:lastCheck] > secs);
	if (checkNow || [sender tag] == MI_CHECKUPDATE) {
		NSURL * url = [NSURL URLWithString:_urlstring];
		NSURLSessionDataTask * dtask = [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *cerror) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (!cerror) {
					NSError * error = nil;
					NSDictionary * pdic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
					if (pdic && !error)	{	// if OK
						NSString * currentVersion = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
						NSString * newVersion = pdic[@"version"];
						if ([newVersion compare:currentVersion] == NSOrderedDescending) {	// if new version is higher than current
							NSAlert * uAlert = [[NSAlert alloc] init];
							uAlert.alertStyle = NSAlertStyleInformational;
							uAlert.messageText = pdic[@"title"];
							uAlert.informativeText = pdic[@"message"];
							[uAlert addButtonWithTitle:@"Details…"];
							[uAlert addButtonWithTitle:@"Not Now"];
							uAlert.icon = [NSImage imageNamed:@"cindex"];
							if ([pdic[@"detail"] length]) {
								NSTextView *accessory = [[NSTextView alloc] initWithFrame:NSMakeRect(0,0,200,15)];
								NSFont *font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
								NSDictionary *textAttributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
								[accessory insertText:pdic[@"detail"] replacementRange:NSMakeRange(0,0)];
								[accessory setEditable:NO];
								[accessory setDrawsBackground:NO];
								uAlert.accessoryView = accessory;
							}
							NSModalResponse mr = [uAlert runModal];
							if (mr == NSAlertFirstButtonReturn)
								[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[pdic objectForKey:@"url"]]];
						}
						else if ([sender tag] == MI_CHECKUPDATE)	// user-triggered check
							simpleAlert(nil,NSAlertStyleInformational,@"Cindex is up to date");
					}
				}
			});
		}];
		[dtask resume];
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kUpdateLastCheck];
	}
}
@end
