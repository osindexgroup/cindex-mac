//
//  SplashWindowController.h
//  Cindex
//
//  Created by PL on 9/25/05.
//  Copyright 2005 Indexing Research. All rights reserved.
//

@interface SplashWindowController : NSWindowController <NSWindowDelegate>{
	IBOutlet NSImageView * sview;
	IBOutlet NSTextField * version;
	IBOutlet NSTextField * tf1;
	IBOutlet NSTextField * tf2;
	IBOutlet NSTextField * tf3;
	
	IBOutlet NSPanel * licensepanel;
	IBOutlet NSTextField * lf1;
	IBOutlet NSTextField * lf2;
	IBOutlet NSTextField * lf3;
	
	IBOutlet NSButton * okbutton;
	
	IBOutlet NSPanel * creditpanel;
	IBOutlet NSTextView * creditview;
	IBOutlet NSButton * credits;
}
+ (void)showWithButton:(BOOL)button;
- (IBAction)showCredits:(id)sender;
- (IBAction)closeCredits:(id)sender;

@end
