//
//  AttrbuteString.m
//  AmHappy
//
//  Created by Syntel-Amargoal1 on 9/4/16.
//
//

#import "AttrbuteString.h"

@implementation AttrbuteString
-(void)setColorForText:(NSString*) textToFind withColor:(UIColor*) color
{
    NSRange range = [self.mutableString rangeOfString:textToFind options:NSCaseInsensitiveSearch];
    
    if (range.location != NSNotFound) {
        [self addAttribute:NSForegroundColorAttributeName value:color range:range];
    }
}
@end
