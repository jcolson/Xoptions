/* TotallerController */

#import <Cocoa/Cocoa.h>
#import "GetQuote.h"
#import "PreferencesController.h"
#import <SM2DGraphView/SM2DGraphView.h>

@interface TotallerController : NSObject
{
	float minX;
	float minY;
	float maxX;
	float maxY;
	NSMutableArray *dataCalcAr;
	NSArray *_tickerArray;
    IBOutlet NSPersistentDocument *persistentDocument;
    IBOutlet NSTableView *tableView;
    IBOutlet NSTextField *total;
    IBOutlet NSProgressIndicator *working;
	IBOutlet SM2DGraphView *graph;
	IBOutlet NSButton *includeNegative;
	IBOutlet NSButton *includeOutsideDates;
}
- (void) awakeFromNib;
- (id) tableView:(NSTableView *) aTableView
		objectValueForTableColumn:(NSTableColumn *) aTableColumn
		row:(int) rowIndex;
- (int) numberOfRowsInTableView:(NSTableView *)aTableView;
- (IBAction) refreshData:(id)sender;
- (void) getTickerPrice:(NSString *) tickerName;
- (void) recalculateData:(id)sender;
- (void) tableView:(NSTableView *)aTableView
			sortDescriptorsDidChange:(NSArray *)oldDescriptors;
- (IBAction)refreshStock:(id)sender;

// SM2DGraph
- (unsigned int)numberOfLinesInTwoDGraphView:(SM2DGraphView *)inGraphView;
- (NSArray *)twoDGraphView:(SM2DGraphView *)inGraphView
			dataForLineIndex:(unsigned int)inLineIndex;
/**- (NSData *)twoDGraphView:(SM2DGraphView *)inGraphView 
			dataObjectForLineIndex:(unsigned int)inLineIndex;*/
- (double)twoDGraphView:(SM2DGraphView *)inGraphView 
			maximumValueForLineIndex:(unsigned int)inLineIndex
			forAxis:(SM2DGraphAxisEnum)inAxis;
- (double)twoDGraphView:(SM2DGraphView *)inGraphView
			minimumValueForLineIndex:(unsigned int)inLineIndex
			forAxis:(SM2DGraphAxisEnum)inAxis;
- (NSDictionary *)twoDGraphView:(SM2DGraphView *)inGraphView
			attributesForLineIndex:(unsigned int)inLineIndex;

//SM2DGraph Delegate
- (NSString *)twoDGraphView:(SM2DGraphView *)inGraphView
			labelForTickMarkIndex:(unsigned int)inTickMarkIndex
			forAxis:(SM2DGraphAxisEnum)inAxis
			defaultLabel:(NSString *)inDefault;
@end
