//
//  UIImageResizing.m
//  pictak
//
//  Created by Ishai Jaffe on 6/4/10.
//  Copyright 2010 none. All rights reserved.
//

#import "UIImageResizing.h"
#define MAX_SIZE	200.0

// Put this in UIImageResizing.m
@implementation UIImage (Resizing)

static CGRect swapWidthAndHeight(CGRect rect)
{
    CGFloat  swap = rect.size.width;
    
    rect.size.width  = rect.size.height;
    rect.size.height = swap;
    
    return rect;
}


-(UIImage*)rotate_scaleTo : (int) bound
{
    CGRect             bnds = CGRectZero;
    UIImage*           copy = nil;
    CGContextRef       ctxt = nil;
    CGImageRef         imag = self.CGImage;
    CGRect             rect = CGRectZero;
    CGAffineTransform  tran = CGAffineTransformIdentity;
	UIImageOrientation orient = self.imageOrientation;
    rect.size.width  = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
	float prop = rect.size.width / rect.size.height;
	if (prop > 1) {
		if (rect.size.width > bound)
		{
			rect.size.width = bound;
			rect.size.height = bound / prop;
		}
	}
	else {
		if (rect.size.height > bound)
		{
			rect.size.width = bound * prop;
			rect.size.height = bound;
		}
		
	}
	
    bnds = rect;
    
    switch (orient)
    {
        case UIImageOrientationUp:
			// would get you an exact copy of the original
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
			tran = CGAffineTransformScale(tran, 1.0, -1.0);
			break;
			
        case UIImageOrientationUpMirrored:
			tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			break;
			
        case UIImageOrientationDown:
			tran = CGAffineTransformMakeTranslation(rect.size.width,
													rect.size.height);
			tran = CGAffineTransformRotate(tran, M_PI);
			break;
			
        case UIImageOrientationDownMirrored:
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
			tran = CGAffineTransformScale(tran, 1.0, -1.0);
			break;
			
        case UIImageOrientationLeft:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
			tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
			break;
			
        case UIImageOrientationLeftMirrored:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(rect.size.height,
													rect.size.width);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
			break;
			
        case UIImageOrientationRight:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
			tran = CGAffineTransformRotate(tran, M_PI / 2.0);
			break;
			
        case UIImageOrientationRightMirrored:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeScale(-1.0, 1.0);
			tran = CGAffineTransformRotate(tran, M_PI / 2.0);
			break;
			
        default:
			// orientation value supplied is invalid
			assert(false);
			return nil;
    }
	
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
	
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
			CGContextScaleCTM(ctxt, -1.0, 1.0);
			CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
			break;
			
        case UIImageOrientationUp:
			break;
       default:
			CGContextScaleCTM(ctxt, 1.0, -1.0);
			CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
			break;
    }
	
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return copy;
}

+(CGImageRef) down_scale : (CGImageRef) imag : (int) bound
{
    CGRect             bnds = CGRectZero;
    CGContextRef       ctxt = nil;
    CGRect             rect = CGRectZero;
    CGAffineTransform  tran = CGAffineTransformIdentity;
	UIImage *		copy;
//	UIImageOrientation orient = self.imageOrientation;
    rect.size.width  = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
	float prop = rect.size.width / rect.size.height;
	if (prop > 1) {
		if (rect.size.width > bound)
		{
			rect.size.width = bound;
			rect.size.height = bound / prop;
		}
	}
	else {
		if (rect.size.height > bound)
		{
			rect.size.width = bound * prop;
			rect.size.height = bound;
		}
		
	}
	
    bnds = rect;
    
	tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
	tran = CGAffineTransformScale(tran, 1.0, -1.0);
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
	
	
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return copy.CGImage;
}

@end