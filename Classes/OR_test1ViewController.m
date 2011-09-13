//
//  OR_test1ViewController.m
//  OR_test1
//
//  Created by Ishai Jaffe on 9/11/10.
//  Copyright none 2010. All rights reserved.
//

#import "OR_test1ViewController.h"
#import "IntegralImage.h"
#import "Feature.h"
#import "HassienDetector.h"
#import "Descriptor.h"
#import <CoreGraphics/CoreGraphics.h>
#import "UIImageResizing.h"

@implementation OR_test1ViewController

@synthesize testImage, testImage2, performace_label;

-(IBAction) runTest
{
	return [self runTestWithType:UIImagePickerControllerSourceTypePhotoLibrary];
}
-(IBAction) runTest_from_camera
{
	return [self runTestWithType:UIImagePickerControllerSourceTypeCamera];
}

-(IBAction) runTestWithType : (UIImagePickerControllerSourceType) sourceType
{
	if(picker != nil)
		[picker release];
	if (image2 != nil) {
		
		if( image1 != nil)
			[image1 release];
		[image2 release];
		image1 = nil;
		image2 = nil;
	}
	picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.sourceType = sourceType;
	[self presentModalViewController:picker animated:YES];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	// Dismiss the image selection, hide the picker and show the image view with the picked image
	if (image1 == nil) {
		image = [[image rotate_scaleTo:200] retain];
		[testImage setImage:image];
		[testImage setNeedsDisplay];
//		[testImage setImage:nil];
		image1 = [[IntegralImage alloc] initFromImage:image];
		[testImage setImage_frame:CGSizeMake(image1.width, image1.height)];
//		if( picker.sourceType == UIImagePickerControllerSourceTypeCamera)
//			[picker dismissModalViewControllerAnimated:YES];
//		[self presentModalViewController:picker animated:YES];
//		picker.view.hidden = NO;
	}
	else {
		image = [image rotate_scaleTo:200];
		[testImage2 setImage:image];
		[testImage2 setNeedsDisplay];
//		[testImage2 setImage:nil];
		[picker dismissModalViewControllerAnimated:YES];
		picker.view.hidden = YES;
		image2 = [[IntegralImage alloc] initFromImage:image];
		[testImage2 setImage_frame:CGSizeMake(image2.width, image2.height)];
		[self runTest_final];
	}

}


-(void) runTest_final
{
//	UIImage *image = image1; //[UIImage imageNamed:@"cookie_monster.gif"];
	
	
//	IntegralImage *img = [[IntegralImage alloc] initFromImage:image];
	NSLog(@"started algorithm");
	NSDate *methodStart = [NSDate date];
	
	/* ... Do whatever you need to do ... */
	
	IntegralImage *img = image1;
	HassienDetector *detect = [[HassienDetector alloc] initWithParams:0.0002 :5 :1];
	NSMutableArray *features = [NSMutableArray new];
	[detect detectFeatures:img:features];
	
	for (int i=0; i<features.count; i++) {
		Feature *ft = [features objectAtIndex:i];
		if (ft.descriptors == nil) {
			NSLog(@"memory problem");
		}
	}
	
	Descriptor *des = [[Descriptor alloc] init];
	[des describeInterestPoints:features :img];
	
	
//	UIImage *image2 =[UIImage imageNamed:@"cookie_monster_bigger.png"];
	
//	[testImage2 setImage:image2];
	
	IntegralImage *img2 = image2; //[[IntegralImage alloc] initFromImage:image2];
	HassienDetector *detect2 = [[HassienDetector alloc] initWithParams:0.0002 :5 :1];
	NSMutableArray *features2 = [NSMutableArray new];
	[detect2 detectFeatures:img2: features2];
	
	Descriptor *des2 = [[Descriptor alloc] init];
	[des2 describeInterestPoints:features2 :img2];
	
	float thresh = 1.9;
	
	NSMutableArray *filtered = [NSMutableArray new];
	NSMutableArray *filtered2 = [NSMutableArray new];
	
	for (int i=0; i<features2.count; i++)
	{
		Feature *ft2 = [features2 objectAtIndex:i];
		BOOL has_twin = FALSE;
		for (int j=0; j<features.count; j++)
		{
			Feature *ft = [features objectAtIndex:j];
			if ([ft compareToFeature:ft2] < thresh) {
				has_twin = TRUE;
				[filtered addObject:ft];
				break;
			}
		}
		if (has_twin) {
			[filtered2 addObject:ft2];
		}
	}
	NSDate *methodFinish = [NSDate date];
	NSLog(@"finished algorithm");
	NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
	[performace_label setText:[NSString stringWithFormat:@"%f secs", executionTime]];
	[detect release];
//	[img release];
	[detect2 release];
//	[img2 release];
	[testImage setFeatures:filtered];
	[testImage setNeedsDisplay];
	[testImage2 setFeatures:filtered2];
	[testImage2 setNeedsDisplay];
	[filtered release];
	[filtered2 release];
	[features release];
	[features2 release];
	[des release];
	[des2 release];
}

- (void)drawCircle:(int) x: (int)y :(int) radius : (CGFloat *) color
{
	CGContextRef c = UIGraphicsGetCurrentContext();		
	CGContextSetStrokeColor(c, color);
	CGRect rect = CGRectMake((float)x, (float)y, (float)radius, (float)radius);
	CGContextStrokeEllipseInRect(c,rect);
}

-(IBAction) runAugmentedReality {
	// set up our camera overlay view
	
	// tool bar - handy if you want to be able to exit from the image picker...
	UIToolbar *toolBar=[[[UIToolbar alloc] initWithFrame:CGRectMake(0, 480-44, 320, 44)] autorelease];
	NSArray *items=[NSArray arrayWithObjects:
					[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil] autorelease],
					[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone  target:self action:@selector(finishedAugmentedReality)] autorelease],
					nil];
	[toolBar setItems:items];
	// create the overlay view
	overlayView=[[[OverlayView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-44)] autorelease];
	// important - it needs to be transparent so the camera preview shows through!
	overlayView.opaque=NO;
	overlayView.backgroundColor=[UIColor clearColor];
	// parent view for our overlay
	UIView *parentView=[[[UIView alloc] initWithFrame:CGRectMake(0,0,320, 480)] autorelease];
	[parentView addSubview:overlayView];
	[parentView addSubview:toolBar];
	
	// configure the image picker with our overlay view
	picker=[[UIImagePickerController alloc] init];
	picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//	UIImagePickerControllerSourceTypePhotoLibrary;
	// hide the camera controls
	picker.showsCameraControls=NO;
	picker.videoQuality = UIImagePickerControllerQualityTypeLow;
	picker.delegate = nil;
	picker.allowsImageEditing = NO;
	// and put our overlay view in
	picker.cameraOverlayView=parentView;
	[self presentModalViewController:picker animated:YES];		
//	[picker release];
	// start our processing timer
	processingTimer=[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(processImage) userInfo:nil repeats:YES];
}

-(void) finishedAugmentedReality {
	[self dismissModalViewControllerAnimated:YES];
	[processingTimer invalidate];
	overlayView=nil;
}

// this is where is all happens
CGImageRef UIGetScreenImage();

-(void) processImage {
/*	UIView *view = picker.view;
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, view.contentScaleFactor);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[view.layer renderInContext:context];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	// Convert UIImage to CGImage
	CGImageRef screenCGImage = [UIImage down_scale:image.CGImage :200];
*/
	CGImageRef cgScreen = UIGetScreenImage();
	cgScreen = [UIImage	down_scale:cgScreen :100];
	IntegralImage *img = [[IntegralImage alloc] initFromCGImage:cgScreen];
	overlayView.image_frame = CGSizeMake(CGImageGetWidth(cgScreen), CGImageGetHeight(cgScreen));
	HassienDetector *detect = [[HassienDetector alloc] initWithParams:0.0002 :3 :1];
	NSMutableArray *c_features = [NSMutableArray new];
	[detect detectFeatures:img:c_features];
	
	Descriptor *des = [[Descriptor alloc] init];
	[des describeInterestPoints:c_features :img];
	if( perv_features != nil)
	{
		float thresh = 1.9;
	
		NSMutableArray *filtered = [NSMutableArray new];
	
		for (int i=0; i<c_features.count; i++)
		{
			Feature *ft2 = [c_features objectAtIndex:i];
			BOOL has_twin = FALSE;
			for (int j=0; j<perv_features.count; j++)
			{
				Feature *ft = [perv_features objectAtIndex:j];
				double score = [ft compareToFeature:ft2];
				if ( score < thresh) {
					NSLog(@"found matches with score %f", score);
					NSLog(@"found matches with x,y %f,%f and scale %f", ft2.x, ft2.y, ft2.scale);
					has_twin = TRUE;
					break;
				}
			}
			if (has_twin)
			{
				[filtered addObject:ft2];
			}
		}
		NSLog(@"found %d matches",filtered.count);
		[overlayView setFeatures:filtered];
		[overlayView setNeedsDisplay];
		[filtered release];
		[perv_features release];
	}
	NSLog(@"******************** Look at me *******************");
	NSLog(@"%d" ,c_features.count);
	[img release];
	perv_features = c_features;
//	[image release];
	[detect release];
	[des release];
//	[image2 release];
	
/*	Image *screenImage=fromCGImage(screenCGImage, overlayView.frame);
	CGImageRelease(screenCGImage);
	// process the image to remove our drawing - WARNING the edge pixels of the image are not processed
	Image *drawnImage=overlayView.drawnImage;
	for(int y=1;y<screenImage->height-1; y++) {
		for(int x=1; x<screenImage->width-1; x++) {
			// if we draw to this pixel replace it with the average of the surrounding pixels
			if(drawnImage->pixels[y][x]!=0) {
				screenImage->pixels[y][x]=(screenImage->pixels[y-1][x]+screenImage->pixels[y+1][x]+
										   screenImage->pixels[y][x-1]+screenImage->pixels[y][x+1])/4;
			}
		}
	}
*/	
	// simple edge detection and tracing
	// finished with our screen image
//	destroyImage(screenCGImage);
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	NSLog(@"^^^^^%&%&$&$%&$%&Warning recieved");
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[testImage release];
	[testImage2 release];
	[performace_label release];
    [super dealloc];
}

@end
