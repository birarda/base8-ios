//
//  Customer.h
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/10/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

@interface Customer : NSObject <NSCoding>

@property (strong, nonatomic) NSNumber *customerId;
@property (strong, nonatomic) NSNumber *twitterId;
@property (strong, nonatomic) NSString *twitterName;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSDate *joinDate;
@property (strong, nonatomic) NSString *oauthToken;
@property (strong, nonatomic) NSString *oauthSecret;
@property (nonatomic) double balance;

-(id)initFromDictionary:(NSDictionary *)userDict;

@end