//
//  AppConstants.h
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/9/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

@class NSString;

@interface AppConstants : NSObject

// api methods constants
extern NSString* const kSignInApiMethod;
extern NSString* const kDownloadTestApiMethod;
extern NSString* const kUploadTestApiMethod;
extern NSString* const kTestEndApiMethod;
extern NSString* const kGetBalanceApiMethod;
extern NSString* const kTestFailApiMethod;
extern NSString* const kTestRequestApiMethod;

extern NSString* const kApiURL;
extern NSString* const kTwitterCounsumerKey;
extern NSString* const kTwitterCounsumerSecret;
extern NSString* const kUdpServer;
extern uint16_t const kUdpPort;


@end
