//
//  Orientation.h
//  viewer
//
//  Created by Sam Anklesaria on 11/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"

@interface Orientation : UIViewController {
    EAGLView *glView;
}

@property (nonatomic, retain) IBOutlet EAGLView *glView;

@end
