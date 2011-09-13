//
//  UIImageResizing.h
//  pictak
//
//  Created by Ishai Jaffe on 6/4/10.
//  Copyright 2010 none. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (Resize)

- (UIImage*)rotate_scaleTo:(int) bound;

+(CGImageRef) down_scale : (CGImageRef) imag : (int) bound;

@end