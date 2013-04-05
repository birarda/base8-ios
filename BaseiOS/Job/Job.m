//
//  Job.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/20/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "Job.h"

#define STATUS_CHECK_INTERVAL_SECONDS 5

@interface Job()

@property (strong, nonatomic) NSTimer *jobWaitTimer;

@end

@implementation Job

- (id)initWithDelegate:(id<JobDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)request {
    [ApiHelper createAssignment:^(id response, NSError *error) {
        if (error) {
            NSLog(@"Error creating assignment: %@", error.localizedDescription);
        }
    }];
}

- (void)repeatStatusCheck
{
    if (!self.jobWaitTimer) {
        self.jobWaitTimer = [NSTimer scheduledTimerWithTimeInterval:STATUS_CHECK_INTERVAL_SECONDS
                                                             target:self
                                                           selector:@selector(checkStatus)
                                                           userInfo:nil
                                                            repeats:YES];
        [self logStatus:@"Waiting for assignment..."];
    }    
}

- (void)checkStatus
{
    [ApiHelper startAssignment:^(id response, NSError *error) {
        if (!error) {
            if (!response || [response[@"message"] isEqualToString:@"cancelled"]) {
                [ApiHelper createAssignment:^(id response, NSError *error) {
                    if (error) {
                        NSLog(@"Error creating assignment: %@", error.localizedDescription);
                    }
                }];
            } else {
                NSLog(@"The reponse for the waiting job is %@", response);
            }
        } else {
            NSLog(@"Error starting assignment: %@", error.localizedDescription);
        }
    }];
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
