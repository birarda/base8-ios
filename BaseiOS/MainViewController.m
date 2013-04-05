//
//  MainViewController.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/10/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "MainViewController.h"
#import "TwitterLoginViewController.h"

@interface MainViewController ()

@property (strong, nonatomic) Job *currentJob;

@property (weak, nonatomic) IBOutlet UILabel *labelBalance;
@property (weak, nonatomic) IBOutlet UIButton *buttonTestConnection;
@property (weak, nonatomic) IBOutlet UIButton *buttonStartAssignment;
@property (weak, nonatomic) IBOutlet UITextView *textViewLog;

@end

@implementation MainViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userStateChanged)
                                                 name:@"LoginStateChanged"
                                               object:nil];

    UILabel* labelNavTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 190, 40)];
    labelNavTitle.textColor = [UIColor whiteColor];
    labelNavTitle.backgroundColor = [UIColor clearColor];

    labelNavTitle.textAlignment = NSTextAlignmentLeft;

    if (AppUserDefaultsHandler.currentCustomer) {
        labelNavTitle.text = [NSString stringWithFormat:@"@%@", AppUserDefaultsHandler.currentCustomer.twitterName];
        
        CLLocation *userLocation = [Base8AppDelegate locationManager].location;
        if (!userLocation) {
            userLocation = [[CLLocation alloc] init];
        }
        
        // we have a logged in user, tell the current job to start waiting
        [self.currentJob repeatStatusCheck];        
    } else {

        labelNavTitle.text = @"";
        TwitterLoginViewController *viewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                                bundle:nil]
                instantiateViewControllerWithIdentifier:@"loginView"];
        [self presentViewController:viewController animated:NO completion:nil];
    }
    
    [self updateCustomerBalanceLabel];
    self.navigationItem.titleView = labelNavTitle;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (Job *)currentJob
{
    if (!_currentJob) {
        _currentJob = [[Job alloc] initWithDelegate:self];
    }
    
    return _currentJob;
}

- (void)userStateChanged
{
    if (!AppUserDefaultsHandler.currentCustomer) {
        TwitterLoginViewController *viewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                                bundle:nil]
                instantiateViewControllerWithIdentifier:@"loginView"];
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        [self updateCustomerBalanceLabel];
    }
}

- (void)updateCustomerBalanceLabel
{
    Customer *currentCustomer = AppUserDefaultsHandler.currentCustomer;
    
    if (currentCustomer) {
        NSString *balanceText = [NSString stringWithFormat:@"%.2f pc", currentCustomer.balance];
        self.labelBalance.text = balanceText;
    } else {
        self.labelBalance.text = @"";
    }
}

- (IBAction)buttonLogoutTapped:(id *)sender
{
    [Base8AppDelegate signOut];
}

- (IBAction)testConnectionTapped:(UIButton *)sender
{
    self.textViewLog.text = @"";
    
    [self replaceButtonWithSpinner:sender];
    
    TestJob *testJob = [[TestJob alloc] initWithDelegate:self];
    [testJob start];
}

#define BUTTON_SPINNER_TAG 4213

- (void)replaceButtonWithSpinner:(UIButton *)button
{
    UIActivityIndicatorView *newSpinner = [[UIActivityIndicatorView alloc]
                                           initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    newSpinner.center = CGPointMake(CGRectGetMaxX(button.frame) - (newSpinner.frame.size.width / 2),
                                    CGRectGetMidY(button.frame));
    newSpinner.tag = BUTTON_SPINNER_TAG;
    [newSpinner startAnimating];
    [newSpinner setColor:[UIColor blackColor]];
    [self.view addSubview:newSpinner];
    
    button.hidden = YES;
}

-(void)logCall:(NSString *)logLine
{
    self.textViewLog.text = [NSString stringWithFormat:@"%@\n%@",  self.textViewLog.text, logLine];
}

#pragma mark JobDelegate
-(void)didFinish:(NSString *)status
{
    [self logCall:status];
    
    self.buttonTestConnection.hidden = NO;
    [[self.view viewWithTag:BUTTON_SPINNER_TAG] removeFromSuperview];
    
    [AppUserDefaultsHandler getCustomerBalance];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Job done"
                                                    message:@"You have been credited with 1PC"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)onError:(NSError *)error
{
    self.buttonTestConnection.enabled = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)onJobLog:(NSString *)logLine
{
    [self logCall:logLine];
}

@end
