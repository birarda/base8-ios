//
//  Base8Test.h
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/21/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "TestJob.h"

@interface Base8Test : NSObject

@property (strong, nonatomic) id<TestJobDelegate> testDelegate;
@property (nonatomic) int numberOfTests;
@property (nonatomic) int currentTest;

- (id)initWithDelegate:(id<TestJobDelegate>)delegate andNumberOfTests:(int)numberOfTests;
- (void)start;
- (void)didFinishWithTime:(int)averageTime;
- (void)didFinishWithError:(NSError *)error;


@end
