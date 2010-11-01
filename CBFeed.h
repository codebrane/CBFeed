#import <Foundation/Foundation.h>
#import "CBFeedParser.h"

@interface CBFeed : NSObject {
  CBFeedParser *parser;
  NSString *feedURL;
}

@property (nonatomic, retain) NSString *feedURL;

-(id)initWithFeedURL:(NSString *)url;

@end
