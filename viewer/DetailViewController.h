//
//  DetailViewController.h
//  ipad viewer
//
//  Created by Sam Anklesaria on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedData.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import "BalloonMapLogic.h"

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
    IBOutlet MKMapView *map;
    BalloonMapLogic *balloonLogic;
}

- (IBAction)showSettings:(id)sender;
- (IBAction)showLog:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (void)showController:(UIViewController *)controller withFrame: (CGRect)rect view: (UIView *)view title: (NSString *)title;

@end
