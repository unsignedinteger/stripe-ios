//
//  StripeUtilTest.m
//  Stripe
//
//  Created by Phil Cohen on 2/18/14.
//

#import "StripeUtilTest.h"
#import "StripeUtil.h"

@implementation StripeUtilTest

- (void)testFormBodyFromDictionary
{
    NSDictionary *testCases = @{
            @{@"param1" : @"value1", @"param2" : @"value2"} : @"param1=value1&param2=value2"
    };

    for (NSString *key in testCases) {
        STAssertEqualObjects([StripeUtil formBodyFromDictionary:key], [testCases[key] dataUsingEncoding:NSUTF8StringEncoding],
        @"A proper form body should be generated."
        );
    }
}

- (void)testFormBodyFromDictionaryWithPrefix
{
    NSDictionary *testCases = @{
            @{@"param1" : @"value1", @"param2" : @"value2"} : @"card[param1]=value1&card[param2]=value2"
    };

    for (NSString *key in testCases) {
        STAssertEqualObjects([StripeUtil formBodyFromDictionary:key withPrefix:@"card"], [testCases[key] dataUsingEncoding:NSUTF8StringEncoding],
        @"A proper form body should be generated."
        );
    }
}

- (void)testURLEncodedString
{
    NSDictionary *testCases = @{
            @"https://stripe.com/docs/api?query=foo bar" : @"https%3A%2F%2Fstripe.com%2Fdocs%2Fapi%3Fquery%3Dfoo+bar",
            @"&=*" : @"%26%3D%2A"
    };

    for (NSString *key in testCases) {
        STAssertEqualObjects([StripeUtil URLEncodedString:key], testCases[key], @"URL should be URL encoded correctly.");
    }
}

@end