//
//  NSString+NSString___SizeForWidth.m
//  
//
//  Created by Peerbits MacMini9 on 29/03/16.
//
//

#import "NSString+NSString___SizeForWidth.h"

@implementation NSString (NSString___SizeForWidth)


-(CGSize)sizeForWidth:(CGFloat)width font:(UIFont *)font
{
    
    NSString *attr = font.fontName;
  
    CGRect height = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil
                  ];
    
    return CGSizeMake(width, ceil(height.size.height));
  
}

@end
