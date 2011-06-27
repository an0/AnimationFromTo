//
//  AnimationFromToViewController.h
//  AnimationFromTo
//
//  Created by Ling Wang on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnimationFromToViewController : UIViewController {
@private
	CALayer *ball;
	NSUInteger viewState;
	NSUInteger method;
	UILabel *label;
}
@end
