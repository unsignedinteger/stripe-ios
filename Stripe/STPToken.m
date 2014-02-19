//
//  STPToken.m
//  Stripe
//
//  Created by Saikat Chakrabarti on 11/5/12.
//
//

#import "STPToken.h"
#import "STPCard.h"
#import "StripeUtil.h"

@implementation STPToken

- (id)initWithAttributeDictionary:(NSDictionary *)attributeDictionary
{
    if (self = [super init]) {
        _tokenId = attributeDictionary[@"id"];
        _object = attributeDictionary[@"object"];
        _livemode = [attributeDictionary[@"livemode"] boolValue];
        _created = [NSDate dateWithTimeIntervalSince1970:[attributeDictionary[@"created"] doubleValue]];
        _used = [attributeDictionary[@"used"] boolValue];
        _card = [[STPCard alloc] initWithAttributeDictionary:attributeDictionary[@"card"]];
    }
    return self;
}

- (void)postToURL:(NSURL *)url withParams:(NSDictionary *)params completion:(void (^)(NSURLResponse *, NSData *, NSError *))completion
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [StripeUtil formBodyFromDictionary:params];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:completion];
}

@end
