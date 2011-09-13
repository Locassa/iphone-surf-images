//
//  Descriptor.h
//  OR_test1
//
//  Created by Ishai Jaffe on 9/6/11.
//  Copyright 2011 none. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IntegralImage.h"
#import "Feature.h"
#import "Layer.h"

#define RESPONSES_COUNT	109

@interface Descriptor : NSObject {
	IntegralImage *img;
}

@property (nonatomic,retain) IntegralImage *img;

-(void) describeInterestPoints:(NSArray *)features
							  :(IntegralImage *)img;

@end
