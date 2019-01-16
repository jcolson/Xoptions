#import "TotallerController.h"

@implementation TotallerController

- (id)init {
    if ((self = [super init])) {// superclass may return nil
        // your initialization code goes here
		if (dataCalcAr == nil) {
			NSLog(@"dataCalcA WAS NIL - INITIALIZING");
			dataCalcAr = [[NSMutableArray alloc] init];
			maxX = 0;
			minX = 0;
			maxY = 0;
			minY = 0;
		}
    }
    return self;
}
- (void) awakeFromNib {
	[self refreshData:nil];
	[tableView setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc]initWithKey:@"excerciseDate" ascending:YES]autorelease]]];
}
// just returns the item for the right row
- (id) tableView:(NSTableView *) aTableView
		objectValueForTableColumn:(NSTableColumn *) aTableColumn
		row:(int) rowIndex {
	if ([aTableView isEqual:tableView]) {
		int counter = 0;
		id obj;
		NSEnumerator *objEnum = [dataCalcAr objectEnumerator];
		while (obj = [objEnum nextObject]) {
			if (counter == rowIndex) {
//				NSLog(@"Got call to object");
//				NSLog([aTableColumn identifier]);
				return [obj valueForKey:[aTableColumn identifier]];
				break;
			} else {
				counter++;
			}
		}
	}
	return @"";
}

// just returns the number of items we have.
- (int) numberOfRowsInTableView:(NSTableView *) aTableView {
	if ([aTableView isEqual:tableView]) {
		NSLog (@"Got call to rows: %d",[dataCalcAr count]);
		return [dataCalcAr count];
	}
	return 0;
}

- (IBAction) refreshData:(id)sender {
	[self recalculateData:(sender)];
//	[self tableView:tableView sortDescriptorsDidChange:[tableView sortDescriptors]];
	[tableView reloadData];
	[graph reloadData];
	[tableView setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc]initWithKey:@"excerciseDate" ascending:YES]autorelease]]];
}

- (void) getTickerPrice:(NSString *) tickerName {
	GetQuote *gq = [[[GetQuote alloc]init]autorelease];
	float quote = [gq getQuoteFor:tickerName];
	NSLog(@"result: %1.2f",quote);
	
}

- (void) recalculateData:(id)sender {
	NSManagedObjectContext *moc = [persistentDocument managedObjectContext];
	
	NSEntityDescription *grantsDesc = [NSEntityDescription entityForName:@"grants" inManagedObjectContext:moc];
	
	NSFetchRequest *grantsReq = [[[NSFetchRequest alloc] init] autorelease];
	
	[grantsReq setEntity:grantsDesc];
	
	NSError *grantsError = nil;
	
	NSArray *grantsArray = [moc executeFetchRequest:grantsReq error:&grantsError];
	[dataCalcAr removeAllObjects];
	if (grantsArray == nil || grantsError != nil) {
		
		NSLog(@"grantsArray was nil");
		
	} else {
		NSLog(@"grantsArray size: %d",[grantsArray count]);
		int i;
		NSNumber *totalNum = [NSNumber numberWithFloat:0];
//		[graph reloadData];
		for (i = 0; i < [grantsArray count]; i++) {
			NSManagedObject *grant = [grantsArray objectAtIndex:i];
			NSNumber *excercisePrice = [grant valueForKey:@"excercisePrice"];
			NSNumber *grantAmount = [grant valueForKey:@"grantAmount"];
			NSNumber *vestingMonths = [grant valueForKey:@"vestingMonths"];
			NSNumber *vestingPeriods = [grant valueForKey:@"vestingPeriods"];
			NSString *ticker = [grant valueForKeyPath:@"grantTickers.ticker"];
			NSNumber *price = [grant valueForKeyPath:@"grantTickers.price"];
			NSString *grantDate = [grant valueForKey:@"grantDate"];
			NSNumber *vestedAmount = [NSNumber numberWithFloat:[grantAmount floatValue] / [vestingPeriods intValue]];
			NSNumber *value = [NSNumber numberWithFloat:([vestedAmount floatValue] * [price floatValue]) - ([vestedAmount floatValue] * [excercisePrice floatValue])];
			NSLog(@"grant: %@, ticker: %@, periods: %d",grant, ticker, [vestingPeriods intValue]);
			int periods;
			NSDate *lastVestDate = [[grantDate copy] autorelease];
			NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			NSDateComponents *comps = [[NSDateComponents alloc] init];
			[comps setMonth:[vestingMonths intValue]];
			for (periods = 0; periods < [vestingPeriods intValue]; periods++) {
				NSDate *today = [NSDate date];
				lastVestDate = [gregorian dateByAddingComponents:comps toDate:lastVestDate options:0];
				if ([includeNegative state] == NSOnState || [value floatValue] >= 0) {
					if ([includeOutsideDates state] == NSOnState || [[lastVestDate laterDate:today] isEqualToDate:today]) {
						totalNum = [NSNumber numberWithFloat:[totalNum floatValue]+[value floatValue]];
					}
				}
//				[graph addDataPoint:point toLineIndex:0];
				NSMutableDictionary *keyDic = [[[NSMutableDictionary alloc] init] autorelease];
				[keyDic setValue:ticker forKey:@"ticker"];
				[keyDic setValue:grantDate forKey:@"grantDate"];
				[keyDic setValue:lastVestDate forKey:@"excerciseDate"];
				[keyDic setValue:value forKey:@"value"];
				[dataCalcAr addObject:keyDic];
				NSLog(@"period: %d, lastVestDate: %@",periods, lastVestDate);
			}
			[comps release];
			[gregorian release];
			NSLog(@"value: %@, total: %@",value, totalNum);
			NSLog(@"DATA count: %d",[dataCalcAr count]);
		}
		[total setFloatValue:[totalNum floatValue]];
	}
	// reset max's
	maxX = 0;
	maxY = 0;
	minX = 0;
	minY = 0;
}

- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
	if ([aTableView isEqual:tableView]) {
		NSLog(@"sortDescChange");
		NSArray *sortDesc = [tableView sortDescriptors];
		[dataCalcAr sortUsingDescriptors:sortDesc];
		[tableView reloadData];
	}
}

- (IBAction)refreshStock:(id)sender {
	NSLog(@"refreshStock");
	NSArray *license = [PreferencesController checkLicense:[[NSUserDefaults standardUserDefaults] objectForKey:@"key"]];
	if ([license count] > 0) {
		[working startAnimation:sender];
		NSManagedObjectContext *moc = [persistentDocument managedObjectContext];
		NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"tickers" inManagedObjectContext:moc];
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		[request setEntity:entityDescription];
		// Set example predicate and sort orderings...
		/**		
			NSPredicate *predicate = [NSPredicate predicateWithFormat:
				@"(ticker LIKE[c] 'SNC')"];
		[request setPredicate:predicate];
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"ticker" ascending:YES];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		[sortDescriptor release];
		*/
		NSError *error = nil;
		NSArray *array = [moc executeFetchRequest:request error:&error];
		if (array == nil || error != nil) {
			NSLog(@"array was nil");
		} else {
			NSLog(@"array size: %d",[array count]);
			int i;
			for (i = 0; i < [array count]; i++) {
				NSManagedObject *tickerO = [array objectAtIndex:i];
				NSLog(@"object: %@",tickerO);
				GetQuote *gq = [[[GetQuote alloc]init]autorelease];
				float price = [gq getQuoteFor:[tickerO valueForKey:@"ticker"]];
				NSDecimalNumber *priceD = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%1.2f",price]];
				[tickerO setValue:priceD forKey:@"price"];
			}
		}
		[working stopAnimation:sender];
		[self refreshData:sender];
	} else {
		NSRunAlertPanel(@"Not Licensed", @"%@", @"Understood", nil, nil, @"Please purchase a license at our website: www.kwazee.com");
	}
}

// SM2DGraph
- (unsigned int)numberOfLinesInTwoDGraphView:(SM2DGraphView *)inGraphView {
	NSLog(@"numberOfLinesInTwoDGraphView");
	NSMutableSet *tickerSet = [NSMutableSet set];
	int counter;
	for (counter = 0; counter < [dataCalcAr count]; counter++) {
		NSMutableDictionary *dic = [dataCalcAr objectAtIndex:counter];
		[tickerSet addObject:[dic objectForKey:@"ticker"]];
	}
	_tickerArray = [tickerSet allObjects];
	return [_tickerArray count]+1;
}
- (NSArray *)twoDGraphView:(SM2DGraphView *)inGraphView
		  dataForLineIndex:(unsigned int)inLineIndex {
	NSLog(@"twoDGraphView:dataForLineIndex:%d",inLineIndex);
	NSMutableArray *dataAr = [[[NSMutableArray alloc]init]autorelease];
//	NSMutableArray *tempAr = [[dataCalcAr copy] autorelease];
	[dataCalcAr sortUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc]initWithKey:@"excerciseDate" ascending:YES]autorelease]]];
	int counter;
	NSNumber *totalNum = [NSNumber numberWithFloat:0];
	for (counter = 0;counter<[dataCalcAr count];counter++) {
		NSMutableDictionary *dic = [dataCalcAr objectAtIndex:counter];
		NSString *ticker = [dic objectForKey:@"ticker"];
		NSDate *lastVestDate = [dic objectForKey:@"excerciseDate"];
		NSNumber *value = [dic objectForKey:@"value"];
		NSDate *today = [NSDate date];
		if ([_tickerArray count] == inLineIndex ||
			[ticker isEqualToString:[_tickerArray objectAtIndex:inLineIndex]]) {
			if ([includeNegative state] == NSOnState || [value floatValue] >= 0) {
				if ([includeOutsideDates state] == NSOnState || [[lastVestDate laterDate:today] isEqualToDate:today]) {
					totalNum = [NSNumber numberWithFloat:[totalNum floatValue]+[value floatValue]];
				}
			}
		}
		//NSLog(@"TotalNum: %@ or %f",totalNum, [totalNum floatValue]);

		float lastVestTime = (float)[lastVestDate timeIntervalSince1970];
		if (maxX < lastVestTime || maxX == 0) {
			maxX = lastVestTime;
		}
		if (minX > lastVestTime || minX == 0) {
			minX = lastVestTime;
		}
		if (maxY < [totalNum floatValue] || maxY == 0) {
			//NSLog (@"maxY: %f new max: %f",maxY, [totalNum floatValue]);
			maxY = [totalNum floatValue];
		}
		if (minY > [totalNum floatValue] || minY == 0) {
			minY = [totalNum floatValue];
		}
		NSPoint point = NSMakePoint(lastVestTime,[totalNum floatValue]);
		NSString *pointS = NSStringFromPoint(point);
		[dataAr addObject:pointS];
	}
//	NSLog(@"data: %@",dataAr);
	return dataAr;
}
- (NSDictionary *)twoDGraphView:(SM2DGraphView *)inGraphView
		 attributesForLineIndex:(unsigned int)inLineIndex {
	NSLog(@"twoDGraphView:attributesForLineIndex");
	NSDictionary *dic = [ NSDictionary dictionaryWithObjectsAndKeys:
		[ NSColor redColor ], NSForegroundColorAttributeName,
		nil];
	//	[dic setObject:[NSColor colorWithDeviceRed:30*(inLineIndex+1) green:30*(inLineIndex+1) blue:30*(inLineIndex+1) alpha:30*(inLineIndex+1)]
	//			forKey:NSForegroundColorAttributeName];
	return dic;
}
- (double)twoDGraphView:(SM2DGraphView *)inGraphView 
			maximumValueForLineIndex:(unsigned int)inLineIndex
			forAxis:(SM2DGraphAxisEnum)inAxis {
	if (inAxis == kSM2DGraph_Axis_X) {
//		NSLog(@"twoDGraphView:maximumValueForLineIndex:forAxisX: %f",maxX);
		return (double)maxX;
	} else if (inAxis == kSM2DGraph_Axis_Y) {
//		NSLog(@"twoDGraphView:maximumValueForLineIndex:forAxisY: %f",maxY);
		return (double)maxY;
	} else {
		return 0;
	}
}
- (double)twoDGraphView:(SM2DGraphView *)inGraphView
			minimumValueForLineIndex:(unsigned int)inLineIndex
			forAxis:(SM2DGraphAxisEnum)inAxis {
	if (inAxis == kSM2DGraph_Axis_X) {
//		NSLog(@"twoDGraphView:minimumValueForLineIndex:forAxisX: %f",minX);
		return (double)minX;
	} else if (inAxis == kSM2DGraph_Axis_Y) {
//		NSLog(@"twoDGraphView:minimumValueForLineIndex:forAxisY: %f",minY);
		return (double)minY;
	} else {
		return 0;
	}
}
- (NSString *)twoDGraphView:(SM2DGraphView *)inGraphView
	  labelForTickMarkIndex:(unsigned int)inTickMarkIndex
					forAxis:(SM2DGraphAxisEnum)inAxis
			   defaultLabel:(NSString *)inDefault {
//	NSLog(@"twoDGraphView:labelForTickMarkIndex:forAxis:defaultLabel");
	NSString *returnS = inDefault;
	if (inAxis == kSM2DGraph_Axis_Y) {
		NSNumberFormatter *formatter = [[[NSNumberFormatter alloc]init]autorelease];
		[formatter setNumberStyle:NSNumberFormatterScientificStyle];
		[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		NSNumber *moolah = [formatter numberFromString:inDefault];
		returnS = [NSString stringWithFormat:@"$%@",moolah];
	} else if (inAxis == kSM2DGraph_Axis_X) {
		NSNumberFormatter *formatter = [[[NSNumberFormatter alloc]init]autorelease];
		[formatter setNumberStyle:NSNumberFormatterScientificStyle];
		[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		NSNumber *time = [formatter numberFromString:inDefault];
//		NSLog(@"inDefault: %@",inDefault);
//		NSLog(@"time: %@",time);
		NSDate *date = [NSDate dateWithTimeIntervalSince1970:[time doubleValue]];
		returnS = [date descriptionWithCalendarFormat:@"%m-%d-%y" timeZone:nil locale:nil];
	} 
	return returnS;
}
@end
