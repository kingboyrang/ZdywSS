#import "NSString+Additions.h"

@implementation NSString (Acani)

/**
 * @brief 参数 [NSCharacterSet whitespaceAndNewlineCharacterSet]  删除字符串左侧的空格和换行符 
 *        or 参数 [NSCharacterSet whitespaceCharacterSet]         不删除换左侧行符和新行，只去除空格
 */
- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet
{
    NSRange rangeOfFirstWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]];
    if (rangeOfFirstWantedCharacter.location == NSNotFound)
    {
        return @"";
    }
    return [self substringFromIndex:rangeOfFirstWantedCharacter.location];
}

/**
 * @brief  删除字符串左侧的空格和换行符
 */
- (NSString *)stringByTrimmingLeadingWhitespaceAndNewlineCharacters
{
    return [self stringByTrimmingLeadingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/**
 * @brief 参数 [NSCharacterSet whitespaceAndNewlineCharacterSet]  删除字符串右侧的空格和换行符 
 *        or 参数 [NSCharacterSet whitespaceCharacterSet]         不删除换右侧行符和新行，只去除空格
 */
- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet
{
    NSRange rangeOfLastWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]
                                                                options:NSBackwardsSearch];
    if (rangeOfLastWantedCharacter.location == NSNotFound)
    {
        return @"";
    }
    return [self substringToIndex:rangeOfLastWantedCharacter.location+1]; // non-inclusive
}

/**
 * @brief  删除字符串右侧的空格和换行符
 */
- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters
{
    return [self stringByTrimmingTrailingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
