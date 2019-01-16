#import "PreferencesController.h"

@implementation PreferencesController

- (void)awakeFromNib {
	NSMutableAttributedString * newTitleString = [[NSMutableAttributedString alloc] initWithString:@"Purchase From: Kwazee, LLC Web Site"];
    //NSRange attrRange = NSMakeRange(0, [newTitleString length]);
    //[newTitleString addAttribute:NSLinkAttributeName value:@"http://www.kwazee.com/html/products/products.html" range:attrRange];
	NSDictionary *d = [NSDictionary dictionaryWithObject: @"http://www.kwazee.com/html/products/products.html" forKey: NSLinkAttributeName];
	[newTitleString addAttributes: d range: NSMakeRange(0, [newTitleString length])];
	[_url setAllowsEditingTextAttributes: YES];
	[_url setAttributedStringValue:newTitleString];
	[_url setAlignment:NSCenterTextAlignment];
	[self assertLicense];
}
- (IBAction)submitKey:(id)sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel beginSheetForDirectory:nil 
				file:nil
				types:[NSArray arrayWithObject:@"xoptionslicense"]
				modalForWindow:_preferencePanel
				modalDelegate:self
				didEndSelector:@selector(openPanelDidEnd:
										returnCode:
										contextInfo:)
				contextInfo:nil];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void  *)contextInfo {
	if (returnCode == NSOKButton) {
		NSArray *licData = [PreferencesController checkLicense:[panel filename]];
		if ([licData count] > 0) {
			NSFileManager *fileMan = [[[NSFileManager alloc]init]autorelease];
			NSString *propPath = [@"~/Library/Preferences/com.kwazee.Xoptions/" stringByExpandingTildeInPath];
			[fileMan createDirectoryAtPath:propPath attributes:nil];
			NSString *newPath = [propPath stringByAppendingPathComponent:[[panel filename] lastPathComponent]];
			[fileMan copyPath:[panel filename] toPath:newPath handler:nil];
			[[NSUserDefaults standardUserDefaults] setObject:newPath forKey:@"key"];
			[self assertLicense];
		}
	}
}

- (void)assertLicense {
	NSArray *licData = [PreferencesController checkLicense:[_key stringValue]];
	if ([licData count] > 0) {
		[_userName setStringValue:[licData objectAtIndex:0]];
		[_userEmail setStringValue:[licData objectAtIndex:1]];
	}
}

/**
for checking license key
 */
+ (NSArray*)checkLicense:(NSString*)licensePath {
	NSMutableString *publicKey = [NSMutableString string];
	[publicKey appendString:@"0xBFA"];
	[publicKey appendString:@"5"];
	[publicKey appendString:@"5"];
	[publicKey appendString:@"17929CC0B8D7893AD2B707C"];
	[publicKey appendString:@"9F27"];
	[publicKey appendString:@"0"];
	[publicKey appendString:@"0"];
	[publicKey appendString:@"D19C181D865BBE3E745E3F8A"];
	[publicKey appendString:@"BE136C5BE3F94C2"];
	[publicKey appendString:@"0"];
	[publicKey appendString:@"0"];
	[publicKey appendString:@"3C6155211FEFC"];
	[publicKey appendString:@"3"];
	[publicKey appendString:@"6"];
	[publicKey appendString:@"6"];
	[publicKey appendString:@"FA485322AE80268585E8D0D4C4A"];
	[publicKey appendString:@"89732DA79D36D2015"];
	[publicKey appendString:@"E"];
	[publicKey appendString:@"E"];
	[publicKey appendString:@"2560A605791"];
	[publicKey appendString:@"49C47D4B1BE272B95A97C3D9791FA2"];
	[publicKey appendString:@"01BD063"];
	[publicKey appendString:@"9"];
	[publicKey appendString:@"9"];
	[publicKey appendString:@"2FD920567136A306119E8"];
	[publicKey appendString:@""];
	[publicKey appendString:@"7"];
	[publicKey appendString:@"7"];
	[publicKey appendString:@"ECD9A48FCBD080EA7E81E8376108"];
	[publicKey appendString:@"83207BAB81B6C822D9"];	
    // Instantiate AquaticPrime
    AquaticPrime *licenseValidator = [AquaticPrime aquaticPrimeWithKey:publicKey];
	
    // Get the dictionary from the license file
    // If the license is invalid, we get nil back instead of a dictionary
    NSDictionary *licenseDictionary = [licenseValidator dictionaryForLicenseFile:licensePath];
	NSMutableArray *licenseData = [[[NSMutableArray alloc] init] autorelease];
    if (licenseDictionary != nil) {
        [licenseData addObject: [licenseDictionary objectForKey:@"Name"]];
		[licenseData addObject: [licenseDictionary objectForKey:@"Email"]];
	}
	return licenseData;
}
@end
