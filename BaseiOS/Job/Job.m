//
//  Job.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/20/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "Job.h"

@implementation Job

- (id)initWithDelegate:(id<JobDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)start
{
    
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
