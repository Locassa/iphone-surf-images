//
//  Feature.h
//  OR_test1
//
//  Created by Ishai Jaffe on 9/4/11.
//  Copyright 2011 none. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Feature : NSObject {
	float x,y,scale,response,orientation,sign;
	
	float *descriptors;
	
}

@property float x,y,scale,response,orientation,sign;

@property float *descriptors;

-(float) compareToFeature:(Feature *)ft;

@end
	
