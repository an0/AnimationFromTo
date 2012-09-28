//
//  AnimationFromToViewController.m
//  AnimationFromTo
//
//  Created by Ling Wang on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimationFromToViewController.h"
#import "BallLayer.h"


const static CGPoint p1 = (CGPoint){160, -60};
const static CGPoint p2 = (CGPoint){160, 430};


@implementation AnimationFromToViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
	label.backgroundColor = [UIColor clearColor];
	[self.view addSubview:label];
	
	ball = [[BallLayer alloc] init];
	ball.bounds = CGRectMake(0, 0, 60, 60);
	ball.position = p1;
	[ball setNeedsDisplay];
	[self.view.layer addSublayer:ball];
	
	UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
	[self.view addGestureRecognizer:tapRecognizer];
	
	method = 0;
	label.text = [NSString stringWithFormat:@"Method %d", method + 1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)tapRecognized:(UIGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state != UIGestureRecognizerStateRecognized) return;
	
	switch (method) {
		case 0: // Property animation.
			if (viewState == 0) { // First tap.
				[CATransaction setAnimationDuration:2];
				ball.position = p2;
			} else { // Second tap.
				ball.position = p1;
			}
			break;

		case 1: // Explicit animation with cancelation via delegate.
				// !!!: This one no longer works perfectly. It seems canceling the first animation in second one's -animationDidStop:finished: delegate method is too late — you can see a flash of first one before it is removed after the second one stops.
			if (viewState == 0) { // First tap.
				CABasicAnimation *drop = [CABasicAnimation animationWithKeyPath:@"position"];
				drop.removedOnCompletion = NO;
				drop.fillMode = kCAFillModeForwards;
				drop.duration = 2;
				drop.toValue = [NSValue valueWithCGPoint:p2];
				[ball addAnimation:drop forKey:@"drop"];
			} else { // Second tap.
				CABasicAnimation* bounce = [CABasicAnimation animationWithKeyPath:@"position"];
				[bounce setValue:@"bounce" forKey:@"tag"];
				bounce.delegate = self;
				bounce.toValue = [NSValue valueWithCGPoint:p1];
				[ball addAnimation:bounce forKey:@"bounce"];
			}
			break;
			
		case 2: // Explicit animation with overwriting.
			if (viewState == 0) { // First tap.
				CABasicAnimation *drop = [CABasicAnimation animationWithKeyPath:@"position"];
				drop.removedOnCompletion = NO;
				drop.fillMode = kCAFillModeForwards;
				drop.duration = 2;
				drop.toValue = [NSValue valueWithCGPoint:p2];
				[ball addAnimation:drop forKey:@"move"];
			} else { // Second tap.
				CGPoint startPoint = ((CALayer *)ball.presentationLayer).position;
				CABasicAnimation* bounce = [CABasicAnimation animationWithKeyPath:@"position"];
				bounce.fromValue = [NSValue valueWithCGPoint:startPoint];
				bounce.toValue = [NSValue valueWithCGPoint:p1];
				[ball addAnimation:bounce forKey:@"move"];
			}
			break;
			
			
		case 3: // Fall with property animation; rise with explicit animation.
			if (viewState == 0) { // First tap.
				[CATransaction setAnimationDuration:2];
				ball.position = p2;
			} else { // Second tap.
				CGPoint startPoint = ((CALayer *)ball.presentationLayer).position;
				CABasicAnimation* stop = [CABasicAnimation animationWithKeyPath:@"position"];
				stop.fromValue = [NSValue valueWithCGPoint:startPoint];
				stop.toValue = [NSValue valueWithCGPoint:p1];
				[ball addAnimation:stop forKey:@"position"];
				// We are doing explicit animation so don't let the implicit animation interfere.
				[CATransaction setDisableActions:YES];
				ball.position = p1;
				[CATransaction setDisableActions:NO];
			}
			break;
			
		case 4: // Fall with explicit animation; rise with property animation.
			if (viewState == 0) { // First tap.
				CGPoint startPoint = ball.position;
				CABasicAnimation *drop = [CABasicAnimation animationWithKeyPath:@"position"];
				drop.removedOnCompletion = NO;
				drop.fillMode = kCAFillModeForwards;
				drop.duration = 2;
				drop.fromValue = [NSValue valueWithCGPoint:startPoint];
				drop.toValue = [NSValue valueWithCGPoint:p2];
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
	label.text = [NSString stringWithFormat:@"Method %d", method + 1]; // Update label.
	viewState = !viewState; // Switch between states.
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	NSString *tag = [anim valueForKey:@"tag"];
	if ([tag isEqualToString:@"bounce"]) {
		[ball removeAnimationForKey:@"drop"];
	}
}


@end
