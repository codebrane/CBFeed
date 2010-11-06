#import "CBFeedTestCase.h"

static NSString* testFeedURL = @"http://codebrane.com/cbfeed/cbfeedtest.xml";

@implementation CBFeedTestCase

-(void)setUp {
  /*
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *currentWorkingDirectory = [fileManager currentDirectoryPath];
  testFeedURL = [[NSString alloc] initWithString:@"file://"];
  testFeedURL = [testFeedURL stringByAppendingString:currentWorkingDirectory];
  testFeedURL = [testFeedURL stringByAppendingString:testFeedFileName];
   */
  
  feedParser = [[CBFeedParser alloc] initWithFeedURL:testFeedURL];
}

-(void)tearDown {
  [feedParser release];
}

-(void)testParseFeed {
  [feedParser parseFeed];
  do {
    /* http://lists.apple.com/archives/aperture-dev/2008/Feb/msg00036.html
     
       NSURLConnection doesn't work in a modal runloop
     
       By default, for the connection to work correctly the calling thread’s
       run loop must be operating in the default run loop mode
      
       Each time a network event occurs, the run loop pass it to the handler
       (NSURLConnection in your case).
     */
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
  } while (![feedParser isFeedReady]);
  
  STAssertTrue([feedParser isFeedOK], @"feed not ok!");
  
  STAssertEquals(feedParser.feed.title, @"Alistair's cakeBlog", @"eek!");
  NSLog(@"TITLE = %@", feedParser.feed.title);
  
  if (![feedParser isFeedOK]) {
    CBFeedError *error = [feedParser getError];
    NSLog(@"%@", error.errorDomain);
    NSLog(@"%@", error.errorDescription);
    NSLog(@"%@", error.errorReason);
  }
}

@end
