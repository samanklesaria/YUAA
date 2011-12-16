//
//  Helium_HelpAppDelegate.h
//  Helium Help
//
//  Created by Sam Anklesaria on 11/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Helium_HelpAppDelegate : NSObject <UIApplicationDelegate> {
    
    UISlider *_heightSlider;
    UITextField *_heightField;
    UITextField *_pressureField;
    UISlider *_volumeSlider;
    UITextField *_volumeField;
    UILabel *_heliumOutput;
    UILabel *_radiusOutput;
    UILabel *_volumeOutput;
    UISlider *_pressureSlider;
    UILabel *_pessureOutput;
    UILabel *_finalPressureOutput;
}
- (IBAction)temperatureChanged:(UISlider *)sender;

- (IBAction)heightChanged:(UISlider *)sender;

@property (nonatomic, retain) IBOutlet UISlider *pressureSlider;

@property (nonatomic, retain) IBOutlet UISlider *heightSlider;

@property (nonatomic, retain) IBOutlet UITextField *heightField;

@property (nonatomic, retain) IBOutlet UITextField *temperatureField;

@property (nonatomic, retain) IBOutlet UISlider *volumeSlider;

@property (nonatomic, retain) IBOutlet UITextField *volumeField;

@property (nonatomic, retain) IBOutlet UILabel *heliumOutput;

@property (nonatomic, retain) IBOutlet UILabel *radiusOutput;

@property (nonatomic, retain) IBOutlet UILabel *volumeOutput;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UILabel *pressureOutput;

- (IBAction)volumeChanged:(UISlider *)sender;

- (IBAction)heightFieldChanged:(UITextField *)sender;

- (IBAction)pressureFieldChanged:(UITextField *)sender;

- (IBAction)volumeFieldChanged:(UITextField *)sender;

- (void)updateStats;

@property (nonatomic, retain) IBOutlet UILabel *finalPressureOutput;

@end
