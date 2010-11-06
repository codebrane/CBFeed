#import <Foundation/Foundation.h>
#import <libxml/tree.h>
#import "CBFeed.h"
#import "CBFeedError.h"

@interface CBFeedParser : NSObject {
  CBFeed *feed;
  @private
  NSString *feedURL;
  xmlParserCtxtPtr context;
  NSURLConnection *feedConnection;
  BOOL finished;
  CBFeedError *feedError;
  NSMutableData *characterBuffer;
  BOOL storingCharacters;
}

@property (nonatomic, retain) CBFeed *feed;
@property (nonatomic, retain) NSString *feedURL;
@property (nonatomic, retain) NSMutableData *characterBuffer;
@property BOOL storingCharacters;

-(id)initWithFeedURL:(NSString *)url;
-(void)parseFeed;
-(BOOL)isFeedReady;
-(BOOL)isFeedOK;
-(CBFeedError *)getError;

#pragma mark -
#pragma mark NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
