//
//  PicViewController.h
//  viewer
//
//  Created by Sam Anklesaria on 11/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicViewController : UIViewController {
    UIImageView *image;
    bool handleSwipe;
    int imageIndex;
}

@property (nonatomic, retain) IBOutlet UIImageView *image;

@end
