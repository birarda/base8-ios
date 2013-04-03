//
//  UdpTest.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/21/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "UdpTest.h"
#import "GCDAsyncUdpSocket.h"

@interface UdpTest()

@property (nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic) double serverStartTime;
@property (nonatomic) double clientStartTime;
@property (nonatomic) int averageDeviceTime;
@property (nonatomic) int averageServerTime;

@end

@implementation UdpTest

- (void)start
{
    if (!self.udpSocket) {
        [self setupSocket];
    }
    
    // first ping is not calculated, used for establishing UDP connection
    self.currentTest = -1;
    [self sendData];
}

- (void)sendData
{
    self.currentTest++;
    NSString *stringData = [NSString stringWithFormat:@"P%f", self.clientStartTime];
    NSData *data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    [self.udpSocket sendData:data toHost:kUdpServer port:kUdpPort withTimeout:10 tag:0];
}

#pragma mark GCDAsyncUdpSocketDelegate
- (void)setupSocket
{
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    
    if (![self.udpSocket bindToPort:0 error:&error])	{
        NSLog(@"Error binding: %@", error);
        return;
    }
    if (![self.udpSocket beginReceiving:&error]) {
        NSLog(@"Error receiving: %@", error);
        return;
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)socket didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if ([(NSObject*)self.testDelegate respondsToSelector:@selector(onTestError:)]) {
        [self.testDelegate onTestError:error];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([msg hasPrefix:@"R"]) {
        
        double serverTime = [[msg substringFromIndex:1] doubleValue] * 1000;
        double clientTime = [[NSDate date] timeIntervalSince1970] * 1000;
        
        if (self.serverStartTime > 0) {
            int clientRTT = clientTime - self.clientStartTime;
            int serverRTT = serverTime - self.serverStartTime;
            
            self.averageDeviceTime = (self.averageDeviceTime * (self.currentTest - 1) + clientRTT) / self.currentTest;
            self.averageServerTime = (self.averageServerTime * (self.currentTest - 1) + serverRTT) / self.currentTest;
        }
        
        self.serverStartTime = serverTime;
        self.clientStartTime = clientTime;
    } else {
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];

        NSLog(@"RECV: Unknown message from: %@:%hu", host, port);
    }
    
    if (self.currentTest >= self.numberOfTests) {
        [self.udpSocket close];
        NSArray *testResults = @[
            @"udp",
            [NSNumber numberWithInt:self.averageDeviceTime],
            [NSNumber numberWithInt:self.averageServerTime]
        ];
        
        [ApiHelper finishJob:testResults withCompletion:^(id response, NSError *error) {
            if (!error) {
                if ([(NSObject*)self.testDelegate respondsToSelector:@selector(test:didFinishWithDeviceTime:andServerTime:)]) {
                    [self.testDelegate test:self
                    didFinishWithDeviceTime:self.averageDeviceTime
                              andServerTime:self.averageServerTime];
                }
            } else {
                [self.testDelegate test:self
                     didFinishWithError:error];
            }
        }];
        
    } else {
        [self sendData];
    }
}

@end
