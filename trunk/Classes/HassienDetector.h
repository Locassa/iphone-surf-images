//
//  HassienDetector.h
//  OR_test1
//
//  Created by Ishai Jaffe on 9/4/11.
//  Copyright 2011 none. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IntegralImage.h"
#import "Layer.h"
#import "Feature.h"

@interface HassienDetector : NSObject {
	float thresh;
    int octaves;
    int init_sample;
}

@property float thresh;

@property int octaves, init_sample;

-(NSMutableArray *) detectFeatures : (IntegralImage *)image : (NSMutableArray *)array;

-(id) initWithParams : (float) _thresh:(int) _octaves : (int) _init_sample;



@end
