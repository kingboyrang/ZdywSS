//
//  SimplePingHelper.m
//  PingTester
//
//  Created by Chris Hulbert on 18/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SimplePingHelper.h"

@interface SimplePingHelper()
@property(nonatomic,retain) SimplePing* simplePing;
@property(nonatomic,retain) id target;
@property(nonatomic,assign) SEL sel;
@property(nonatomic,assign) id<SimplePingHelperDelegate> delegate;
@property(nonatomic,strong)  NSDate* startDate;
@property(nonatomic,strong)  NSDate* endDate;
@property(nonatomic,strong)  NSURL* hostURL;
- (id)initWithAddress:(NSString*)address target:(id)_target sel:(SEL)_sel;
- (id)initWithAddress:(NSString*)address delegate:(id<SimplePingHelperDelegate>)delegate;
@end

@implementation SimplePingHelper
@synthesize simplePing, target, sel;

#pragma mark - Run it

// Pings the address, and calls the selector when done. Selector must take a NSnumber which is a bool for success
+ (void)ping:(NSString*)address target:(id)target sel:(SEL)sel {
	// The helper retains itself through the timeout function
	[[[[SimplePingHelper alloc] initWithAddress:address target:target sel:sel] autorelease] go];
}
+ (void)ping:(NSString*)address delegate:(id<SimplePingHelperDelegate>)delegate{
    [[[[SimplePingHelper alloc] initWithAddress:address delegate:delegate] autorelease] go];
}
#pragma mark - Init/dealloc

- (void)dealloc {
	self.simplePing = nil;
	self.target = nil;
	[super dealloc];
}

- (id)initWithAddress:(NSString*)address target:(id)_target sel:(SEL)_sel {
	if (self = [self init]) {
        self.hostURL=[NSURL URLWithString:address];
		self.simplePing = [SimplePing simplePingWithHostName:self.hostURL.host];
		self.simplePing.delegate = self;
		self.target = _target;
		self.sel = _sel;
	}
	return self;
}
- (id)initWithAddress:(NSString*)address delegate:(id<SimplePingHelperDelegate>)delegate{
    
    if (self = [self init]) {
        self.hostURL=[NSURL URLWithString:address];
        self.simplePing = [SimplePing simplePingWithHostName:self.hostURL.host];
        self.simplePing.delegate = self;
        self.delegate = delegate;
    }
    return self;
}


#pragma mark - Go

- (void)go {
	[self.simplePing start];
	[self performSelector:@selector(endTime) withObject:nil afterDelay:1]; // This timeout is what retains the ping helper
}

#pragma mark - Finishing and timing out

// Called on success or failure to clean up
- (void)killPing {
	[self.simplePing stop];
	[[self.simplePing retain] autorelease]; // In case, higher up the call stack, this got called by the simpleping object itself
	self.simplePing = nil;
}

- (void)successPing {
	[self killPing];
	//[target performSelector:sel withObject:[NSNumber numberWithBool:YES]];
    [target performSelector:sel withObject:[self pingWithStatus:PingHostAddressStatusSuccess success:YES packetLength:0]];
}

- (void)failPing:(NSString*)reason {
	[self killPing];
	//[target performSelector:sel withObject:[NSNumber numberWithBool:NO]];
    if ([reason isEqualToString:@"didFailToSendPacket"]) {
        [target performSelector:sel withObject:[self pingWithStatus:PingHostAddressStatusFailPacket success:YES packetLength:0]];
    }else if([reason isEqualToString:@"didFailWithError"]){
        [target performSelector:sel withObject:[self pingWithStatus:PingHostAddressStatusFailed success:NO packetLength:0]];
    }else{
        [target performSelector:sel withObject:[self pingWithStatus:PingHostAddressStatusTimeOut success:NO packetLength:0]];
    }
    //timeout
}

// Called 1s after ping start, to check if it timed out
- (void)endTime {
	if (self.simplePing) { // If it hasn't already been killed, then it's timed out
        [self endPingWithStatus:PingHostAddressStatusTimeOut success:NO packetLength:0];
		[self failPing:@"timeout"];
	}
}
//表示ping完成
- (void)endPingWithStatus:(PingHostAddressStatus)status success:(BOOL)success packetLength:(NSInteger)len{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(simplePingHelperResult:)]) {
        SimplePingResult *mod=[[SimplePingResult alloc] init];
        if (status!=PingHostAddressStatusTimeOut) {
            mod.timeInterval=[self.endDate timeIntervalSinceDate:self.startDate];
        }
        if (self.hostURL) {
            mod.hostName=self.hostURL.absoluteString;
        }else{
           mod.hostName=self.simplePing.hostName;
        }
        mod.pingHostStatus=status;
        mod.success=success;
        mod.packetLength=len;
        [self.delegate simplePingHelperResult:mod];
    }
}
- (SimplePingResult*)pingWithStatus:(PingHostAddressStatus)status success:(BOOL)success packetLength:(NSInteger)len{
    SimplePingResult *mod=[[SimplePingResult alloc] init];
    if (status!=PingHostAddressStatusTimeOut) {
        mod.timeInterval=[self.endDate timeIntervalSinceDate:self.startDate];
    }
    if (self.hostURL) {
        mod.hostName=self.hostURL.absoluteString;
    }else{
        mod.hostName=self.simplePing.hostName;
    }
    mod.pingHostStatus=status;
    mod.success=success;
    mod.packetLength=len;
    return mod;
}
#pragma mark - Pinger delegate

// When the pinger starts, send the ping immediately
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    self.startDate=[NSDate date];
	[self.simplePing sendPingWithData:nil];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
    self.endDate=[NSDate date];
    [self endPingWithStatus:PingHostAddressStatusFailed success:NO packetLength:0];
    [self failPing:@"didFailWithError"];
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error {
	// Eg they're not connected to any network
    self.endDate=[NSDate date];
	
    [self endPingWithStatus:PingHostAddressStatusFailPacket success:YES packetLength:packet.length];
    [self failPing:@"didFailToSendPacket"];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet {
    self.endDate=[NSDate date];
    [self endPingWithStatus:PingHostAddressStatusSuccess success:YES packetLength:0];
    [self successPing];
}

@end
