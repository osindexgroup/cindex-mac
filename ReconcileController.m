//
//  ReconcileController.m
//  Cindex
//
//  Created by PL on 1/9/05.
//  Copyright 2005 Indexing Research. All rights reserved.
//

#import "ReconcileController.h"
#import "IRIndexTextWController.h"
#import "AttributedStringCategories.h"
#import "tools.h"
#import "commandutils.h"
#import "strings_c.h"
#import "records.h"

//static int tabset[] = {-40,48,100,0};

@implementation ReconcileController
- (void)awakeFromNib {
	[super awakeFromNib];
	FF = [[self document] iIndex];
	int count;

	[headings removeAllItems];
	for (count = 0; count < FF->head.indexpars.maxfields-1; count++)	/* for all fields */
		[headings addItemWithTitle:[NSString stringWithCString:FF->head.indexpars.field[count].name encoding:NSUTF8StringEncoding]];
	[phrasechar setStringValue:@","];
	if (!sort_isinfieldorder(FF->head.sortpars.fieldorder,FF->head.indexpars.maxfields))	/* if isn't straight field order */
		[preservemodified setEnabled:NO];	// disable splitting
	[protectnames setState:YES];
}
- (IBAction)showHelp:(id)sender {
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"reconcile0_Anchor-14210" inBook:@"Cindex 4 Help"];
}
- (void)windowDidUpdate:(NSNotification *)aNotification {
	[phrasechar setEnabled:YES];
	[preservemodified setEnabled:YES];
	[protectnames setEnabled:YES];
	[handleorphans setEnabled:YES];
}
- (IBAction)closeSheet:(id)sender {    
	if ([sender tag] == OKTAG)	{
		JOINPARAMS tjn;
		RECN markcount;
		
		if (![[self window] makeFirstResponder:[self window]])	// if a bad field
			return;
		memset(&tjn,0,sizeof(tjn));
		tjn.firstfield = [headings indexOfSelectedItem];
		tjn.protectnames = [protectnames state];
		tjn.orphanaction = [[handleorphans selectedCell] tag];
		tjn.nosplit = [preservemodified state];
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTE_GLOBALLYCHANGING object:[self document]];
		tjn.jchar = *[[phrasechar stringValue] UTF8String];
		tjn.orphancount = 0;
		if (markcount = tool_join(FF, &tjn))
			errorSheet([self.document windowForSheet], RECMARKERR,WARN, markcount);
		[[self document] redisplay:0 mode:0];	// redisplay all records
	}
	[self.window.sheetParent endSheet:self.window returnCode:[sender tag]];
}
- (void)controlTextDidChange:(NSNotification *)note	{
	NSControl * control = [note object];

	checktextfield(control,2);
	if (!ispunct(*[[control stringValue] UTF8String]))
		[control setStringValue:@""];
}
@end
