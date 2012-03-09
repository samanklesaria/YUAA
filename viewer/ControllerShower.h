//
//  ControllerShower.h
//  viewer
//
//  Created by Sam Anklesaria on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AbstractControllerShower.h"
#import "Orientation.h"
#import "GraphLogic.h"
#import "Connector.h"
#import "GraphViewController.h"
#import "PicViewController.h"

@interface ControllerShower : NSObject <UIAlertViewDelegate> {
    id <AbstractControllerShower> shower;
    Orientation *orientation;
    GraphLogic *graphLogic;
    PicViewController *picViewController;
    GraphViewController *graphView;
    Connector *connector;
}

-(void)showGraphWithTag:(NSString *)tag frame: (CGRect)rect view: (UIView *)view title: (NSString *)title;
-(void)showOrientationWithFrame: (CGRect)rect view: (UIView *)view;
-(void)showPicturesWithFrame: (CGRect)rect view: (UIView *)view;

-(void)showController:(UIViewController *)controller withFrame: (CGRect)rect view: (UIView *)view title: (NSString *)title;
-(void)sendMessage;
- (id)initWithConnector: (Connector *)c shower: (id)s graphView: (GraphViewController *)g orientationView: (Orientation *)o picView: (PicViewController *)p;

@property (retain) id shower;

@end

