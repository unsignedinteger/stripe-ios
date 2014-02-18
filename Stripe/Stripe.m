//
//  Stripe.m
//  Stripe
//
//  Created by Saikat Chakrabarti on 10/30/12.
//  Copyright (c) 2012 Stripe. All rights reserved.
//

#import "Stripe.h"
#import "StripeUtil.h"

@implementation Stripe

static NSString *defaultKey;
static NSString *const apiURLBase = @"api.stripe.com";
static NSString *const apiVersion = @"v1";
static NSString *const tokenEndpoint = @"tokens";

+ (id)alloc
{
    [NSException raise:@"CannotInstantiateStaticClass" format:@"'Stripe' is a static class and cannot be instantiated."];
    return nil;
}

#pragma mark - Creating card tokens

+ (void)createTokenWithCard:(STPCard *)card publishableKey:(NSString *)publishableKey operationQueue:(NSOperationQueue *)queue completion:(STPCompletionBlock)completion
{
    if (card == nil) {
        [NSException raise:@"RequiredParameter" format:@"'card' is required to create a token"];
    }
    if (completion == nil) {
        [NSException raise:@"RequiredParameter" format:@"'completion' is required to use the token that is created"];
    }
    [self validatePublishableKey:publishableKey];

    [self executeRequestWithURL:[self apiURLWithPublishableKey:publishableKey endpoint:tokenEndpoint]
                         method:@"POST"
                           body:[StripeUtil formBodyFromDictionary:[card dictionaryRepresentation] withPrefix:@"card"]
                 operationQueue:[NSOperationQueue mainQueue]
                     completion:^(NSURLResponse *response, NSData *body, NSError *requestError) {
                         [self parseResponse:response body:body requestError:requestError completion:completion];
                     }];
}

#pragma mark - Fetching card tokens

+ (void)requestTokenWithID:(NSString *)tokenId publishableKey:(NSString *)publishableKey operationQueue:(NSOperationQueue *)queue completion:(STPCompletionBlock)completion
{
    if (tokenId == nil) {
        [NSException raise:@"RequiredParameter" format:@"'tokenId' is required to retrieve a token"];
    }
    if (completion == nil) {
        [NSException raise:@"RequiredParameter" format:@"'completion' is required to use the token that is requested"];
    }
    [self validatePublishableKey:publishableKey];

    [self executeRequestWithURL:[[self apiURLWithPublishableKey:publishableKey endpoint:tokenEndpoint] URLByAppendingPathComponent:tokenId]
                         method:@"GET"
                           body:nil
                 operationQueue:queue
                     completion:^(NSURLResponse *response, NSData *body, NSError *requestError) {
                         [self parseResponse:response body:body requestError:requestError completion:completion];
                     }];
}

#pragma mark - Publishable key

+ (NSString *)defaultPublishableKey
{
    return defaultKey;
}

+ (void)setDefaultPublishableKey:(NSString *)publishableKey
{
    [self validatePublishableKey:publishableKey];
    defaultKey = publishableKey;
}

#pragma mark - Shortcut methods

+ (void)createTokenWithCard:(STPCard *)card publishableKey:(NSString *)publishableKey completion:(STPCompletionBlock)completion
{
    [self createTokenWithCard:card publishableKey:publishableKey operationQueue:[NSOperationQueue mainQueue] completion:completion];
}

+ (void)createTokenWithCard:(STPCard *)card completion:(STPCompletionBlock)completion
{
    [self createTokenWithCard:card publishableKey:[self defaultPublishableKey] completion:completion];
}

+ (void)createTokenWithCard:(STPCard *)card operationQueue:(NSOperationQueue *)queue completion:(STPCompletionBlock)completion
{
    [self createTokenWithCard:card publishableKey:[self defaultPublishableKey] operationQueue:queue completion:completion];
}

+ (void)requestTokenWithID:(NSString *)tokenId publishableKey:(NSString *)publishableKey completion:(STPCompletionBlock)completion
{
    [self requestTokenWithID:tokenId publishableKey:publishableKey operationQueue:[NSOperationQueue mainQueue] completion:completion];
}

+ (void)requestTokenWithID:(NSString *)tokenId completion:(STPCompletionBlock)completion
{
    [self requestTokenWithID:tokenId publishableKey:[self defaultPublishableKey] operationQueue:[NSOperationQueue mainQueue] completion:completion];
}

+ (void)requestTokenWithID:(NSString *)tokenId operationQueue:(NSOperationQueue *)queue completion:(STPCompletionBlock)completion
{
    [self requestTokenWithID:tokenId publishableKey:[self defaultPublishableKey] operationQueue:queue completion:completion];
}

#pragma mark - Private Methods

// Returns root API URL to |endpoint| using |publishableKey|.
+ (NSURL *)apiURLWithPublishableKey:(NSString *)publishableKey endpoint:(NSString *)endpoint
{
    return [[[NSURL URLWithString:
            [NSString stringWithFormat:@"https://%@:@%@", [StripeUtil URLEncodedString:publishableKey], apiURLBase]]
            URLByAppendingPathComponent:apiVersion]
            URLByAppendingPathComponent:endpoint];
}

// Ensures |publishableKey| is a valid publishable key (throws an exception if not).
+ (void)validatePublishableKey:(NSString *)publishableKey
{
    if (!publishableKey || [publishableKey isEqualToString:@""]) {
        [NSException raise:@"InvalidPublishableKey" format:@"You must provide your publishable key, either in the function call or by using |setDefaultPublishableKey|. To get your publishable key, see https://manage.stripe.com/account/apikeys"];
    }

    if ([publishableKey hasPrefix:@"sk_"]) {
        [NSException raise:@"InvalidPublishableKey" format:@"You are using a secret key to create a token, instead of a publishable one. You must not include your secret key in your iOS app as it is a security risk. To get your publishable key, see https://manage.stripe.com/account/apikeys"];
    }
}

// Convenience method for executing requests.
+ (void)executeRequestWithURL:(NSURL *)URL
                       method:(NSString *)method
                         body:(NSData *)body
               operationQueue:(NSOperationQueue *)queue
                   completion:(void (^)(NSURLResponse *response, NSData *body, NSError *requestError))completion
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = method;
    if (body) {
        request.HTTPBody = body;
    }
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:completion];
}

// Parses |response| (parsing any errors) and runs |completion| with the appropriate parameters.
+ (void)parseResponse:(NSURLResponse *)response body:(NSData *)body requestError:(NSError *)requestError completion:(STPCompletionBlock)completion
{
    if (requestError) {
        NSDictionary *json = nil;
        if (body && (json = [StripeUtil dictionaryFromJSONData:body error:nil]) && json[@"error"]) {
            completion(nil, [self errorFromStripeResponse:json]); // Handle Stripe API errors as |StripeDomain| errors.
        }
        else {
            completion(nil, requestError); // Otherwise, return the raw NSURLError error.
        }
    }
    else {
        NSError *parseError;
        NSDictionary *json = [StripeUtil dictionaryFromJSONData:body error:&parseError];

        if (!json) {
            completion(nil, parseError);
        } else if ([(NSHTTPURLResponse *) response statusCode] == 200) {
            completion([[STPToken alloc] initWithAttributeDictionary:[self camelCasedResponseFromStripeResponse:json]], nil);
        } else {
            completion(nil, [self errorFromStripeResponse:json]);
        }
    }
}

// Returns the response dictionary with all values under the "card" key camelCased.
+ (NSDictionary *)camelCasedResponseFromStripeResponse:(NSDictionary *)response
{
    NSMutableDictionary *camelCasedResponse = [NSMutableDictionary dictionary];
    for (NSString *key in response) {
        if ([key isEqualToString:@"card"]) {
            camelCasedResponse[key] = [self camelCasedResponseFromStripeResponse:response[key]];
        } else {
            camelCasedResponse[[StripeUtil camelCaseFromUnderscoredString:key]] = response[key];
        }
    }
    return camelCasedResponse;
}

// Converts a Stripe API error into an |NSError|.
+ (NSError *)errorFromStripeResponse:(NSDictionary *)json
{
    NSString *type = json[@"error"][@"type"];
    NSString *serverMessage = json[@"error"][@"message"];

    // There should always be a message and type for the error.
    if (!serverMessage || !type) {
        return [[NSError alloc] initWithDomain:StripeDomain
                                          code:STPAPIError
                                      userInfo:@{
                                              NSLocalizedDescriptionKey : STPUnexpectedError,
                                              STPErrorMessageKey : @"Could not interpret the error response that was returned from Stripe."
                                      }];
    }

    NSInteger errorCode = 0;
    NSString *userDescription = serverMessage; // NOTE(saikat) This is probably not correct, but I think it's correct enough in most cases.
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:serverMessage forKey:STPErrorMessageKey];

    // |param| specifies which parameter caused the error.
    NSString *parameter = json[@"error"][@"param"];
    if (parameter) {
        userInfo[STPErrorParameterKey] = [StripeUtil camelCaseFromUnderscoredString:parameter];
    }

    // Determine what type of error it is.
    if ([type isEqualToString:@"api_error"]) {
        errorCode = STPAPIError;
        userDescription = STPUnexpectedError;
    }
    else if ([type isEqualToString:@"invalid_request_error"]) {
        errorCode = STPInvalidRequestError;
    }
    else if ([type isEqualToString:@"card_error"]) {
        errorCode = STPCardError;
        NSString *cardErrorCode = json[@"code"];
        if ([cardErrorCode isEqualToString:@"incorrect_number"]) {
            cardErrorCode = STPIncorrectNumber;
            userDescription = STPCardErrorInvalidNumberUserMessage;
        }
        else if ([cardErrorCode isEqualToString:@"invalid_number"]) {
            cardErrorCode = STPInvalidNumber;
            userDescription = STPCardErrorInvalidNumberUserMessage;
        }
        else if ([cardErrorCode isEqualToString:@"invalid_expiry_month"]) {
            cardErrorCode = STPInvalidExpMonth;
            userDescription = STPCardErrorInvalidExpMonthUserMessage;
        }
        else if ([cardErrorCode isEqualToString:@"invalid_expiry_year"]) {
            cardErrorCode = STPInvalidExpYear;
            userDescription = STPCardErrorInvalidExpYearUserMessage;
        }
        else if ([cardErrorCode isEqualToString:@"invalid_cvc"]) {
            cardErrorCode = STPInvalidCVC;
            userDescription = STPCardErrorInvalidCVCUserMessage;
        }
        else if ([cardErrorCode isEqualToString:@"expired_card"]) {
            cardErrorCode = STPExpiredCard;
            userDescription = STPCardErrorExpiredCardUserMessage;
        }
        else if ([cardErrorCode isEqualToString:@"incorrect_cvc"]) {
            cardErrorCode = STPIncorrectCVC;
            userDescription = STPCardErrorInvalidCVCUserMessage;
        }
        else if ([cardErrorCode isEqualToString:@"card_declined"]) {
            cardErrorCode = STPCardDeclined;
            userDescription = STPCardErrorDeclinedUserMessage;
        }
        else if ([cardErrorCode isEqualToString:@"processing_error"]) {
            cardErrorCode = STPProcessingError;
            userDescription = STPCardErrorProcessingErrorUserMessage;
        }

        userInfo[STPCardErrorCodeKey] = cardErrorCode;
    }

    userInfo[NSLocalizedDescriptionKey] = userDescription;
    return [[NSError alloc] initWithDomain:StripeDomain code:errorCode userInfo:userInfo];
}

@end
