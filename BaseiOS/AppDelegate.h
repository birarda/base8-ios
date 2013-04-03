//
//  AppDelegate.h
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/8/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CLLocationManager *locationManager;

- (void)signOut;

@end
