//
//  StripeUtil.h
//  Stripe
//
//  Created by Phillip Cohen on 12/10/13.
//
//

#import <Foundation/Foundation.h>

/**
* Utility methods for making API requests.
*/
@interface StripeUtil : NSObject

// Creates a HTTP POST form body from the given dictionary.
+ (NSData *)formBodyFromDictionary:(NSDictionary *)dictionary;
+ (NSData *)formBodyFromDictionary:(NSDictionary *)dictionary withPrefix:(NSString *)prefix; // All variables will be prefixed, ie card[foo]=bar.

// URL-encodes the given string.
+ (NSString *)URLEncodedString:(NSString *)string;

@end
