//
//  MyDocument.m
//  Xoptions
//
//  Created by Jay Colson on 6/14/06.
//  Copyright Jay Colson 2006 . All rights reserved.
//

#import "MyDocument.h"

@implementation MyDocument

- (id)init 
{
    self = [super init];
    if (self != nil) {
        // initialization code
    }
    return self;
}

- (NSString *)windowNibName 
{
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
    [super windowControllerDidLoadNib:windowController];
    // user interface preparation code
}

- (void)saveDocumentWithDelegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(void *)contextInfo {
	NSArray *license = [PreferencesController checkLicense:[[NSUserDefaults standardUserDefaults] objectForKey:@"key"]];
	if ([license count] > 0) {
		[super saveDocumentWithDelegate:delegate didSaveSelector:didSaveSelector contextInfo:contextInfo];
	} else {
		NSRunAlertPanel(@"Not Licensed", @"%@", @"Understood", nil, nil, @"Please purchase a license at our website: www.kwazee.com");
	}
}

- (void)saveToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation delegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(void *)contextInfo {
	NSArray *license = [PreferencesController checkLicense:[[NSUserDefaults standardUserDefaults] objectForKey:@"key"]];
	if ([license count] > 0) {
		[super saveToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation delegate:delegate didSaveSelector:didSaveSelector contextInfo:contextInfo];
	} else {
		NSRunAlertPanel(@"Not Licensed", @"%@", @"Understood", nil, nil, @"Please purchase a license at our website: www.kwazee.com");
	}
}
- (void)printShowingPrintPanel:(BOOL)showPanels {
    // Obtain a custom view that will be printed
	
    // Construct the print operation and setup Print panel
    NSPrintOperation *op = [NSPrintOperation
                printOperationWithView:printView
							 printInfo:[self printInfo]];
    [op setShowPanels:showPanels];
    if (showPanels) {
        // Add accessory view, if needed
    }
	
    // Run operation, which shows the Print panel if showPanels was YES
    [self runModalPrintOperation:op
						delegate:nil
				  didRunSelector:NULL
					 contextInfo:NULL];
}
@end
