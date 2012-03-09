//
//  GraphViewController.h
//  viewer
//
//  Created by Sam Anklesaria on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "GraphLogic.h"

@interface GraphViewController : UIViewController {
    
}
@property (retain, nonatomic) IBOutlet CPTGraphHostingView *graphView;

@end
