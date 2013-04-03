//
//  Customer.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/10/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

@implementation Customer
-(id)initFromDictionary:(NSDictionary *)userDict
{
    self = [super init];
    if (self) {
        self.customerId = userDict[@"id"];
        self.twitterId = userDict[@"twitterId"];
        self.twitterName = userDict[@"twitterName"];
        self.nickname = userDict[@"nickname"];
        self.balance = [userDict[@"balance"] doubleValue];
        self.joinDate = userDict[@"joinDate"];
        self.oauthToken = userDict[@"oauthToken"];
        self.oauthSecret = userDict[@"oauthSecret"];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        @try {
            
            self.customerId = [decoder decodeObjectForKey:@"id"];
            self.twitterId = [decoder decodeObjectForKey:@"twitterId"];
            self.twitterName = [decoder decodeObjectForKey:@"twitterName"];
            self.nickname = [decoder decodeObjectForKey:@"nickname"];
            self.joinDate = [decoder decodeObjectForKey:@"joinDate"];
            self.oauthToken = [decoder decodeObjectForKey:@"oauthToken"];
            self.oauthSecret = [decoder decodeObjectForKey:@"oauthSecret"];
            self.balance = [decoder decodeDoubleForKey:@"balance"];
            
        } @catch (NSException *e) {
            NSLog(@"Exception: %@", e);
        }
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.customerId forKey:@"id"];
    [encoder encodeObject:self.twitterId forKey:@"twitterId"];
    [encoder encodeObject:self.twitterName forKey:@"twitterName"];
    [encoder encodeObject:self.nickname forKey:@"nickname"];
    [encoder encodeDouble:self.balance forKey:@"balance"];
    [encoder encodeObject:self.joinDate forKey:@"joinDate"];
    [encoder encodeObject:self.oauthToken forKey:@"oauthToken"];
    [encoder encodeObject:self.oauthSecret forKey:@"oauthSecret"];
}


@end
