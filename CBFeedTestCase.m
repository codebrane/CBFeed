#import "CBFeedTestCase.h"

static NSString* testFeedFileName = @"/testfeed.xml";

@implementation CBFeedTestCase

-(void)setUp {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *currentWorkingDirectory = [fileManager currentDirectoryPath];
  testFeedURL = [[NSString alloc] initWithString:@"file://"];
  testFeedURL = [testFeedURL stringByAppendingString:currentWorkingDirectory];
  testFeedURL = [testFeedURL stringByAppendingString:testFeedFileName];
  
  feed = [[CBFeed alloc] initWithFeedURL:testFeedURL];
}

-(void)tearDown {
  [feed release];
  [testFeedURL release];
}

-(void)testFeedURLIsSet {
  STAssertEqualObjects(feed.feedURL, testFeedURL, testFeedURL);
}

@end
