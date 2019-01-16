/* PreferencesController */

#import <Cocoa/Cocoa.h>
#import "AquaticPrime.h"

@interface PreferencesController : NSObject
{
    IBOutlet NSTextField *_key;
    IBOutlet NSTextField *_keyErrorText;
    IBOutlet NSTextField *_userEmail;
    IBOutlet NSTextField *_userName;
    IBOutlet NSTextField *_url;
	IBOutlet NSPanel *_preferencePanel;
}
- (void)awakeFromNib;
- (IBAction)submitKey:(id)sender;
+ (NSArray*)checkLicense:(NSString*)licensePath;
- (void)assertLicense;
- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;
@end
