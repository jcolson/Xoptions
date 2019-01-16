//
//  GetQuote.m
//  Xoptions
//
//  Created by Jay Colson on 7/9/06.
//  Copyright 2006 Jay Colson. All rights reserved.
//

#import "GetQuote.h"


@implementation GetQuote
- (float) getQuoteFor:(NSString *) ticker {
	float quote = 0;
	NSString *urlString = [NSString stringWithFormat:@"http://quotes.nasdaq.com/quote.dll?mode=stock&page=quick&symbol=%@",ticker];
	NSURL *url = [NSURL URLWithString: urlString];
	NSURLRequest *req = [NSURLRequest requestWithURL:url];
	NSURLResponse *res;
	NSError *err;
	NSData *data = [NSURLConnection sendSynchronousRequest: req returningResponse: &res error: &err];
	if ([err code]) {
		NSLog(@"%@ %d %@ %@ %@", [ err domain], [ err code], [ err
			localizedDescription], req);
	} else if (data) {
		NSString *result = [[[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding] autorelease];
		NSScanner *scanner = [NSScanner scannerWithString:result];
		[scanner scanUpToString:[NSString stringWithFormat:@"selected=%@",ticker] intoString:nil];
		[scanner scanUpToString:@"nbsp;" intoString:nil];	
		[scanner scanString:@"nbsp;" intoString:nil];
		if ([scanner scanFloat:&quote]) {
			NSLog(@"Success float scan!");
		}
		//NSLog(@"quote value: %@",quote);
	}
	return quote;
}
@end
