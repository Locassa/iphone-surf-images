//
//  Layer.h
//  OR_test1
//
//  Created by Ishai Jaffe on 9/4/11.
//  Copyright 2011 none. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IntegralImage.h"

@interface Layer : NSObject {
	
	int step,filter_size;
	int width,height;
	
	float *responses;
	BOOL *signs;
}

@property int step,filter_size, width, height;

@property float *responses;

@property BOOL *signs;

-(id) initWithParams : (int) m_width: (int) m_height : (int) m_step : (int) m_filter_size;

-(float) getResponse : (int) row : (int) col;

-(void) setResponse :(int) row : (int) col : (float) value;

-(void) setSign: (int) row : (int) col : (BOOL) value;

-(BOOL) getSign : (int) row : (int) col;

-(float) getResponsePropToLayer:(int) row : (int) col : (Layer *) layer;

-(BOOL) getSignPropToLayer:(int) row : (int) col : (Layer *) layer;

-(void) buildResponseLayer : (IntegralImage *) image;

@end
