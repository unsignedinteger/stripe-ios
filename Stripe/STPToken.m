//
//  STPToken.m
//  Stripe
//
//  Created by Saikat Chakrabarti on 11/5/12.
//
//

#import "STPToken.h"
#import "STPCard.h"

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

- (void)postToURL:(NSURL *)url withParams:(NSDictionary *)params completion:(void (^)(NSURLResponse *, NSData *, NSError *))handler
{
    NSMutableString *body = [NSMutableString stringWithFormat:@"stripeToken=%@", self.tokenId];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [body appendFormat:@"&%@=%@", key, obj];
    }];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:handler];
}

@end
