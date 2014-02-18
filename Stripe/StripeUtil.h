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

// Converts |string| from underscore_format to camelCase.
+ (NSString *)camelCaseFromUnderscoredString:(NSString *)string;

// Parses |data| into an |NSDictionary|; if it fails, writes an error (STPUnexpectedError) to |error|.
+ (NSDictionary *)dictionaryFromJSONData:(NSData *)data error:(NSError **)error;

@end
