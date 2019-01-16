/* AppController */

#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"

@interface AppController : NSObject
{
}
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)theApplication;
- (BOOL)application:(NSApplication *)theApplication
           openFile:(NSString *)filename;
@end
