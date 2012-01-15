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
    NSMutableArray *images;
}

- (void)updatePics;
- (void)addImage:(UIImage *)theImage;
- (NSData *)getImageTag;
- (int)imagesCount;

@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (retain, nonatomic) IBOutlet UILabel *imageCounter;

@end
