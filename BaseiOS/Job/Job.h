//
//  Job.h
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/20/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

@protocol JobDelegate

@optional
- (void)onJobLog:(NSString *)logLine;
- (void)onError:(NSError *)error;
- (void)didFinish:(NSString *)status;

@end

@interface Job : NSObject

@property (strong, nonatomic) NSNumber *identifier;
@property (nonatomic) id<JobDelegate> delegate;

- (id)initWithDelegate:(id<JobDelegate>)delegate;
- (void)startWaiting;
- (void)stop;

@end
