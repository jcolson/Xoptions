//
//  MyDocument.h
//  Xoptions
//
//  Created by Jay Colson on 6/14/06.
//  Copyright Jay Colson 2006 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"

@interface MyDocument : NSPersistentDocument {
	IBOutlet NSView *printView;
}

@end
