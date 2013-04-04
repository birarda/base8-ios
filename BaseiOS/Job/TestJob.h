//
//  PerformanceTestJob.h
//  BaseiOS
//
//  Created by Stephen Birarda on 4/4/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "Job.h"

@protocol TestJobDelegate

@property (strong, nonatomic) id testData;

@optional
- (void)onTestError:(NSError *)error;
- (void)test:(id)test didFinishWithTime:(int)average;
- (void)test:(id)test didFinishWithDeviceTime:(int)deviceAverage andServerTime:(int)serverAverage;
- (void)test:(id)test didFinishWithError:(NSError *)error;

@end

@interface TestJob : Job <TestJobDelegate>

@end
