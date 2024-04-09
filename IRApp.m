//
//  IRApp.m
//  Cindex
//
//  Created by PL on 9/3/05.
//  Copyright 2005 Indexing Research. All rights reserved.
//

#import "IRApp.h"
#import "IRIndexDocument.h"
#import "IRIndexDocumentController.h"
#import "IRIndexDocWController.h"
#import "SplashWindowController.h"

@implementation IRApp

- (void)terminate:(id)sender {
	// do this cleanup here because [IRdc applicationShouldTerminate] is called *after*
	// doccontroller handles any dirty documents.
	
    IRIndexDocument * doc = [(IRIndexDocumentController *)[self delegate] currentDocument];
    NSArray * docarray = [(IRIndexDocumentController *)[self delegate] documents];

	if ([[doc fileType] isEqualToString:CINIndexType])	// if have current index doc
		[[NSUserDefaults standardUserDefaults] setObject:[[doc fileURL] path] forKey:CILastIndex];	// save it as last used
	for (NSInteger index = [docarray count]; --index >= 0;)
		[[[[docarray objectAtIndex:index] mainWindowController] window] performClose:self];
	[[NSPasteboard pasteboardWithName:NSPasteboardNameDrag] clearContents];		// terminate calls Pboard to deliver any promised data
	[super terminate:sender];
}
- (void)orderFrontStandardAboutPanel:(id)sender {
	[SplashWindowController showWithButton:YES];
}
@end
