//
//  OR_test1AppDelegate.h
//  OR_test1
//
//  Created by Ishai Jaffe on 9/11/10.
//  Copyright none 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OR_test1ViewController;

@interface OR_test1AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    OR_test1ViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet OR_test1ViewController *viewController;

@end

