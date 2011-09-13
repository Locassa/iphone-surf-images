//
//  Descriptor.m
//  OR_test1
//
//  Created by Ishai Jaffe on 9/6/11.
//  Copyright 2011 none. All rights reserved.
//

#import "Descriptor.h"
#include <math.h>

@interface Descriptor(hidden)

-(void) getOrientation:(Feature *)ft;

-(void) getDescriptor:(Feature *)ft;

double getAngle(float X, float Y);

float gaussian(double x, double y, float sig);

float GAUSSMAT(int row, int col);

@end



@implementation Descriptor

@synthesize img;

-(id) init
{
	self = [super init];
	return self;
}

float GAUSSMAT(int row, int col)
{
	float _GAUSSMAT[7][7] = {
		{0.02350693969273f,0.01849121369071f,0.01239503121241f,0.00708015417522f,0.00344628101733f,0.00142945847484f,0.00050524879060f},
		{0.02169964028389f,0.01706954162243f,0.01144205592615f,0.00653580605408f,0.00318131834134f,0.00131955648461f,0.00046640341759f},
		{0.01706954162243f,0.01342737701584f,0.00900063997939f,0.00514124713667f,0.00250251364222f,0.00103799989504f,0.00036688592278f},
		{0.01144205592615f,0.00900063997939f,0.00603330940534f,0.00344628101733f,0.00167748505986f,0.00069579213743f,0.00024593098864f},
		{0.00653580605408f,0.00514124713667f,0.00344628101733f,0.00196854695367f,0.00095819467066f,0.00039744277546f,0.00014047800980f},
		{0.00318131834134f,0.00250251364222f,0.00167748505986f,0.00095819467066f,0.00046640341759f,0.00019345616757f,0.00006837798818f},
		{0.00131955648461f,0.00103799989504f,0.00069579213743f,0.00039744277546f,0.00019345616757f,0.00008024231247f,0.00002836202103f}
    };
	return _GAUSSMAT[row][col];
}

double getAngle(float X, float Y)
{
	return atan2f(X, Y);
}

float gaussian(double x, double y, float sig)
{
	float pi = (float)M_PI;
	return 1.0 / (2.0 * pi * sig * sig) * (float)exp(-(x * x + y * y) / (2.0 * sig * sig));
}

-(void) getDescriptor:(Feature * )ft
{
	int sample_x, sample_y, count = 0;
	int i = 0, ix = 0, j = 0, jx = 0, xs = 0, ys = 0;
	float dx, dy, mdx, mdy, co, si;
	float dx_yn, mdx_yn, dy_xn, mdy_xn;
	float gauss_s1 = 0.0, gauss_s2 = 0.0;
	float rx = 0.0, ry = 0.0, rrx = 0.0, rry = 0.0, len = 0.0;
	float cx = -0.5, cy = 0.0; //Subregion centers for the 4x4 gaussian weighting
	
	// Get rounded InterestPoint data
	int X = (int)round(ft.x);
	int Y = (int)round(ft.y);
	int S = (int)round(ft.scale);
	
    co = (float) cosf(ft.orientation);
    si = (float)sinf(ft.orientation);
	
	//Calculate descriptor for this interest point
	i = -8;
	while (i < 12)
	{
        j = -8;
        i = i - 4;
		
        cx += 1.0;
        cy = -0.5;
		
        while (j < 12)
        {
			cy += 1.0;
			
			j = j - 4;
			
			ix = i + 5;
			jx = j + 5;
			
			dx = dy = mdx = mdy = 0.0;
			dx_yn = mdx_yn = dy_xn = mdy_xn = 0.0;
			
			xs = (int)round(X + (-jx * S * si + ix * S * co));
			ys = (int)round(Y + (jx * S * co + ix * S * si));
			
			// zero the responses
			dx = dy = mdx = mdy = 0.0;
			dx_yn = mdx_yn = dy_xn = mdy_xn = 0.0;
			
			for (int k = i; k < i + 9; ++k)
			{
				for (int l = j; l < j + 9; ++l)
				{
					//Get coords of sample point on the rotated axis
					sample_x = (int)round(X + (-l * S * si + k * S * co));
					sample_y = (int)round(Y + (l * S * co + k * S * si));
					
					//Get the gaussian weighted x and y responses
					gauss_s1 = gaussian(xs - sample_x, ys - sample_y, 2.5 * S);
					rx = (float)[img haarX:sample_y: sample_x: 2 * S];
					ry = (float)[img haarY:sample_y: sample_x: 2 * S ];
					
					//Get the gaussian weighted x and y responses on rotated axis
					rrx = gauss_s1 * (-rx * si + ry * co);
					rry = gauss_s1 * (rx * co + ry * si);
					
					
					dx += rrx;
					dy += rry;
					mdx += fabsf(rrx);
					mdy += fabsf(rry);
				}
			}
			
			//Add the values to the descriptor vector
			gauss_s2 = gaussian(cx - 2.0, cy - 2.0, 1.5);
			
			ft.descriptors[count++] = dx * gauss_s2;
			ft.descriptors[count++] = dy * gauss_s2;
			ft.descriptors[count++] = mdx * gauss_s2;
			ft.descriptors[count++] = mdy * gauss_s2;
			
			
			len += (dx * dx + dy * dy + mdx * mdx + mdy * mdy
					+ dx_yn + dy_xn + mdx_yn + mdy_xn) * gauss_s2 * gauss_s2;
			
			j += 9;
        }
        i += 9;
	}
	
	//Convert to Unit Vector
	len = sqrtf(len);
	if (len > 0.0)
	{
        for (int d = 0; d < 64; ++d)
        {
			ft.descriptors[d] /= len;
        }
	}
}

-(void) getOrientation:(Feature * )ft
{
	float resX[RESPONSES_COUNT] = { 0.0 };
	float resY[RESPONSES_COUNT] = { 0.0 };
	float Ang[RESPONSES_COUNT] = {0.0 };
	int idx = 0;
	int idtf[13] = { 6, 5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5, 6 };
	
	// Get rounded InterestPoint data
		
	int X = (int)round(ft.x);
	int Y = (int)round(ft.y);
	int S = (int)round(ft.scale);
	
	// calculate haar responses for points within radius of 6*scale
	for (int i = -6; i <= 6; ++i)
	{
        for (int j = -6; j <= 6; ++j)
        {
			if (i * i + j * j < 36)
			{
				float gauss = GAUSSMAT(idtf[i + 6],idtf[j + 6]);
				resX[idx] = gauss * [img haarX:Y+j*S :X+i*5 :4*S];
				resY[idx] = gauss * [img haarY:Y + j * S: X + i * S: 4 * S];
				Ang[idx] = (float)getAngle(resX[idx], resY[idx]);
				++idx;
			}
        }
	}
	
	// calculate the dominant direction 
	float sumX, sumY, max = 0, orientation = 0;
	float ang1, ang2;
	float pi = (float)M_PI;
	
	// loop slides pi/3 window around feature point
	for (ang1 = 0; ang1 < 2 * pi; ang1 += 0.15)
	{
        ang2 = (ang1 + pi / 3.0 > 2 * pi ? ang1 - 5 * pi / 3.0 : ang1 + pi / 3.0);
        sumX = sumY = 0;
		
        for (int k = 0; k < RESPONSES_COUNT; ++k)
        {
			// determine whether the point is within the window
			if (ang1 < ang2 && ang1 < Ang[k] && Ang[k] < ang2)
			{
				sumX += resX[k];
				sumY += resY[k];
			}
			else if (ang2 < ang1 &&
					 ((Ang[k] > 0 && Ang[k] < ang2) || (Ang[k] > ang1 && Ang[k] < pi)))
			{
				sumX += resX[k];
				sumY += resY[k];
			}
        }
		
        // if the vector produced from this window is longer than all 
        // previous vectors then this forms the new dominant direction
        if (sumX * sumX + sumY * sumY > max)
        {
			// store largest orientation
			max = sumX * sumX + sumY * sumY;
			orientation = (float)getAngle(sumX, sumY);
        }
	}
	
	// assign orientation of the dominant response vector
	ft.orientation = (float)orientation;
	
}

-(void) describeInterestPoints:(NSArray * )features :(IntegralImage * )_img
{
	self.img = _img;
	for (int i=0; i<features.count; i++)
	{
		Feature *ft = [features objectAtIndex:i];
				
        [self getOrientation:ft];
		
		[self getDescriptor:ft];
	}
}


-(void) dealloc
{
	[img release];
	[super dealloc];
}

@end
