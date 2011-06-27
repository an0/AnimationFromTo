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
	switch (method) {
		case 0: // Property animation.
			if(viewState == 0) { // First tap.
				[CATransaction setAnimationDuration:2];
				ball.position = p2;
			}  else { // Second tap.
				ball.position = p1;
			}
			break;
			
		case 1: // Explicit animation with cancelation via delegate.
			if(viewState == 0) { // First tap.
				CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
				move.removedOnCompletion = NO;
				move.fillMode = kCAFillModeForwards;
				move.duration = 2;
				move.toValue = [NSValue valueWithCGPoint:p2];
				[ball addAnimation:move forKey:@"move"];
			}  else { // Second tap.
				CABasicAnimation* stop = [CABasicAnimation animationWithKeyPath:@"position"];
				[stop setValue:@"stop" forKey:@"tag"];
				stop.delegate = self;
				stop.toValue = [NSValue valueWithCGPoint:p1];
				[ball addAnimation:stop forKey:@"stop"];
			}
			break;
			
		case 2: // Explicit animation with overwriting.
			if(viewState == 0) { // First tap.
				CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
				move.removedOnCompletion = NO;
				move.fillMode = kCAFillModeForwards;
				move.duration = 2;
				move.toValue = [NSValue valueWithCGPoint:p2];
				[ball addAnimation:move forKey:@"position"];
			}  else { // Second tap.
				CGPoint startPoint = ((CALayer *)ball.presentationLayer).position;
				CABasicAnimation* stop = [CABasicAnimation animationWithKeyPath:@"position"];
				stop.fromValue = [NSValue valueWithCGPoint:startPoint];
				stop.toValue = [NSValue valueWithCGPoint:p1];
				[ball addAnimation:stop forKey:@"position"];
			}
			break;
			
			
		case 3: // Fall with property animation; rise with explicit animation.
			if(viewState == 0) { // First tap.
				[CATransaction setAnimationDuration:2];
				ball.position = p2;
			}  else { // Second tap.
				CGPoint startPoint = ((CALayer *)ball.presentationLayer).position;
				ball.position = p1;
				CABasicAnimation* stop = [CABasicAnimation animationWithKeyPath:@"position"];
				stop.fromValue = [NSValue valueWithCGPoint:startPoint];
				stop.toValue = [NSValue valueWithCGPoint:p1];
				[ball addAnimation:stop forKey:@"position"];
			}
			break;
			
		case 4: // Fall with explicit animation; rise with property animation.
			if(viewState == 0) { // First tap.
				CGPoint startPoint = ball.position;
				ball.position = p2;
				CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
				move.removedOnCompletion = NO;
				move.fillMode = kCAFillModeForwards;
				move.duration = 2;
				move.fromValue = [NSValue valueWithCGPoint:startPoint];
				move.toValue = [NSValue valueWithCGPoint:p2];
				[ball addAnimation:move forKey:@"position"];
			}  else { // Second tap.
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
	if ([tag isEqualToString:@"stop"]) {
		[ball removeAnimationForKey:@"move"];
	}
}


@end
