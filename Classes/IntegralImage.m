//
//  IntegralImage.m
//  OR_test1
//
//  Created by Ishai Jaffe on 9/4/11.
//  Copyright 2011 none. All rights reserved.
//

#import "IntegralImage.h"
#import <math.h>

@implementation IntegralImage

@synthesize width, height, pixels, rawImage;

-(float) getPixel:(int )row :(int )col
{
	return self.pixels[row][col];
}

-(id) initWithSize:(int)_width :(int) _height
{
	self = [super init];
	self.width = _width;
	self.height = _height;
	rawImage=(float *) calloc(_width*_height, sizeof(float));
	// create a 2D aray - this makes using the data a lot easier
	self.pixels=(float **) malloc(sizeof(float *)*_height);
	for(int y=0; y<_height; y++) {
		pixels[y]=rawImage+y*_width;
	}
	
	return self;
}

-(id) initFromCGImage:(CGImageRef)imageRef
{
	NSUInteger _width = CGImageGetWidth(imageRef);
	NSUInteger _height = CGImageGetHeight(imageRef);
	self = [self initWithSize:_width :_height];
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	unsigned char *rawData = malloc(_height * _width * 4);
	NSUInteger bytesPerPixel = 4;
	NSUInteger bytesPerRow = bytesPerPixel * _width;
	NSUInteger bitsPerComponent = 8;
	CGContextRef context = CGBitmapContextCreate(rawData, _width, _height,
												 bitsPerComponent, bytesPerRow, colorSpace,
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	
	CGContextDrawImage(context, CGRectMake(0, 0, _width, _height), imageRef);
	CGContextRelease(context);
	
	float rowsum = 0;
	int byteIndex = 0;
	CGFloat red, green,blue,alpha;
	for (int x = 0; x < _width-10; x++)
	{
		byteIndex = x * bytesPerPixel;
		red   = (rawData[byteIndex]     * 1.0);
		green = (rawData[byteIndex + 1] * 1.0);
		blue  = (rawData[byteIndex + 2] * 1.0);
        rowsum += ((cR * red + cG * green + cB * blue) / 255.0);
        pixels[0][x] = rowsum;
	}
	
	
	for (int y = 1; y < _height-40; y++)
	{
        rowsum = 0;
        for (int x = 0; x < _width-10; x++)
        {
			byteIndex =(y * bytesPerRow) + x * bytesPerPixel;
			red   = (rawData[byteIndex]     * 1.0);
			green = (rawData[byteIndex + 1] * 1.0);
			blue  = (rawData[byteIndex + 2] * 1.0);
			rowsum += (cR * red + cG * green + cB * blue) / 255.0;
			
			// integral image is rowsum + value above        
			pixels[y][x] = rowsum + self.pixels[y - 1][x];
        }
	}
	self.height -= 40;
	self.width -= 10;
	
	free(rawData);
	
	return self;
	
}

-(id) initFromImage:(UIImage * )image
{
	CGImageRef imageRef = [image CGImage];
	self = [self initFromCGImage:imageRef];
	return self;
}

-(float) boxIntegral:(int )row :(int )col :(int )_width :(int )_height
{
	// The subtraction by one for row/col is because row/col is inclusive.
		int r1 = fmin(row, self.height) - 1;
		int c1 = fmin(col, self.width) - 1;
		int r2 = fmin(row + _height, self.height) - 1;
		int c2 = fmin(col + _width, self.width) - 1;
		
		float A = 0, B = 0, C = 0, D = 0;
		if (r1 >= 0 && c1 >= 0) A = pixels[r1][c1];
		if (r1 >= 0 && c2 >= 0) B = pixels[r1][c2];
		if (r2 >= 0 && c1 >= 0) C = pixels[r2][c1];
		if (r2 >= 0 && c2 >= 0) D = pixels[r2][c2];
		
		return fmax(0.0, A - B - C + D);
 
	return 0.0;
}

-(float) haarX:(int) row :(int) col :(int) size
{
	return [self boxIntegral:row-size/2 :col : size :size / 2] 
	- [self boxIntegral:row - size/2: col - size / 2 : size:size / 2];
}

-(float) haarY:(int) row :(int) col :(int) size
{
	return [self boxIntegral:row :col-size/2 : size/2 :size] 
	- [self boxIntegral:row-size/2: col-size/2 : size/2:size];
}

-(void) dealloc
{
	free(rawImage);
	free(pixels);
	[super dealloc];
}

@end
