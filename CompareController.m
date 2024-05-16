//
//  CompareController.m
//  Cindex
//
//  Created by PL on 7/20/21.
//  Copyright 2021 Indexing Research. All rights reserved.
//

#import "IRIndexDocumentController.h"
#import "indexdocument.h"
#import "CompareController.h"
#import "IRIndexTextWController.h"
#import "tools.h"
#import "commandutils.h"
#import "strings_c.h"
#import "records.h"
#import "search.h"
#import "collate.h"
#import "regex.h"
#import "index.h"

@interface CompareController  () {
	IBOutlet NSPopUpButton * indexList;
	IBOutlet NSPopUpButton * fieldDepth;
	IBOutlet NSTextField * recordsInThis;
	IBOutlet NSTextField * recordsInBoth;
	IBOutlet NSTextField * recordsInImport;
	IBOutlet NSPopUpButton * labelInThis;
	IBOutlet NSPopUpButton * labelInBoth;
	IBOutlet NSPopUpButton * labelInImport;
	IBOutlet NSButton * deleteInThis;
	IBOutlet NSButton * deleteInBoth;
	IBOutlet NSButton * importOther;
	IBOutlet NSButton * groupInThis;
	IBOutlet NSButton * groupInBoth;
	IBOutlet NSButton * groupInOther;
	IBOutlet NSButton * compare;
	IBOutlet NSButton * modify;
	IBOutlet NSStackView * stack;
	IBOutlet NSButton * cancel;

	INDEX * FF;
	COMPAREPARAMS params;
}
@end
@implementation CompareController

- (void)awakeFromNib {
	[super awakeFromNib];
	FF = [[self document] iIndex];
	[indexList removeAllItems];
	
	for (IRIndexDocument * iid in [IRdc documents]) {
		if (iid != self.document)	{
			[indexList addItemWithTitle:iid.displayName];
			[[indexList itemWithTitle:iid.displayName] setRepresentedObject:iid];
		}
	}
//	compare.enabled = indexList.numberOfItems > 0;
	modify.enabled = NO;
	[self enableOpItems:NO];
	stack.hidden = YES;
}
- (IBAction)showHelp:(id)sender {
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"compare0_Anchor-14210" inBook:@"Cindex 4 Help"];
}
- (IBAction)doClick:(id)sender {
	if (sender == importOther) {
		groupInOther.enabled = importOther.state;
		labelInImport.enabled = importOther.state;
	}
	if (sender == indexList || sender == fieldDepth) {	// reset all
		[self enableOpItems:NO];
	}
	modify.enabled = (deleteInThis.state || groupInThis.state || labelInThis.selectedTag >= 0
		|| deleteInBoth.state || groupInBoth.state || labelInBoth.selectedTag >= 0
		|| importOther.state);
}
- (IBAction)compareIndexes:(id)sender {
	memset(&params,0, sizeof(params));
	if ([self setParamsWithOp:OP_COMPARE])	{
		tool_compare(FF, &params);
		if (params.inThis || params.inOther) {
			recordsInThis.stringValue = [NSString stringWithFormat:params.inThis != 1 ? @"%d records" : @"%d record" ,params.inThis];
			recordsInBoth.stringValue = [NSString stringWithFormat:params.inBoth != 1 ? @"%d records" : @"%d record" ,params.inBoth];
			recordsInImport.stringValue = [NSString stringWithFormat:params.inOther != 1 ? @"%d records" : @"%d record" ,params.inOther];
			[self enableOpItems:YES];
			stack.hidden = NO;
		}
		else {
			infoSheet(self.window.sheetParent, INFO_INDEXESMATCH);
			[self.window.sheetParent endSheet:self.window returnCode:[sender tag]];
		}
	}
}
- (IBAction)closeSheet:(id)sender {
	if ([sender tag] == OKTAG)	{
		if (params.importOther) {
			if (params.deepestImport > FF->head.indexpars.maxfields)	{	/* if need to increase field limit */
				if (showWarning([self.document windowForSheet],RECFIELDNUMWARN, params.deepestImport))	{
					int oldmaxfieldcount = FF->head.indexpars.maxfields;
					
					FF->head.indexpars.maxfields = params.deepestImport;
					adjustsortfieldorder(FF->head.sortpars.fieldorder, oldmaxfieldcount, FF->head.indexpars.maxfields);
				}
				else
					return;
			}
			if (params.longestImport > FF->head.indexpars.recsize)	{	/* if need record enlargement */
				if (!showWarning([self.document windowForSheet],RECENLARGEWARN,params.longestImport-FF->head.indexpars.recsize) ||	/* if don't want resize */
					![self.document resizeIndex:params.longestImport])	// or can't
					return;		/* can't do it */
			}
			if (!index_setworkingsize(FF,params.inOther))
				return;		// some error return;
		}
		[self setParamsWithOp:OP_MODIFY];
		tool_compare(FF, &params);		// do it
		[[self document] flush];
		[[self document] setGroupMenu:[[self document] groupMenu:NO]];	// rebuild menu
		[[self document] installGroupMenu];	// install it
		[self.document setViewType:VIEW_ALL name:nil];
	}
	[self.window.sheetParent endSheet:self.window returnCode:[sender tag]];
}
- (BOOL)setParamsWithOp:(int)op {
	params.XF = [indexList.selectedItem.representedObject iIndex];
	params.op = op;
	params.textMode = (int)fieldDepth.selectedTag;
	params.deleteThis = (int)deleteInThis.state;
	params.deleteBoth = (int)deleteInBoth.state;
	params.importOther = (int)importOther.state;
	params.groupThis = (int)groupInThis.state;
	params.groupBoth = (int)groupInBoth.state;
	params.groupOther = (int)groupInOther.state;
	params.labelThis = (int)labelInThis.selectedTag;
	params.labelBoth = (int)labelInBoth.selectedTag;
	params.labelImport = (int)labelInImport.selectedTag;
	return YES;
}
- (void)enableOpItems:(BOOL)enabled {
	if (!enabled) {		// if comparing 
		deleteInThis.state = NSOffState;
		groupInThis.state = NSOffState;
		[labelInThis selectItemWithTag:-1];
		
		deleteInBoth.state = NSOffState;
		groupInBoth.state = NSOffState;
		[labelInBoth selectItemWithTag:-1];

		importOther.state = NSOffState;
		groupInOther.state = NSOffState;
		[labelInImport selectItemWithTag:0];
		[cancel setTitle:@"Cancel"];
		recordsInThis.stringValue = @"— records";
		recordsInBoth.stringValue = @"— records";
		recordsInImport.stringValue = @"— records";
	}
	else
		[cancel setTitle:@"Done"];
	compare.enabled = !enabled;
	deleteInThis.enabled = enabled && params.inThis > 0;
	groupInThis.enabled = enabled && params.inThis > 0;
	labelInThis.enabled = enabled && params.inThis > 0;

	deleteInBoth.enabled = enabled && params.inBoth > 0;
	groupInBoth.enabled = enabled && params.inBoth > 0;
	labelInBoth.enabled = enabled && params.inBoth > 0;

	importOther.enabled = enabled && params.inOther > 0;
	groupInOther.enabled = importOther.state == NSOnState;
	labelInImport.enabled = importOther.state == NSOnState;
}
@end
