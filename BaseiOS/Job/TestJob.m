//
//  PerformanceTestJob.m
//  BaseiOS
//
//  Created by Stephen Birarda on 4/4/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "TestJob.h"
#import "UdpTest.h"
#import "DownloadTest.h"
#import "UploadTest.h"

@interface TestJob()

@property (nonatomic) int numberOfTests;

@end

@implementation TestJob

@synthesize testData = _testData;

- (void)start
{
    [ApiHelper getTestConfigurationWithCompletion:^(id response, NSError *error) {
        if (error) {
            if ([(NSObject*)self.delegate respondsToSelector:@selector(onError:)]) {
                [self.delegate onError:error];
            }
        } else {
            self.numberOfTests = [response[@"test_runs"] integerValue];
            [self startUdpTest];
        }
    }];
}

- (void)startUdpTest
{
    if ([(NSObject*)self.delegate respondsToSelector:@selector(onJobLog:)]) {
        [self.delegate onJobLog:@"ping test"];
    }
    
    UdpTest *udp = [[UdpTest alloc] initWithDelegate:self andNumberOfTests:self.numberOfTests];
    [udp performSelectorInBackground:@selector(start) withObject:nil];
}

- (void)startDownloadTest
{
    if ([(NSObject*)self.delegate respondsToSelector:@selector(onJobLog:)]) {
        [self.delegate onJobLog:@"download test"];
    }
    
    DownloadTest *download = [[DownloadTest alloc] initWithDelegate:self andNumberOfTests:self.numberOfTests];
    [download performSelectorInBackground:@selector(start) withObject:nil];
}

- (void)startUploadTest
{
    if ([(NSObject*)self.delegate respondsToSelector:@selector(onJobLog:)]) {
        [self.delegate onJobLog:@"upload test"];
    }
    
    UploadTest *upload = [[UploadTest alloc] initWithDelegate:self andNumberOfTests:self.numberOfTests];
    [upload performSelectorInBackground:@selector(start) withObject:nil];
}

- (void)test:(id)test didFinishWithDeviceTime:(int)deviceAverage andServerTime:(int)serverAverage
{
    if ([test isKindOfClass:[UdpTest class]]) {
        [self logStatus:[NSString stringWithFormat:@"average ping time: %dms (%dms)", deviceAverage, serverAverage]];
        [self startDownloadTest];
    }
}

- (void)test:(id)test didFinishWithTime:(int)average
{
    if ([test isKindOfClass:[DownloadTest class]]) {
        [self logStatus:[NSString stringWithFormat:@"average download time: %dms", average]];
    } else if ([test isKindOfClass:[UploadTest class]]) {
        [self logStatus:[NSString stringWithFormat:@"average upload time: %dms", average]];
    }
    
    if ([(NSObject *)self.delegate respondsToSelector:@selector(didFinish:)]) {
        [self.delegate didFinish:@"OK"];
    }
}

- (void)logStatus:(NSString *)logLine
{
    if ([(NSObject*)self.delegate respondsToSelector:@selector(onJobLog:)]) {
        [self.delegate onJobLog:logLine];
    }
}

- (void)test:(id)test didFinishWithError:(NSError *)error
{
    [ApiHelper setTestFail:^(NSDictionary *json, NSError *apiError) {
        if ([(NSObject*)self.delegate respondsToSelector:@selector(onError:)]) {
            [self.delegate onError:error];
        }
        [self logStatus:[NSString stringWithFormat:@"Error occurred: %@", error.localizedDescription]];
    }];
}

@end
