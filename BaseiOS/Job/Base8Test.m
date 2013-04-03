//
//  Base8Test.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/21/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "Base8Test.h"

@implementation Base8Test

- (id)initWithDelegate:(id<TestDelegate>)delegate andNumberOfTests:(int)numberOfTests
{
    if (self = [super init]) {
        self.testDelegate = delegate;
        self.numberOfTests = numberOfTests;
    }
    return self;
}

- (void)didFinishWithError:(NSError *)error
{
    if ([(NSObject*)self.testDelegate respondsToSelector:@selector(test:didFinishWithError:)]) {
        [self.testDelegate test:self didFinishWithError:error];
    }
}

- (void)didFinishWithTime:(int)averageTime
{
    if ([(NSObject*)self.testDelegate respondsToSelector:@selector(test:didFinishWithTime:)]) {
        [self.testDelegate test:self didFinishWithTime:averageTime];
    }
}

- (void)start
{
    // dummy 
}

@end
