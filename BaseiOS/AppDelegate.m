//
//  AppDelegate.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/8/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self customAppearanceStyles];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive.
    // If the application was previously in the background, optionally refresh the user interface.
    [AppUserDefaultsHandler getCustomerBalance];
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
    }
    
    return _locationManager;
}


#pragma mark - Appearance Styles
- (void)customAppearanceStyles
{
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"black"] forBarMetrics:UIBarMetricsDefault];
}

- (void)signOut
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        [cookieStorage deleteCookie:cookie];
    }
    [AppUserDefaultsHandler setCurrentCustomer:nil];
}

@end
