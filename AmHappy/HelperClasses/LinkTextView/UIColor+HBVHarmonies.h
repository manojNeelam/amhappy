//
//  UIColor+HBVHarmonies.h
//  Herbivore
//
//  Created by Travis Henspeter on 3/5/14.
//  Copyright (c) 2014 Herbivore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HBVHarmonies)

- (UIColor *)colorHarmonyWithExpression:(CGFloat(^)(CGFloat value))expression alpha:(CGFloat)alpha;
+ (UIColor *)randomColor;
- (UIColor *)complement;
- (UIColor *)jitterWithPercent:(CGFloat)percent;

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net
