//
//  AddressPingHelper.m
//  SkyClient
//
//  Created by dyn on 13-6-22.
//  Copyright (c) 2013年 D-TONG-TELECOM. All rights reserved.
//

#import "AddressPingHelper.h"
#include <sys/socket.h>
#include <netdb.h>

static NSString * DisplayAddressForAddress(NSData * address)
// Returns a dotted decimal string for the specified address (a (struct sockaddr)
// within the address NSData).
{
    int         err;
    NSString *  result;
    char        hostStr[NI_MAXHOST];
    
    result = nil;
    
    if (address != nil)
    {
        err = getnameinfo([address bytes], (socklen_t) [address length], hostStr, sizeof(hostStr), NULL, 0, NI_NUMERICHOST);
        if (err == 0)
        {
            result = [NSString stringWithCString:hostStr encoding:NSASCIIStringEncoding];
            assert(result != nil);
        }
    }
    
    return result;
}


@implementation AddressPingHelper


@synthesize delegate = _delegate;
@synthesize pinger = _pinger;

- (void)dealloc
{
    [self->_pinger stop];
}

- (void)pingHostName:(NSString *)hostName
// The Objective-C 'main' for this program.  It creates a SimplePing object
// and runs the runloop sending pings and printing the results.
{
    self.hostURL=[NSURL URLWithString:hostName];
    assert(self.pinger == nil);

    self.pinger = [SimplePing simplePingWithHostName:hostName];
    assert(self.pinger != nil);
    
    self.pinger.delegate = self;
    [self.pinger start];
    
    while (self.pinger != nil)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    NSLog(@"AddressPingHelper end");
}

- (void)sendPing
// Called to send a ping, both directly (as soon as the SimplePing object starts up)
// and via a timer (to continue sending pings periodically).
{
    assert(self.pinger != nil);
    [self.pinger sendPingWithData:nil];
    
    _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                     target:self
                                                   selector:@selector(handelTimeout)
                                                   userInfo:nil
                                                    repeats:NO];
}

- (void)handelTimeout
{
    self.pinger = nil;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(testNetDidAbnormal)])
    {
        [self.delegate testNetDidAbnormal];
    }
   
}

#pragma mark -
#pragma mark SimplePing Delegate

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
// A SimplePing delegate callback method.  We respond to the startup by sending a
// ping immediately and starting a timer to continue sending them every second.
{
    self.startDate=[NSDate date];
    NSString *host = DisplayAddressForAddress(address);
    NSLog(@"ping address = %@", host);
    
    // Send the first ping straight away.
    [self sendPing];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
// A SimplePing delegate callback method.  We shut down our timer and the
// SimplePing object itself, which causes the runloop code to exit.
{
    self.endDate=[NSDate date];
    self.pinger = nil;
    
    if(_timeoutTimer)
    {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(testNetDidAbnormal)])
    {
        [self.delegate testNetDidAbnormal];
    }
    
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error
// A SimplePing delegate callback method.  We just log the failure.
{
    self.endDate=[NSDate date];
    NSLog(@"didFailToSendPacket");
    
    self.pinger = nil;
    
    if(_timeoutTimer)
    {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(testNetDidAbnormal)])
    {
        [self.delegate testNetDidAbnormal];
    }
    
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet
// A SimplePing delegate callback method.  We just log the reception of a ping response.
{
    NSLog(@"didReceivePingResponsePacket");
    self.endDate=[NSDate date];
    self.pinger = nil;
    
    if(_timeoutTimer)
    {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(testNetDidNormal)])
    {
        [self.delegate testNetDidNormal];
    }
    
}

@end
