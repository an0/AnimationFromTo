//
//  BallLayer.m
//  AnimationFrom
//
//  Created by Ling Wang on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BallLayer.h"

@implementation BallLayer

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
	CGContextSaveGState(ctx);
    CGRect bounds = self.bounds;
    CGMutablePathRef clipPath = CGPathCreateMutable();
    CGPathAddEllipseInRect(clipPath, NULL, CGRectMake(0.5, 0.5, bounds.size.width-1, bounds.size.height-1));
    CGContextAddPath(ctx, clipPath);
    CGContextClip(ctx);
    CGPathRelease(clipPath);
    CGGradientRef gradient;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 0.9, 0.1,0, 1.0,  // Start color
        0.3, 0.1, 0, 1.0 }; // End color
    
    gradient = CGGradientCreateWithColorComponents (colorSpace, components,
													locations, num_locations);
    CGColorSpaceRelease(colorSpace);
    CGPoint startPoint, endPoint;
    CGFloat startRadius, endRadius;
    startPoint.x = CGRectGetMidX(bounds)-12;
    startPoint.y =  CGRectGetMidY(bounds)-10;
    endPoint.x = CGRectGetMidX(bounds);
    endPoint.y = CGRectGetMidY(bounds);
    startRadius = 0;
    endRadius = CGRectGetWidth(bounds)/2;
    CGContextDrawRadialGradient (ctx, gradient, startPoint,
                                 startRadius, endPoint, endRadius,0
                                 /*kCGGradientDrawsAfterEndLocation*/);
    CGGradientRelease(gradient);
    CGContextRestoreGState(ctx);
}

@end
