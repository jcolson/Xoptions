#import "AppController.h"

@implementation AppController
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)theApplication {
    return NO;
}
- (BOOL)application:(NSApplication *)theApplication
           openFile:(NSString *)filename {
	if ([[filename pathExtension] isEqualToString:@"xoptionslicense"]) {
		NSArray *licData = [PreferencesController checkLicense:filename];
		if ([licData count] > 0) {
			NSFileManager *fileMan = [[[NSFileManager alloc]init]autorelease];
			NSString *propPath = [@"~/Library/Preferences/com.kwazee.Xoptions/" stringByExpandingTildeInPath];
			[fileMan createDirectoryAtPath:propPath attributes:nil];
			NSString *newPath = [propPath stringByAppendingPathComponent:[filename lastPathComponent]];
			[fileMan copyPath:filename toPath:newPath handler:nil];
			[[NSUserDefaults standardUserDefaults] setObject:newPath forKey:@"key"];
			NSRunAlertPanel(@"Licensed!", @"%@", @"Thank You", nil, nil, @"Thank you very much for licensing Xoptions!  Please restart the application to take advantage of licensee options.");
		} else {
			NSRunAlertPanel(@"Not Licensed", @"%@", @"Understood", nil, nil, @"The license file used was not readable, please contact: company-info@kwazee.com.");
		}
		return YES;
	} else {
		NSDocumentController *dc;
		id doc;
		
		dc = [NSDocumentController sharedDocumentController];
		NSURL *url = [NSURL URLWithString:filename];
		doc = [dc openDocumentWithContentsOfURL:url display:YES];
		
		return ( doc != nil);
	}
}
@end
