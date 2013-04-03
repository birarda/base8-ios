//
//  Job.h
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/20/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

@protocol TestDelegate

@property (strong, nonatomic) id testData;

@optional
- (void)onTestError:(NSError *)error;
- (void)test:(id)test didFinishWithTime:(int)average;
- (void)test:(id)test didFinishWithDeviceTime:(int)deviceAverage andServerTime:(int)serverAverage;
- (void)test:(id)test didFinishWithError:(NSError *)error;

@end

@protocol JobDelegate

@optional
- (void)onJobLog:(NSString *)logLine;
- (void)onError:(NSError *)error;
- (void)didFinish:(NSString *)status;

@end

@interface Job : NSObject <TestDelegate>

- (id)initWithDelegate:(id<JobDelegate>)delegate;
- (void)start;

@end
