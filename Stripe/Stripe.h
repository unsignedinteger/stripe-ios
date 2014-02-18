//
//  Stripe.h
//  Stripe
//
//  Created by Saikat Chakrabarti on 10/30/12.
//  Copyright (c) 2012 Stripe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StripeError.h"
#import "STPCard.h"
#import "STPToken.h"

typedef void (^STPCompletionBlock)(STPToken *token, NSError *error);

/**
 * The Stripe API is used to create and retrieve tokens.
 *
 * The usual workflow:
 *   1) Collect card details from your users.
 *   2) Use the Stripe class to create a token (STPToken) from the details.
 *   3) Send this token to your server, and use it to create charges, customers, etc.
 *
 * You can get your publishable key at https://manage.stripe.com/account/apikeys.
 * DO NOT use your secret key, or embed your secret key in your application.
 */
@interface Stripe : NSObject

// Creates a Stripe token from the given card details (|card|).
+ (void)createTokenWithCard:(STPCard *)card publishableKey:(NSString *)publishableKey completion:(STPCompletionBlock)completion;
+ (void)createTokenWithCard:(STPCard *)card publishableKey:(NSString *)publishableKey operationQueue:(NSOperationQueue *)queue completion:(STPCompletionBlock)completion;
+ (void)createTokenWithCard:(STPCard *)card completion:(STPCompletionBlock)completion;
+ (void)createTokenWithCard:(STPCard *)card operationQueue:(NSOperationQueue *)queue completion:(STPCompletionBlock)completion;

// Checks to see if a token is still valid (as they can only be used once). An error will be returned in |completion| if not.
+ (void)requestTokenWithID:(NSString *)tokenId publishableKey:(NSString *)publishableKey completion:(STPCompletionBlock)completion;
+ (void)requestTokenWithID:(NSString *)tokenId publishableKey:(NSString *)publishableKey operationQueue:(NSOperationQueue *)queue completion:(STPCompletionBlock)completion;
+ (void)requestTokenWithID:(NSString *)tokenId completion:(STPCompletionBlock)completion;
+ (void)requestTokenWithID:(NSString *)tokenId operationQueue:(NSOperationQueue *)queue completion:(STPCompletionBlock)completion;

// Globally sets your publishableKey so you don't have to pass it with each method call.
+ (void)setDefaultPublishableKey:(NSString *)publishableKey;
+ (NSString *)defaultPublishableKey;

@end
