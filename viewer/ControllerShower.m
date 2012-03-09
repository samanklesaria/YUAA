//
//  ControllerShower.m
//  viewer
//
//  Created by Sam Anklesaria on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ControllerShower.h"
#import <Foundation/Foundation.h>

@implementation ControllerShower
@synthesize shower;

- (id)initWithConnector: (Connector *)c shower: (id)s graphView: (GraphViewController *)g orientationView: (Orientation *)o picView: (PicViewController *)p
{
    self = [self init];
    if (self) {
        graphView = [g retain];
        [graphView view];
        orientation = [o retain];
        picViewController = [p retain];
        graphLogic = [[GraphLogic alloc] initWithGraphView:graphView.graphView];
        connector = [c retain];
        shower = [s retain];
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        [connector sendMessage: [alertView textFieldAtIndex: 0].text];
    }
}

-(void)showGraphWithTag:(NSString *)tag frame: (CGRect)rect view: (UIView *)view title: (NSString *)title {
    [shower showController: graphView withFrame:rect view:view title: title];
    FlightData *f = [FlightData instance];
    StatPoint *tmp = [f.balloonStats objectForKey: tag];
    [graphLogic showDataSource: tmp named: title];
}

-(void)showOrientationWithFrame: (CGRect)rect view: (UIView *)view {
    [shower showController: orientation withFrame: rect view: view title: @"Orientation"];
}

-(void)showPicturesWithFrame:(CGRect)rect view:(UIView *)view {
    [shower showController: picViewController withFrame: rect view: view title: @"Pictures"];
}

- (void)showController:(UIViewController *)controller withFrame: (CGRect)rect view: (UIView *)view title: (NSString *)title {
    [shower showController: controller withFrame: rect view:view title:title];
}

- (void)sendMessage {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle: @"Send Command" message: @"Type the AKP tags to be sent:" delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Ok",nil] autorelease];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void) dealloc {
    [orientation release];
    [graphLogic release];
    [graphView release];
    [connector release];
    [picViewController release];
    [shower release];
    [super dealloc];
}

@end
