#import <Foundation/Foundation.h>
#import "CBFeedItem.h"

@interface CBFeed : NSObject {
  NSString *title;
  NSString *link;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *link;

@end
