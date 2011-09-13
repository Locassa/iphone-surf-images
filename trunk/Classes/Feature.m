//
//  Feature.m
//  OR_test1
//
//  Created by Ishai Jaffe on 9/4/11.
//  Copyright 2011 none. All rights reserved.
//

#import "Feature.h"
#import <math.h>

@implementation Feature

@synthesize x,y,scale,response,orientation,sign, descriptors;

-(id) init
{
	self = [super init];
	descriptors = calloc(64, sizeof(float));
	return self;
}

-(float) compareToFeature:(Feature * )ft
{
	float score = 0.0;
	if (self.sign != ft.sign) {
		score += 10.0;
	}
	for (int i=0; i<64; i++) {
		score += fabsf(descriptors[i] - ft.descriptors[i]);
	}
	return score;
}

-(void) dealloc
{
	free(descriptors);
	[super dealloc];
}

@end
