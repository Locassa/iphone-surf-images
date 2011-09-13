//
//  Layer.m
//  OR_test1
//
//  Created by Ishai Jaffe on 9/4/11.
//  Copyright 2011 none. All rights reserved.
//

#import "Layer.h"


@implementation Layer

@synthesize width, height, step, filter_size, responses, signs;

-(id) initWithParams:(int )m_width :(int )m_height :(int )m_step :(int )m_filter_size
{
	self = [super init];
	self.width = m_width;
	self.height = m_height;
	responses = (float *)calloc(m_width*m_height, sizeof(float));
	signs = (BOOL *)calloc(m_width*m_height, sizeof(BOOL));
	self.step = m_step;
	self.filter_size = m_filter_size;
	return self;
}

-(float) getResponse:(int )row :(int )col
{
	return responses[row * self.width + col];
}

-(void) setResponse:(int) row : (int) col : (float) value
{
	responses[row * width + col] = value;
}

-(float) getResponsePropToLayer:(int )row :(int )col :(Layer * )layer
{
	int scale = width / layer.width;
	return [self getResponse:row*scale:col*scale];
}

-(BOOL) getSign:(int )row :(int )col
{
	return signs[row * self.width + col];
}

-(void ) setSign: (int) row : (int) col : (BOOL) value
{
	signs[row * width + col] = value;
}

-(BOOL) getSignPropToLayer:(int )row :(int )col :(Layer * )layer
{
	int scale = width / layer.width;
	return [self getSign:row*scale:col*scale];
}

-(void) buildResponseLayer:(IntegralImage * )img
{
	int step = self.step;                      // step size for this filter
	int b = (self.filter_size - 1) / 2 + 1;         // border for this filter
	int l = self.filter_size / 3;                   // lobe for this filter (filter size / 3)
	int w = self.filter_size;                       // filter size
	float inverse_area = 1.0 / (w * w);       // normalisation factor
	float Dxx, Dyy, Dxy;
	
	for (int r, c, ar = 0, index = 0; ar < self.height; ++ar)
	{
        for (int ac = 0; ac < self.width; ++ac, index++)
        {
			// get the image coordinates
			r = ar * step;
			c = ac * step;
			
			// Compute response components
			Dxx = [img boxIntegral:r-l+1 :c-b :2*l-1 :w] - 3 * [img boxIntegral:r-l+1 :c-l/2 :2*l-1 :l];
			Dyy = [img boxIntegral:r - b :c- l + 1 :w: 2 * l - 1] - 3 * [img boxIntegral:r - l / 2: c - l + 1: l: 2 * l - 1];
			Dxy = [img boxIntegral:r - l:c + 1: l: l]+ [img boxIntegral:r + 1: c - l: l: l]
			- [img boxIntegral:r - l: c - l: l:l] - [img boxIntegral:r + 1: c + 1: l: l];
			
			// Normalise the filter responses with respect to their size
			Dxx *= inverse_area;
			Dyy *= inverse_area;
			Dxy *= inverse_area;
			
			// Get the determinant of hessian response & laplacian sign
			[self setResponse: ar : ac :(float) (Dxx * Dyy - 0.81 * Dxy * Dxy)];
			[self setSign: ar: ac : (Dxx + Dyy >= 0 ? YES : NO)];
//			self.responses[index] =(float) (Dxx * Dyy - 0.81 * Dxy * Dxy);
//			self.signs[index] = (Dxx + Dyy >= 0 ? YES : NO);
        }
	}
}

-(void) dealloc
{
	free(responses);
	free(signs);
	[super dealloc];
}
@end
