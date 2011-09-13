//
//  HassienDetector.m
//  OR_test1
//
//  Created by Ishai Jaffe on 9/4/11.
//  Copyright 2011 none. All rights reserved.
//

#import "HassienDetector.h"
#import <math.h>

@interface HassienDetector(hidden)

-(void) buildResponseMap: (NSMutableArray *) array : (IntegralImage *) image;

-(BOOL) isExtremum: (int) row: (int)col : (Layer *) top: (Layer *)current : (Layer *)bottom;

-(Feature *) InterpolateExtremum:(int) row: (int)col : (Layer *) top: (Layer *)current : (Layer *)bottom;

-(void) addLayerWithParams : (int) width:(int)height:(int) step : (int)filter_size : (NSMutableArray *) array;

-(void) buildDerivatives:(int) row : (int) col : (Layer *)top : (Layer *) current : (Layer *)bottom : (double *) buffer;

-(void) buildHassien:(int) row : (int) col : (Layer *)top : (Layer *) current : (Layer *)bottom : (double *) buffer;



@end


@implementation HassienDetector

@synthesize thresh, octaves, init_sample;


-(id) initWithParams : (float) _thresh:(int) _octaves : (int) _init_sample 
{
	self = [super init];
	thresh = _thresh;
	octaves = _octaves;
	init_sample = _init_sample;
	return self;
}

-(void) buildDerivatives:(int )row :(int )col :(Layer * )top :(Layer * )current :(Layer * )bottom :(double * )buffer
{
	double dx, dy, ds;
	
	dx = ([current getResponsePropToLayer:row :col+1 :top] - [current getResponsePropToLayer:row :col-1 :top])/2.0;
	dy = ([current getResponsePropToLayer:row+1 :col :top] - [current getResponsePropToLayer:row-1 :col :top])/2.0;
	ds = ([top getResponse:row :col] - [bottom getResponsePropToLayer:row :col :top])/2.0;
	
	buffer[0] = dx;
	buffer[1] = dy;
	buffer[2] = ds;
}

-(void) buildHassien:(int )row :(int )col :(Layer * )top :(Layer * )current :(Layer * )bottom :(double * )buffer
{
	double v, dxx, dyy, dss, dxy, dxs, dys;
	
	v = [current getResponsePropToLayer:row :col :top];
	dxx = [current getResponsePropToLayer:row :col+1 :top] + [current getResponsePropToLayer:row :col-1 :top] - 2*v;
	dyy = [current getResponsePropToLayer:row+1 :col :top] + [current getResponsePropToLayer:row-1 :col :top] - 2*v;
	dss = [top getResponse:row :col] + [bottom getResponsePropToLayer:row :col :top] - 2 *v;
	dxy = ([current getResponsePropToLayer:row+1 :col+1 :top] - [current getResponsePropToLayer:row+1 :col-1 :top] -
		   [current getResponsePropToLayer:row-1 :col+1 :top] + [current getResponsePropToLayer:row-1 :col-1 :top])/4.0;
	dxs = ([top getResponse:row:col+1] - [top getResponse:row :col-1] - [bottom getResponsePropToLayer:row :col+1:top]
		   + [bottom getResponsePropToLayer:row :col-1 :top])/4.0;
	dys = ([top getResponse:row+1 :col] - [top getResponse:row-1 :col] - 
		   [bottom getResponsePropToLayer:row+1 :col :top] + [bottom getResponsePropToLayer:row-1 :col :top])/4.0;
	
	buffer[0] = dxx; buffer[3] = dxy; buffer[6] = dxs;
	buffer[1] = dxy; buffer[4] = dyy; buffer[7] = dys;
	buffer[2] = dxs; buffer[5] = dys; buffer[8] = dss;
	
}

-(Feature *) InterpolateExtremum:(int )row :(int )col :(Layer * )top :(Layer * )current :(Layer * )bottom
{
	double *deriv = (double *)calloc(3,sizeof(double));
	double *hassien = (double *)calloc(9, sizeof(double));
	[self buildDerivatives:row :col :top :current :bottom :deriv];
	[self buildDerivatives:row :col :top :current :bottom :hassien];
	
	int NDIM = 3, N = NDIM, NRHS = 1, LDA = NDIM,LDB = NDIM;
	int IPIV[NDIM], INFO;
//	dgesv_(&N, &NRHS, hassien, &LDA, IPIV, deriv, &LDB, &INFO);
	
	double O[3] = { deriv[0] * -1, deriv[1] * -1 , deriv[2] * -1 };
	free(deriv);
	free(hassien);
		
		// get the step distance between filters
		int filterStep = (current.filter_size - bottom.filter_size);
		
		// If point is sufficiently close to the actual extremum
		if (fabs(O[0]) < 0.5 && fabs(O[1]) < 0.5 && fabs(O[2]) < 0.5)
		{
			Feature *ft = [Feature new];
			ft.x = (float)((col + O[0]) * top.step);
			ft.y = (float)((row + O[1]) * top.step);
			ft.scale = (float)((0.1333) * (current.filter_size + O[2] * filterStep));
			ft.sign = [current getSignPropToLayer:row :col :top];
//			[features addObject:ft];
			return ft;
		}
	return nil;
}

-(BOOL) isExtremum:(int )row :(int )col :(Layer * )top :(Layer * )current :(Layer * )bottom
{
		// bounds check
		int layerBorder = (top.filter_size + 1) / (2 * top.step);
		if (row <= layerBorder || row >= top.height - layerBorder || col <= layerBorder || col >= top.width - layerBorder)
			return FALSE;
		
		// check the candidate point in the middle layer is above thresh 
		float candidate = [current getResponsePropToLayer:row :col :top];
		if (candidate < thresh)
			return FALSE;
		
		for (int rr = -1; rr <= 1; ++rr)
		{
			for (int cc = -1; cc <= 1; ++cc)
			{
				// if any response in 3x3x3 is greater candidate not maximum
				if ([top getResponse:row+rr :col+cc] >= candidate ||
					((rr != 0 || cc != 0) && [current getResponsePropToLayer:row+rr :col+cc :top] >= candidate) ||
					[bottom getResponsePropToLayer:row+rr :col+cc :top ] >= candidate)
				{
					return FALSE;
				}
			}
		}
		
		return TRUE;
}

-(void) buildResponseMap : (NSMutableArray *)array : (IntegralImage *) img
{
	// Calculate responses for the first 4 octaves:
	// Oct1: 9,  15, 21, 27
	// Oct2: 15, 27, 39, 51
	// Oct3: 27, 51, 75, 99
	// Oct4: 51, 99, 147,195
	// Oct5: 99, 195,291,387
	
	// Get image attributes
	int w = (img.width / init_sample);
	int h = (img.height / init_sample);
	int s = (init_sample);
	
	// Calculate approximated determinant of hessian values
	if (octaves >= 1)
	{
		[self addLayerWithParams:w :h :s :9: array];
		[self addLayerWithParams:w :h :s :15: array];
		[self addLayerWithParams:w :h :s :21: array];
		[self addLayerWithParams:w :h :s :27: array];
	}
	
	if (octaves >= 2)
	{
		[self addLayerWithParams:w/2 :h/2 :s*2 :39: array];
		[self addLayerWithParams:w/2 :h/2 :s*2 :51: array];
	}
	
	if (octaves >= 3)
	{
		[self addLayerWithParams:w/4 :h/4 :s*4 :75: array];
		[self addLayerWithParams:w/4 :h/4 :s*4 :99: array];
	}
	
	if (octaves >= 4)
	{
		[self addLayerWithParams:w/8 :h/8 :s*8 :147: array];
		[self addLayerWithParams:w/8 :h/8 :s*8 :195: array];
	}
	
	if (octaves >= 5)
	{
		[self addLayerWithParams:w/16 :h/16 :s*16 :291: array];
		[self addLayerWithParams:w/16 :h/16 :s*16 :387: array];
	}
	
	// Extract responses from the image
	for (int i = 0; i < array.count; ++i)
	{
		Layer *ly = [array objectAtIndex:i];
		[ly buildResponseLayer:img];
	}
}

-(void) addLayerWithParams:(int )width :(int )height :(int )step :(int )filter_size : (NSMutableArray *) array
{
	Layer *ly = [[Layer alloc] initWithParams:width :height :step :filter_size];
	[array addObject:ly];
	[ly release];
}

-(NSMutableArray *) detectFeatures:(IntegralImage * )image : (NSMutableArray *) array
{
	NSMutableArray *layerMap = [NSMutableArray new];
	int filter_map[5][4] = {{0,1,2,3}, {1,3,4,5}, {3,5,6,7}, {5,7,8,9}, {7,9,10,11}};
	// Build the response map
	[self buildResponseMap: layerMap : image];
	
	// Get the response layers
	Layer *b, *m, *t;
	for (int o = 0; o < octaves; ++o)
	{
		for (int i = 0; i <= 1; ++i)
		{
			b = [layerMap objectAtIndex:filter_map[o][i]];
			m = [layerMap objectAtIndex:filter_map[o][i+1]];
			t = [layerMap objectAtIndex:filter_map[o][i+2]];
		
			// loop over middle response layer at density of the most 
			// sparse layer (always top), to find maxima across scale and space
			for (int r = 0; r < t.height; ++r)
			{
				for (int c = 0; c < t.width; ++c)
				{
					if ([self isExtremum:r:c :t :m :b])
					{
						Feature *ft = [self InterpolateExtremum:r :c :t :m :b];
						if( ft != nil)
						{
							[array addObject:ft];
							[ft release];
						}
					}
				}
			}
		}
	}
	[layerMap release];
}

-(void) dealloc
{
	[super dealloc];
}

@end
