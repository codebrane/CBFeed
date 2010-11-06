#import <Foundation/Foundation.h>

@interface CBFeedError : NSObject {
  NSInteger errorCode;
  NSString *errorDomain;
  NSString *errorDescription;
  NSString *errorReason;
}

@property (nonatomic) NSInteger errorCode;
@property (nonatomic, retain) NSString *errorDomain;
@property (nonatomic, retain) NSString *errorDescription;
@property (nonatomic, retain) NSString *errorReason;

@end
