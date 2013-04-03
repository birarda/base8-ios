//
//  AppUserDefaultsHandler.h
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/11/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

@interface AppUserDefaultsHandler : NSObject

+(Customer *)currentCustomer;

+(void)setCurrentCustomer:(Customer *)currentCustomer;
+(void)getCustomerBalance;

@end
