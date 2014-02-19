//
//  PaymentViewController.m
//
//  Created by Alex MacCaw on 2/14/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#import "PaymentViewController.h"
#import "MBProgressHUD.h"
#define STRIPE_PUBLISHABLE_KEY @"pk_test_6pRNASCoBOKtIshFeQd4XMUh"

@interface PaymentViewController ()
- (void)hasError:(NSError *)error;
- (void)hasToken:(STPToken *)token;
@end

@implementation PaymentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Add Card";
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
      self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Setup save button
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:0 target:self action:@selector(save:)];
    saveButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // Setup checkout
    self.checkoutView = [[STPView alloc] initWithFrame:CGRectMake(15,20,290,55) andKey:STRIPE_PUBLISHABLE_KEY];
    self.checkoutView.delegate = self;
    [self.view addSubview:self.checkoutView];
}

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    // Enable save button if the Checkout is valid
    self.navigationItem.rightBarButtonItem.enabled = valid;
}

- (IBAction)save:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self.checkoutView createToken:^(STPToken *token, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (error) {
            [self hasError:error];
        } else {
            [self hasToken:token];
        }
    }];
}

- (void)hasError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"There was an error submitting your card details", @"Shown in an alert view")
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil] show];
}

- (void)hasToken:(STPToken *)token
{
    NSLog(@"Hooray! Received a token from Stripe: %@", token.tokenId);

    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success!", @"Shown in an alert view")
                                message:@"The card details were submitted successfully.\n\nNext, send the token to your servers."
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                      otherButtonTitles:nil] show];
    [self.navigationController popViewControllerAnimated:YES];

    // Use this to send the token to your server. (Or, reuse your own API)
    /*
    [token postToURL:[NSURL URLWithString:@"https://example.com"]
          withParams:@{ @"token": token.tokenId } // (Could also include user ID, etc).
          completion:^(NSURLResponse *response, NSData *data, NSError *error) {

          }];
    */
}

@end
