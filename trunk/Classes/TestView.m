//
//  TestView.m
//  OR_test1
//
//  Created by Ishai Jaffe on 9/6/11.
//  Copyright 2011 none. All rights reserved.
//

#import "TestView.h"
#import "Feature.h"
#import <math.h>

@implementation TestView

@synthesize image, features, image_frame;

- (void)drawRect:(CGRect)rect {
//	[super drawRect:rect];
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	CGFloat red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
	CGFloat green[4] = { 0.0f, 0.0f, 0.0f, 1.0f };
	CGContextSetStrokeColor(c, red);
	CGContextSetFillColor(c, red);
	double ratio_x = 0.0, ratio_y = 0.0;
	if (image != nil)
	{	
		ratio_x = self.frame.size.width * 1.0 / (image.size.width);
		ratio_y = self.frame.size.height * 1.0 / (image.size.height);
		[image drawInRect:rect];
//		CGContextDrawImage(c,rect,[image CGImage]);
	}
	if (features != nil) {
		for (int i=0; i<features.count; i++) {
			Feature *ft = [features objectAtIndex:i];
			int S = 2 * (int) roundf(1.0f * ft.scale);
			int R = (int) (S / 2.0f);
			
			int x = (int) roundf(ft.x);
			int y = (int)roundf(ft.y);
			
			float co = (float) cosf(ft.orientation);
			float si = (float) sinf(ft.orientation);
			CGContextSetFillColor(c, red);
			CGContextFillEllipseInRect(c, CGRectMake((x - R)*ratio_x, (y - R)*ratio_y, S*ratio_x, S*ratio_y));
//			CGContextSetFillColor(c, green);
			CGContextSetStrokeColor(c, green);
			CGContextSetLineWidth(c, 1);
			CGContextBeginPath(c);
			CGContextMoveToPoint(c, (x-co*R/3)*ratio_x, (y-si*R/3)*ratio_y);
			CGContextAddLineToPoint(c, (x+co*R*2)*ratio_x, (y + si*R*2)*ratio_y);
			CGContextStrokePath(c);
			
		}
	}
}

-(void) dealloc
{
	[features release];
	[image release];
	[super dealloc];
}

@end
