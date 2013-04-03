//
//  UploadTest.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/21/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "UploadTest.h"

@interface UploadTest()

@property (nonatomic) int averageTime;

@end

@implementation UploadTest

- (void)start
{
    [self uploadData];
}

- (void) uploadData
{
    self.currentTest++;
    
    int startTime = CACurrentMediaTime() * 1000;
    [ApiHelper uploadTest:[self.testDelegate testData] andCompletion:^(id response, NSError *error) {
        int endTime = CACurrentMediaTime() * 1000;
        if (error) {
            [super didFinishWithError:error];
            return;
        }
        self.averageTime = (self.averageTime * (self.currentTest - 1) + (endTime - startTime)) / self.currentTest;
        
        if (self.currentTest >= self.numberOfTests) {
            
            NSArray *testResults = @[
                @"upload",
                [NSNumber numberWithInt:self.averageTime],
                @0,
                [NSNumber numberWithDouble:[Base8AppDelegate locationManager].location.coordinate.latitude],
                [NSNumber numberWithDouble:[Base8AppDelegate locationManager].location.coordinate.longitude]
            ];
            
            [ApiHelper finishJob:testResults withCompletion:^(id response, NSError *error) {
                if (!error) {
                    [super didFinishWithTime:self.averageTime];
                } else {
                    [super didFinishWithError:error];
                }
            }];
        } else {
            [self uploadData];
        }
    }];
}

@end
