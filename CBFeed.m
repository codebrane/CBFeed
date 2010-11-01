#import "CBFeed.h"

@implementation CBFeed

@synthesize feedURL;

-(id)initWithFeedURL:(NSString *)url {
  if (self = [super init]) {
    self.feedURL = url;
  }
  return self;
}

@end
