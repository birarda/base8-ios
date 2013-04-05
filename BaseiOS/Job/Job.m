//
//  Job.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/20/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "Job.h"

#define STATUS_CHECK_INTERVAL_SECONDS 5

@interface Job() <NSStreamDelegate>

@property (strong, nonatomic) NSTimer *jobWaitTimer;
@property (strong, nonatomic) NSMutableData *assignmentData;

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
            } else if ([response[@"message"] isEqualToString:@"working"]) {
                NSLog(@"Received assignment: %@", response);
                [self download];
            }
        } else {
            NSLog(@"Error starting assignment: %@", error.localizedDescription);
        }
    }];
}

- (void)download
{
    [self logStatus:@"Downloading assignment..."];
    [self.jobWaitTimer invalidate];
    
    self.assignmentData = nil;
    NSOutputStream *assignmentOutputStream = [NSOutputStream outputStreamToMemory];
    assignmentOutputStream.delegate = self;
    [assignmentOutputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                      forMode:NSDefaultRunLoopMode];
    [assignmentOutputStream open];
    
    [ApiHelper loadAssignment:^(id response, NSError *error) {
        [assignmentOutputStream close];
        [assignmentOutputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                          forMode:NSDefaultRunLoopMode];
        self.assignmentData = [assignmentOutputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self start];
        });
    } outputStream:assignmentOutputStream];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
}

- (void)start
{
    // currently there's only one type of assignment
    // so perform the float averaging now
    
    int numFloatsInData = 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self logStatus:@"Starting assignment..."];
    });
    
    do {
        numFloatsInData = 0;
        
        for (int i = 0; i < self.assignmentData.length - 4; i += 4) {
            // pull out the next two floats
            Float32 firstFloat, secondFloat, averageFloat;
            
            [self.assignmentData getBytes:&firstFloat range:NSMakeRange(i, 4)];
            [self.assignmentData getBytes:&secondFloat range:NSMakeRange(i + 4, 4)];
            
            averageFloat = (firstFloat + secondFloat) / 2;
            numFloatsInData++;
            
            // put the average float into the NSMutableData at the position of the first
            // and remove the second, shrinking the data
            [self.assignmentData replaceBytesInRange:NSMakeRange(i, 4) withBytes:&averageFloat length:4];
            [self.assignmentData replaceBytesInRange:NSMakeRange(i + 4, 4) withBytes:NULL length:0];
        
        }
    } while (numFloatsInData > 100);
    
    NSLog(@"Completed averaging of floats - There are %d in the result.", numFloatsInData);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self logStatus:@"Completed assignment, sending to server."];
    });
    
    [self complete];
}

- (void)complete {
    // post the results back to the server
    
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
