//
//  NSAlert+NSAlert.m
//  Cindex 4
//
//  Created by Peter Lennie on 4/29/24.
//

#import "NSAlert+NSAlert.h"

NSWindow * alertParent;

@implementation NSAlert (NSAlert)

- (void)configureForParent:(NSWindow *)parent {
	alertParent = parent;
	if (parent)
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowMoved:) name:NSWindowDidMoveNotification object:nil];
}
- (void)windowMoved:(NSNotification *)aNotification {
	[[NSNotificationCenter defaultCenter] removeObserver:self];	// ensure can never be called again
	if (aNotification.object == self.window && alertParent) {	// if our window, and we have a parent
		NSRect frame = self.window.frame;
		NSRect pFrame = alertParent.frame;
		frame.origin.x = pFrame.origin.x + (pFrame.size.width-frame.size.width)/2;
		frame.origin.y = pFrame.origin.y +(pFrame.size.height-frame.size.height)/2;
		[self.window setFrame:frame display:NO];
	}
}
@end
