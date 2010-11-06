#import "CBFeedParser.h"

#pragma mark SAX handler method declarations
static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI);
static void	charactersFoundSAX(void * ctx, const xmlChar * ch, int len);
static void errorEncounteredSAX(void * ctx, const char * msg, ...);

#pragma mark SAX handler struct forward declaration
static xmlSAXHandler simpleSAXHandlerStruct;

@implementation CBFeedParser

@synthesize feed;
@synthesize feedURL;
@synthesize characterBuffer;
@synthesize storingCharacters;

-(id)initWithFeedURL:(NSString *)url {
  if (self = [super init]) {
    self.feedURL = url;
  }
  return self;
}

-(void)parseFeed {
  finished = NO;
  self.characterBuffer = [NSMutableData data];
  NSURLRequest *feedRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.feedURL]];
  feedConnection = [[NSURLConnection alloc] initWithRequest:feedRequest delegate:self];
  context = xmlCreatePushParserCtxt(&simpleSAXHandlerStruct, self, NULL, 0, NULL);
}

-(BOOL)isFeedReady {
  return finished;
}

-(BOOL)isFeedOK {
  if (feedError == nil) {
    return YES;
  }
  else {
    return NO;
  }
}

-(CBFeedError *)getError {
  return feedError;
}

- (void)appendCharacters:(const char *)charactersFound length:(NSInteger)length {
  [characterBuffer appendBytes:charactersFound length:length];
}

- (NSString *)currentString {
  // Create a string with the character data using UTF-8 encoding. UTF-8 is the default XML data encoding.
  NSString *currentString = [[[NSString alloc] initWithData:characterBuffer encoding:NSUTF8StringEncoding] autorelease];
  [characterBuffer setLength:0];
  return currentString;
}

#pragma mark NSURLConnection Delegate methods

// Disable caching so that each time we run this app we are starting with a clean slate. You may not want to do this in your application.
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
  return nil;
}

// Forward errors to the delegate.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  feedError = [[CBFeedError alloc] init];
  feedError.errorCode = [error code];
  feedError.errorDomain = [error domain];
  feedError.errorDescription = [error localizedDescription];
  NSLog(@"**************** ERROR! = %@", [error localizedDescription]);
  feedError.errorReason = [error localizedFailureReason];
  finished = YES;
}

// Called when a chunk of data has been downloaded.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  // Process the downloaded chunk of data.
  xmlParseChunk(context, (const char *)[data bytes], [data length], 0);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  // Signal the context that parsing is complete by passing "1" as the last parameter.
  xmlParseChunk(context, NULL, 0, 1);
  finished = YES; 
}

@end

static BOOL inChannel = NO;
static BOOL inTitle = NO;
static BOOL inItem = NO;
static BOOL inLink = NO;

// The following constants are the XML element names and their string lengths for parsing comparison.
// The lengths include the null terminator, to ensure exact matches.
static const char *kName_Channel = "channel";
static const NSUInteger kLength_Channel = 8;
static const char *kName_Item = "item";
static const NSUInteger kLength_Item = 5;
static const char *kName_Title = "title";
static const NSUInteger kLength_Title = 6;
static const char *kName_Link = "link";
static const NSUInteger kLength_Link = 5;

static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, 
                            int nb_namespaces, const xmlChar **namespaces, int nb_attributes,
                            int nb_defaulted, const xmlChar **attributes) {
  CBFeedParser *parser = (CBFeedParser *)ctx;
  
  if (prefix == NULL && !strncmp((const char *)localname, kName_Channel, kLength_Channel)) {
    inChannel = YES;
    parser.storingCharacters = NO;
    CBFeed *newFeed = [[CBFeed alloc] init];
    parser.feed = newFeed;
    [newFeed release];
  }
  else if (prefix == NULL && !strncmp((const char *)localname, kName_Title, kLength_Title)) {
    inTitle = YES;
    parser.storingCharacters = YES;
  }
  else if (prefix == NULL && !strncmp((const char *)localname, kName_Item, kLength_Item)) {
    inItem = YES;
    parser.storingCharacters = NO;
  }
  else if (prefix == NULL && !strncmp((const char *)localname, kName_Link, kLength_Link)) {
    inLink = YES;
    parser.storingCharacters = YES;
  }
}

static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI) {
  CBFeedParser *parser = (CBFeedParser *)ctx;
  
  if (prefix == NULL && !strncmp((const char *)localname, kName_Channel, kLength_Channel)) {
    inChannel = NO;
  }
  else if (inTitle) {
    inTitle = NO;
    if (!inItem) {
      parser.feed.title = [parser currentString];
    }
    else {
      [parser currentString];
    }
  }
  else if (inItem) {
    inItem = NO;
  }
  else if (inLink) {
    inLink = NO;
    if (!inItem) {
      parser.feed.link = [parser currentString];
    }
    else {
      [parser currentString];
    }
  }
  
  parser.storingCharacters = NO;
}

static void	charactersFoundSAX(void *ctx, const xmlChar *ch, int len) {
  CBFeedParser *parser = (CBFeedParser *)ctx;
  if (!parser.storingCharacters) return;
  [parser appendCharacters:(const char *)ch length:len];
}

static void errorEncounteredSAX(void *ctx, const char *msg, ...) {
  CBFeedParser *parser = (CBFeedParser *)ctx;
}

#pragma mark SAX handler struct definition
static xmlSAXHandler simpleSAXHandlerStruct = {
  NULL,                       /* internalSubset */
  NULL,                       /* isStandalone   */
  NULL,                       /* hasInternalSubset */
  NULL,                       /* hasExternalSubset */
  NULL,                       /* resolveEntity */
  NULL,                       /* getEntity */
  NULL,                       /* entityDecl */
  NULL,                       /* notationDecl */
  NULL,                       /* attributeDecl */
  NULL,                       /* elementDecl */
  NULL,                       /* unparsedEntityDecl */
  NULL,                       /* setDocumentLocator */
  NULL,                       /* startDocument */
  NULL,                       /* endDocument */
  NULL,                       /* startElement*/
  NULL,                       /* endElement */
  NULL,                       /* reference */
  charactersFoundSAX,         /* characters */
  NULL,                       /* ignorableWhitespace */
  NULL,                       /* processingInstruction */
  NULL,                       /* comment */
  NULL,                       /* warning */
  errorEncounteredSAX,        /* error */
  NULL,                       /* fatalError //: unused error() get all the errors */
  NULL,                       /* getParameterEntity */
  NULL,                       /* cdataBlock */
  NULL,                       /* externalSubset */
  XML_SAX2_MAGIC,             //
  NULL,
  startElementSAX,            /* startElementNs */
  endElementSAX,              /* endElementNs */
  NULL,                       /* serror */
};

