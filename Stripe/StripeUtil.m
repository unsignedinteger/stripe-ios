//
//  StripeUtil.m
//  Stripe
//
//  Created by Phillip Cohen on 12/10/13.
//
//

#import "StripeUtil.h"

@implementation StripeUtil

#pragma mark HTTP request creation

+ (NSData *)formBodyFromDictionary:(NSDictionary *)dictionary
{
    return [self formBodyFromDictionary:dictionary withPrefix:nil];
}

+ (NSData *)formBodyFromDictionary:(NSDictionary *)dictionary withPrefix:(NSString *)prefix
{
    NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:dictionary.count];
    for (id key in dictionary) {
        if (![key isEqual:[NSNull null]] && ![dictionary[key] isEqual:[NSNull null]]) {
            if (prefix) {
                [pairs addObject:[NSString stringWithFormat:@"%@[%@]=%@", prefix, [self URLEncodedString:key], [self URLEncodedString:dictionary[key]]]];
            } else {
                [pairs addObject:[NSString stringWithFormat:@"%@=%@", [self URLEncodedString:key], [self URLEncodedString:dictionary[key]]]];
            }
        }
    }

    return [[pairs componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
}


/**
* From http://stackoverflow.com/questions/3423545/objective-c-iphone-percent-encode-a-string.
* There is a CoreFoundation version that does this too.
*/
+ (NSString *)URLEncodedString:(NSString *)string
{
    NSMutableString *output = [NSMutableString string];
    // TODO(phil): C-style strings?
    const unsigned char *source = (const unsigned char *) [string UTF8String];
    int sourceLen = strlen((const char *) source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char c = source[i];
        if (c == ' ') {
            [output appendString:@"+"];
        } else if (c == '.' || c == '-' || c == '_' || c == '~' ||
                (c >= 'a' && c <= 'z') ||
                (c >= 'A' && c <= 'Z') ||
                (c >= '0' && c <= '9')) {
            [output appendFormat:@"%c", c];
        } else {
            [output appendFormat:@"%%%02X", c];
        }
    }
    return output;
}

+ (NSString *)camelCaseFromUnderscoredString:(NSString *)string
{
    if (!string) {
        return nil;
    }

    NSMutableString *output = [NSMutableString stringWithCapacity:string.length];
    BOOL makeNextCharacterUpperCase = NO;
    for (NSInteger index = 0; index < [string length]; index += 1) {
        NSString *character = [string substringWithRange:NSMakeRange(index, 1)];

        if ([character isEqualToString:@"_"]) {
            makeNextCharacterUpperCase = YES;
            continue;
        }

        if (makeNextCharacterUpperCase) {
            character = [character uppercaseString];
            makeNextCharacterUpperCase = NO;
        }

        [output appendString:character];
    }

    return output;
}

@end
