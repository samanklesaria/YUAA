//
//  PrefsViewController.h
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedData.h"
#import <MapKit/MapKit.h>
#import "Connector.h"

@interface PrefsViewController : UIViewController <UITextFieldDelegate> {
    UITextField *serverField;
    UITextField *portField;
    UITextField *phoneNumber;
    IBOutlet UISegmentedControl *autoUpdateControl;
    Connector *con;
}

@property (nonatomic, retain) IBOutlet UITextField *phoneNumber;
@property (nonatomic, retain) IBOutlet UITextField *serverField;
@property (nonatomic, retain) IBOutlet UITextField *portField;
@property (retain, nonatomic) IBOutlet UITextField *nameField;

- (IBAction)mapChanged:(UISegmentedControl *)sender;
- (IBAction)updateChanged:(UISegmentedControl *)sender;
- (void) updateConnector;
@end
