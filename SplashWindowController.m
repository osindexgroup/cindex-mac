//
//  SplashWindowController.m
//  Cindex
//
//  Created by PL on 9/25/05.
//  Copyright 2005 Indexing Research. All rights reserved.
//

#import "SplashWindowController.h"
#import "commandutils.h"

#define BASETIME 3.0
#define FADETIME 2.0
#define TICKTIME 0.05

SplashWindowController * spc;

@interface SplashWindowController () {
	NSTimer * _splashtimer;
	int _ticks;
}
@property (assign) BOOL showButton;
@end

@implementation SplashWindowController
+ (void)showWithButton:(BOOL)button {
	spc = [[SplashWindowController alloc] initWithWindowNibName:@"SplashWController"];
	spc.showButton = button;
	[spc showWindow:nil];
}
- (void)dealloc {
	[_splashtimer invalidate];
}
- (void)awakeFromNib {
	[super awakeFromNib];
	NSBundle * bundle = [NSBundle mainBundle];
	NSString * vString = [NSString stringWithFormat:@"%@ (%@)",[bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"],[bundle objectForInfoDictionaryKey:@"CFBundleVersion"]];
	
	[version setStringValue:vString];
	[version sizeToFit];
	[version setNeedsDisplay];
	[tf1 setStringValue:@"Everyone"];
	[tf2 setStringValue:@"Full Edition"];
	[tf3 setStringValue:@"Unrestricted Use"];
}
- (IBAction)showWindow:(id)sender {
	[[self window] makeFirstResponder:self];
	if (!_showButton)	{
		[credits setHidden:YES];
		_splashtimer = [NSTimer scheduledTimerWithTimeInterval:TICKTIME target:self selector:@selector(changeTransparency:) userInfo:nil repeats:YES];
	}
	[super showWindow:self];
}
- (IBAction)closePanel:(id)sender {
}
- (void)closewhenready {
	if (!creditpanel.isVisible) {
		[_splashtimer invalidate];
		_splashtimer = nil;
		[self close];
		spc = nil;
	}
}
- (void)keyDown:(NSEvent *)theEvent {
	[self closewhenready];
}
- (void)mouseDown:(NSEvent *)theEvent	{
	[self closewhenready];
}
- (void)windowDidResignKey:(NSNotification *)notification {
	[self closewhenready];
}
- (void)changeTransparency:(id)sender {
	float elapsed = ++_ticks*TICKTIME;
	if (elapsed > BASETIME)	{
		if (elapsed < BASETIME+FADETIME)	{
			[[self window] setAlphaValue:1-(elapsed-BASETIME)/FADETIME];
			[[self window] display];		// force redraw
		}
		else {
			[self closewhenready];
		}
	}
}
- (IBAction)showCredits:(id)sender {
	NSData * rtfdata = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"notices" ofType:@"rtf"]];
	[creditview replaceCharactersInRange:NSMakeRange(0, 0) withRTF:rtfdata];
	[creditview.textStorage addAttribute:NSForegroundColorAttributeName value:NSColor.textColor range:NSMakeRange(0, creditview.textStorage.length)];
	[creditpanel setLevel:NSPopUpMenuWindowLevel];
	[NSApp runModalForWindow:creditpanel];
}
- (IBAction)closeCredits:(id)sender {
	[[sender window] orderOut:sender];
	[NSApp stopModal];
	[self close];
}
@end
