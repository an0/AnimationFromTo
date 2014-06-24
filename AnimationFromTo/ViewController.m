//
//  ViewController.m
//  AnimationFromTo
//
//  Created by Ling Wang on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "BallLayer.h"

const static CGPoint p1 = (CGPoint){160, -60};
const static CGPoint p2 = (CGPoint){160, 430};

@implementation ViewController {
    CALayer *ball;
    NSUInteger viewState;
    NSUInteger method;
    UILabel *label;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 120, 30)];
	label.backgroundColor = [UIColor clearColor];
	[self.view addSubview:label];
	
	ball = [[BallLayer alloc] init];
	ball.bounds = CGRectMake(0, 0, 60, 60);
	ball.position = p1;
	[ball setNeedsDisplay];
	[self.view.layer addSublayer:ball];
	
	UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[self.view addGestureRecognizer:tapRecognizer];
	
	method = 0;
	label.text = [NSString stringWithFormat:@"Method %lu", method + 1];
}

- (void)handleTap:(UIGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state != UIGestureRecognizerStateRecognized) return;
	
	switch (method) {
		case 0: // Property animation.
			if (viewState == 0) { // First tap.
				[CATransaction setAnimationDuration:1];
				ball.position = p2;
			} else { // Second tap.
				ball.position = p1;
			}
			break;

		case 1: // Explicit animation with cancellation.
			if (viewState == 0) { // First tap.
				CABasicAnimation *drop = [CABasicAnimation animationWithKeyPath:@"position"];
                drop.fromValue = [NSValue valueWithCGPoint:((CALayer *)ball.presentationLayer).position];
				drop.duration = 1;
				[ball addAnimation:drop forKey:@"drop"];
                
                // We are doing explicit animation so don't let the implicit animation interfere.
                [CATransaction setDisableActions:YES];
                ball.position = p2;
                [CATransaction setDisableActions:NO];
			} else { // Second tap.
				CABasicAnimation *bounce = [CABasicAnimation animationWithKeyPath:@"position"];
				[bounce setValue:@"bounce" forKey:@"tag"];
                bounce.fromValue = [NSValue valueWithCGPoint:((CALayer *)ball.presentationLayer).position];
				[ball addAnimation:bounce forKey:@"bounce"];
                
                // Remove drop animation.
                [ball removeAnimationForKey:@"drop"];

                // We are doing explicit animation so don't let the implicit animation interfere.
                [CATransaction setDisableActions:YES];
                ball.position = p1;
                [CATransaction setDisableActions:NO];
			}
			break;
			
		case 2: // Explicit animation with overwriting.
            if (viewState == 0) { // First tap.
                CABasicAnimation *drop = [CABasicAnimation animationWithKeyPath:@"position"];
                drop.fromValue = [NSValue valueWithCGPoint:((CALayer *)ball.presentationLayer).position];
                drop.duration = 1;
                [ball addAnimation:drop forKey:@"move"];
                
                // We are doing explicit animation so don't let the implicit animation interfere.
                [CATransaction setDisableActions:YES];
                ball.position = p2;
                [CATransaction setDisableActions:NO];
            } else { // Second tap.
                CABasicAnimation *bounce = [CABasicAnimation animationWithKeyPath:@"position"];
                bounce.fromValue = [NSValue valueWithCGPoint:((CALayer *)ball.presentationLayer).position];
                [ball addAnimation:bounce forKey:@"move"];
                
                // We are doing explicit animation so don't let the implicit animation interfere.
                [CATransaction setDisableActions:YES];
                ball.position = p1;
                [CATransaction setDisableActions:NO];
            }
			break;
			
		case 3: // Fall with property animation; rise with explicit animation.
            if (viewState == 0) { // First tap.
                [CATransaction setAnimationDuration:1];
                ball.position = p2;
            } else { // Second tap.
                CABasicAnimation *bounce = [CABasicAnimation animationWithKeyPath:@"position"];
                bounce.fromValue = [NSValue valueWithCGPoint:((CALayer *)ball.presentationLayer).position];
                [ball addAnimation:bounce forKey:@"position"];
                
                // We are doing explicit animation so don't let the implicit animation interfere.
                [CATransaction setDisableActions:YES];
                ball.position = p1;
                [CATransaction setDisableActions:NO];
            }
			break;
			
		case 4: // Fall with explicit animation; rise with property animation.
            if (viewState == 0) { // First tap.
                CABasicAnimation *drop = [CABasicAnimation animationWithKeyPath:@"position"];
                drop.fromValue = [NSValue valueWithCGPoint:((CALayer *)ball.presentationLayer).position];
                drop.duration = 1;
                [ball addAnimation:drop forKey:@"position"];
                
                // We are doing explicit animation so don't let the implicit animation interfere.
                [CATransaction setDisableActions:YES];
                ball.position = p2;
                [CATransaction setDisableActions:NO];
            } else { // Second tap.
                ball.position = p1;
            }
			break;
			
		default:
			break;
	}
	
	method = (method + viewState) % 5; // Switch to next method after second tap.
	label.text = [NSString stringWithFormat:@"Method %lu", method + 1]; // Update label.
	viewState = !viewState; // Switch between states.
}

@end
