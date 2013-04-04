//
//  AppUserDefaultsHandler.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/11/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

// define a way to quickly grab and set NSUserDefaults
#define DEFAULTS(type, key) ([[NSUserDefaults standardUserDefaults] type##ForKey:key])
#define SET_DEFAULTS(Type, key, val) do {\
[[NSUserDefaults standardUserDefaults] set##Type:val forKey:key];\
[[NSUserDefaults standardUserDefaults] synchronize];\
} while (0)

@implementation AppUserDefaultsHandler

NSString* const kCurrentCustomer = @"loggedCustomer";

+ (void)setCurrentCustomer:(Customer *)currentCustomer
{
    // encode the user object
    NSData *encodedUser = [NSKeyedArchiver archivedDataWithRootObject:currentCustomer];
    
    // store it in user defaults
    SET_DEFAULTS(Object, kCurrentCustomer, encodedUser);

    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginStateChanged" object:nil];
}

+ (void)getCustomerBalance
{
    if (AppUserDefaultsHandler.currentCustomer) {
        [ApiHelper getBalance:^(id response, NSError *error) {
            if (!error) {
                double balance = [response[@"balance"] doubleValue];
                if (AppUserDefaultsHandler.currentCustomer.balance != balance) {

                    Customer *customer = AppUserDefaultsHandler.currentCustomer;
                    customer.balance = balance;
                    [AppUserDefaultsHandler setCurrentCustomer:customer];
                }
            }
        }];
    }
}


+ (Customer *)currentCustomer
{
    Customer *customer;

    if (DEFAULTS(object, kCurrentCustomer)) {
        NSData *myEncodedObject = DEFAULTS(object, kCurrentCustomer);
        customer = (Customer *)[NSKeyedUnarchiver unarchiveObjectWithData:myEncodedObject];
    }
    
    return customer;
}

@end
