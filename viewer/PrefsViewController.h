//
//  PrefsViewController.h
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Prefs.h"

@protocol PrefsResponder <NSObject>
- (void)mapChosen: (int)type;
- (void)mapTrackingChanged: (bool)type;
@end

@interface PrefsViewController : UIViewController <UITextFieldDelegate> {
    
    IBOutlet UISegmentedControl *mapView;
    IBOutlet UISegmentedControl *mapType;
    IBOutlet UITextField *portField;
    IBOutlet UITextField *localServerField;
    IBOutlet UITextField *postServerField;
    IBOutlet UITextField *deviceNameField;
    id <PrefsResponder> delegate;
    Prefs *prefs;
}

- (IBAction)mapChanged:(UISegmentedControl *)sender;
- (IBAction)updateChanged:(UISegmentedControl *)sender;
@property (retain) Prefs *prefs;
@property (retain) id delegate;
@end
