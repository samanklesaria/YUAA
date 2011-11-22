//
//  PicViewController.h
//  viewer
//
//  Created by Sam Anklesaria on 11/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicViewController : UIViewController {
    UIPageControl *pageControl;
    UIImageView *image;
}

- (IBAction)pageValueChanged:(id)sender;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) IBOutlet UIImageView *image;

@end
