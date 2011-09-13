//
//  IntegralImage.h
//  OR_test1
//
//  Created by Ishai Jaffe on 9/4/11.
//  Copyright 2011 none. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define cR	0.2989
#define cG	0.5870
#define cB	0.1140

@interface IntegralImage : NSObject {
	float *rawImage;
	float **pixels;
	int width;
	int height;	
}

@property int width, height;

@property float **pixels;

@property float *rawImage;

-(float) getPixel:(int) row
				 :(int) col;

-(id) initWithSize:(int)width :(int) height;

-(id) initFromImage:(UIImage *)image;

-(id) initFromCGImage:(CGImageRef)image;

-(float) boxIntegral:(int) row:(int)col: (int)width:(int)height;

-(float) haarX:(int) row :(int) col :(int) size;

-(float) haarY:(int) row :(int) col :(int) size;



@end
