//
//  ViewControllerTest.m
//  StripeExample
//
//  Created by Jack Flintermann on 10/22/14.
//  Copyright (c) 2014 Stripe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ViewController.h"
#import "STPTestPaymentAuthorizationViewController.h"

@interface TestViewController : ViewController
@property (nonatomic) UIViewController *testPresentedController;
@property (nonatomic) BOOL useApplePay;
@end
@implementation TestViewController

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    self.testPresentedController = viewControllerToPresent;
}

- (BOOL)isDebugBuild {
    return YES;
}

- (BOOL)canUseApplePayWithRequest:(id)request {
    return self.useApplePay;
}

@end

@interface ViewControllerTest : XCTestCase
@end

@implementation ViewControllerTest

- (void)testBeginPaymentWithApplePay {
    TestViewController *testController = [TestViewController new];
    testController.useApplePay = YES;
    [testController beginPayment:nil];
    XCTAssertEqualObjects(NSStringFromClass(testController.testPresentedController.class),
                          NSStringFromClass([STPTestPaymentAuthorizationViewController class]));
}

- (void)testBeginPaymentWithLegacyPayment {
    TestViewController *testController = [TestViewController new];
    [testController beginPayment:nil];
    XCTAssertEqualObjects(testController.testPresentedController.class, [UINavigationController class]);
}

@end
