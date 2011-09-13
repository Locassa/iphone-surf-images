//
//  TestView.h
//  OR_test1
//
//  Created by Ishai Jaffe on 9/6/11.
//  Copyright 2011 none. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TestView : UIView {
	UIImage *image;
	NSArray *features;
	CGSize image_frame;
}

@property (nonatomic,retain) UIImage *image;

@property (nonatomic,retain) NSArray *features;

@property CGSize image_frame;

-(void) drawOval;


@end
