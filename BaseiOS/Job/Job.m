//
//  Job.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/20/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "Job.h"

#define POLL_INTERVAL_SECONDS 5

@interface Job() <NSStreamDelegate>

@property (strong, nonatomic) NSTimer *pollTimer;
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

- (void)startWaiting
{
    if (!self.pollTimer) {
        self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:POLL_INTERVAL_SECONDS
                                                             target:self
                                                           selector:@selector(createOrWaitForWorking)
                                                           userInfo:nil
                                                            repeats:YES];
        [self logStatus:@"Waiting for assignment..."];
    }
}

- (void)createOrWaitForWorking
{
    [ApiHelper startAssignment:^(id response, NSError *error) {
        if (!error) {
            if (!response || [response[@"message"] isEqualToString:@"cancelled"]) {
                [ApiHelper createAssignment:^(id response, NSError *error) {
                    if (error) {
                        NSLog(@"Error creating assignment: %@", error.localizedDescription);
                    }
                }];
            } else if ([response[@"message"] isEqualToString:@"pending"]) {                
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
    
    [self.pollTimer invalidate];
    self.pollTimer = nil;

    [ApiHelper loadAssignment:^(id response, NSError *error) {
        self.assignmentData = response;
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self start];
        });
    } outputStream:nil];
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
        
        // pull out the next two floats
        Float32 firstFloat = 0, secondFloat = 0, averageFloat = 0;
        
        for (int i = 0; i < self.assignmentData.length - 4; i += 4) {
            
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
    
    [self upload];
}

- (void)upload {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self logStatus:@"Completed assignment, sending to server..."];
    });
    
    NSMutableString *resultString = [NSMutableString string];
    
    int stringIndex = 0;
    NSString *thisFloatString;
    Float32 thisFloat = 0;
    
    for (int i = 0; i < self.assignmentData.length; i += 4) {
        // add the float at this position to the float string
        [self.assignmentData getBytes:&thisFloat range:NSMakeRange(i, 4)];
        thisFloatString = [NSString stringWithFormat:@"%.4f", thisFloat];
        
        [resultString insertString:thisFloatString atIndex:stringIndex];
        
        stringIndex += thisFloatString.length;
    }

    
    // post the results back to the server
    [ApiHelper uploadAssignment:^(id response, NSError *error) {
        if (!error) {
            int jobID = [response[@"assignment"][@"jobId"] intValue];
            self.identifier = @(jobID);
            
            // we need to start a timer to check the assignment status
            [self repeatStatusCheck];
        } else {
            NSLog(@"Error uploading assignment: %@", error.localizedDescription);
        }
    } resultString:resultString];
}

- (void)repeatStatusCheck
{
    self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:POLL_INTERVAL_SECONDS
                                                      target:self
                                                    selector:@selector(checkStatus)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)checkStatus
{
    [ApiHelper getBalance:^(id response, NSError *error) {
        NSLog(@"The balance - %@", response);
    } optionalJobID:self.identifier];
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
