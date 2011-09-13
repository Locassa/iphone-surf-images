//
//  OR_test1ViewController.h
//  OR_test1
//
//  Created by Ishai Jaffe on 9/11/10.
//  Copyright none 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlayView.h"
#import "TestView.h"
#import "IntegralImage.h"

@interface OR_test1ViewController : UIViewController <UIImagePickerControllerDelegate> {
	NSTimer *processingTimer;
	OverlayView *overlayView;
	TestView *testImage;
	TestView *testImage2;
	NSMutableArray *perv_features;
	UIImagePickerController *picker;
	IntegralImage *image1;
	IntegralImage *image2;
	UILabel *performace_label;
}

-(IBAction) runAugmentedReality;

-(IBAction) runTest;

-(IBAction) runTest_from_camera;

@property (nonatomic,retain) IBOutlet TestView *testImage, *testImage2;

@property (nonatomic,retain) IBOutlet UILabel *performace_label;

@end

