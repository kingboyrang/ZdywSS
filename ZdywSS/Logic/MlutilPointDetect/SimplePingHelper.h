//
//  SimplePingHelper.h
//  PingTester
//
//  Created by Chris Hulbert on 18/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimplePing.h"
#import "SimplePingResult.h"

@protocol SimplePingHelperDelegate <NSObject>
- (void)simplePingHelperResult:(SimplePingResult*)result;
@end

@interface SimplePingHelper : NSObject <SimplePingDelegate>
+ (void)ping:(NSString*)address target:(id)target sel:(SEL)sel;
+ (void)ping:(NSString*)address delegate:(id<SimplePingHelperDelegate>)delegate;
@end
