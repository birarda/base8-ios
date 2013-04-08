//
//  ApiHelper.h
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/11/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

typedef void (^apiCompletion)(id response, NSError *error);

@interface ApiHelper : NSObject

+ (void)createAssignment:(apiCompletion)completion;
+ (void)startAssignment:(apiCompletion)completion;
+ (void)loadAssignment:(apiCompletion)completion outputStream:(NSOutputStream *)outputStream;
+ (void)uploadAssignment:(apiCompletion)completion resultString:(NSString *)resultString;
+ (void)downloadTest:(apiCompletion)completion;
+ (void)uploadTest:(id)testData andCompletion:(apiCompletion)completion;
+ (void)getTestConfigurationWithCompletion:(apiCompletion)completion;
+ (void)setTestFail:(apiCompletion)completion;
+ (void)finishJob:(NSArray *)testData withCompletion:(apiCompletion)completion;
+ (void)getBalance:(apiCompletion)completion optionalAssignmentHash:(NSString *)optionalAssignmentHash;
+ (void)signInWithTwitterData:(NSDictionary *)twitterData
                andCompletion:(apiCompletion)completion;

@end
