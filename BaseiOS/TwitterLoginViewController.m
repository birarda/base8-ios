//
//  TwitterLoginViewController.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/9/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "TwitterLoginViewController.h"
#import "TWAPIManager.h"

@interface TwitterLoginViewController ()

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) NSArray *accounts;

@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityLogin;

@end

@implementation TwitterLoginViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.accountStore) {
        self.accountStore = [[ACAccountStore alloc] init];
        self.buttonLogin.hidden = NO;
        self.navigationController.navigationBarHidden = YES;
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != (actionSheet.numberOfButtons - 1)) {
        [self performReverseAuthForAccount:self.accounts[(NSUInteger) buttonIndex]];
    }
}

#pragma mark - Private

-(void)performReverseAuthForAccount:(ACAccount *)account
{
    
    self.buttonLogin.hidden = YES;
    [self.activityLogin startAnimating];
    
    TWAPIManager *apiManager = [[TWAPIManager alloc] init];
    [apiManager performReverseAuthForAccount:account
                                 withHandler:^(NSData *responseData, NSError *error) {
                                     
                                         if (responseData) {
                                             NSString *responseStr = [[NSString alloc] initWithData:responseData
                                                                                           encoding:NSUTF8StringEncoding];
                                             
                                             NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
                                             
                                             if (parts.count == 0) {
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter authorization error"
                                                                                                 message:@"Please check Twitter settings on your device."
                                                                                                delegate:nil
                                                                                       cancelButtonTitle:@"OK"
                                                                                       otherButtonTitles:nil];
                                                 [alert show];
                                                 return;
                                             }
                                             
                                             NSMutableDictionary *twitterData = [[NSMutableDictionary alloc] init];
                                             
                                             for (NSString *part in parts) {
                                                 
                                                 NSArray *pairComponents = [part componentsSeparatedByString:@"="];
                                                 NSString *key = [pairComponents objectAtIndex:0];
                                                 NSString *value = [pairComponents objectAtIndex:1];
                                                 
                                                 [twitterData setObject:value forKey:key];
                                             }
                                             
                                             [ApiHelper signInWithTwitterData:twitterData
                                                                andCompletion:^(NSDictionary *json, NSError *signInError) {

                                                                  self.buttonLogin.hidden = NO;
                                                                  [self.activityLogin stopAnimating];
                                                                  if (!signInError) {
                                                                      
                                                                      NSDictionary *customer = json[@"customer"];
                                                                      Customer *currentCustomer = [[Customer alloc] initFromDictionary:customer];
                                                                      [AppUserDefaultsHandler setCurrentCustomer:currentCustomer];
                                                                      [self dismissModalViewControllerAnimated:YES];
                                                                      
                                                                  } else {
                                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Signin Error"
                                                                                                                      message:signInError.localizedDescription
                                                                                                                     delegate:nil
                                                                                                            cancelButtonTitle:@"OK"
                                                                                                            otherButtonTitles:nil];
                                                                      [alert show];
                                                                  }
                                                                  
                                                              }];
                                             
                                         } else {
                                             NSLog(@"Error!\n%@", [error localizedDescription]);
                                             
                                             self.buttonLogin.hidden = NO;
                                             [self.activityLogin stopAnimating]; 
                                         }
                                     
                                 }];
    
}

- (void)obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
{
    ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                self.accounts = [self.accountStore accountsWithAccountType:twitterType];
            }
            
            block(granted);
        });
    };
    
    //  This method changed in iOS6.  If the new version isn't available, fall
    //  back to the original (which means that we're running on iOS5+).
    if ([self.accountStore respondsToSelector:@selector(requestAccessToAccountsWithType: options: completion:)]) {
        [self.accountStore requestAccessToAccountsWithType:twitterType
                                                   options:nil
                                                completion:handler];
    } else {
        [self.accountStore requestAccessToAccountsWithType:twitterType
                                     withCompletionHandler:handler];
    }
}

- (IBAction)twitterLoginTapped:(id)sender
{
    [self obtainAccessToAccountsWithBlock:^(BOOL granted) {
        
        if (granted && [TWAPIManager isLocalTwitterAccountAvailable] && self.accounts.count > 0) {
            if (self.accounts.count == 1) {
                [self performReverseAuthForAccount:self.accounts[0]];
                
            } else {
                UIActionSheet *sheet = [[UIActionSheet alloc]
                                        initWithTitle:@"Choose an Account"
                                        delegate:self
                                        cancelButtonTitle:nil
                                        destructiveButtonTitle:nil
                                        otherButtonTitles:nil];
                
                for (ACAccount *acct in self.accounts) {
                    [sheet addButtonWithTitle:acct.username];
                }
                
                [sheet addButtonWithTitle:@"Cancel"];
                [sheet setDestructiveButtonIndex:[self.accounts count]];
                [sheet showInView:self.view];
            }
        } else {
            
            @try {
                
                // Set up the built-in twitter composition view controller.
                TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
                
                // Create the completion handler block.
                [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                    [self dismissModalViewControllerAnimated:YES];
                }];
                
                // Present the tweet composition view controller modally.
                [self presentModalViewController:tweetViewController animated:YES];
                for (UIView *view in tweetViewController.view.subviews){
                    [view removeFromSuperview];
                }
                
            } @catch (NSException *e) {
                
                NSLog(@"Exception: %@", e);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Accounts"
                                                                message:@"Please configure a Twitter account in Settings.app"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }];
}

@end
