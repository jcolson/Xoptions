//
//  GetQuote.h
//  Xoptions
//
//  Created by Jay Colson on 7/9/06.
//  Copyright 2006 Jay Colson. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GetQuote : NSObject {
}

- (float) getQuoteFor:(NSString *) ticker;

@end
