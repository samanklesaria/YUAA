//
//  PrefsViewController.m
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PrefsViewController.h"

@implementation PrefsViewController
@synthesize phoneNumber;
@synthesize serverField;
@synthesize portField;
@synthesize nameField;

- (void) updateConnector {
    if ([SharedData instance].server && [[SharedData instance].server length] > 0 && [SharedData instance].port > 0) {
        [con release];
        con = [[Connector alloc] init];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    SharedData *s = [SharedData instance];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *serverString = [defaults stringForKey: @"server"];
    if (serverString != nil) {
        s.server = serverString;
        serverField.text = s.server;
    }
    NSString *portString = [defaults objectForKey: @"port"];
    if (portString != nil) {
        portField.text = portString;
        s.port = [portField.text integerValue];
    }
    NSString *phoneNum = [defaults objectForKey: @"phoneNumber"];
    if (phoneNum != nil) {
        phoneNumber.text = phoneNum;
        s.phoneNumber = phoneNum;
    }
    NSString *devName = [defaults objectForKey: @"deviceName"];
    if (devName != nil) {
        nameField.text = devName;
        s.deviceName = devName;
    }
    NSInteger adjVal = [defaults integerForKey: @"autoAdjust"];
    [autoUpdateControl setSelectedSegmentIndex: adjVal];
    s.autoAdjust = (enum mapAdjust)adjVal;
    [self updateConnector];
}

- (void)viewDidUnload
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    [self setServerField:nil];
    [self setPortField:nil];
    [self setPhoneNumber:nil];
    [autoUpdateControl release];
    autoUpdateControl = nil;
    [self setNameField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    SharedData *s = [SharedData instance];
    if (textField == serverField) {
        [[SharedData instance] setServer: textField.text];
        [self updateConnector];
        [defaults setObject: s.server forKey:@"server"];
        return;
    }
    if (textField == portField) {
        int a = [portField.text intValue];
        if (a != 0) {
            [[SharedData instance] setPort: a];
            [self updateConnector];
            [defaults setObject: [NSString stringWithFormat: @"%i", s.port] forKey:@"port"];
        }
        return;
    }
    if (textField == phoneNumber) {
        [[SharedData instance] setPhoneNumber: textField.text];
        [defaults setObject: s.phoneNumber forKey:@"phoneNumber"];
        return;
    }
    if (textField == nameField) {
        [[SharedData instance] setDeviceName: textField.text];
        [defaults setObject: s.deviceName forKey:@"deviceName"];
        return;
    }
}

- (IBAction)mapChanged:(UISegmentedControl *)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0: 
            [[[SharedData instance] map] setMapType: MKMapTypeStandard];
            break;
        case 1: 
            [[[SharedData instance] map] setMapType: MKMapTypeSatellite];
            break;
        case 2: 
            [[[SharedData instance] map] setMapType: MKMapTypeHybrid];
            break;
    }
}

- (IBAction)updateChanged:(UISegmentedControl *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    SharedData *s = [SharedData instance];
    switch ([sender selectedSegmentIndex]) {
        case 0:
            s.autoAdjust = AUTO;
            [s.map setUserTrackingMode: MKUserTrackingModeNone];
            break;
        case 1:
            s.autoAdjust = CAR;
            [s.map setUserTrackingMode: MKUserTrackingModeFollowWithHeading animated: YES];
            break;
        case 2:
            s.autoAdjust = MANUAL;
            [s.map setUserTrackingMode: MKUserTrackingModeNone];
            break;  
    }
    [defaults setInteger: (NSInteger)s.autoAdjust forKey: @"autoAdjust"];
}

- (void)dealloc {
    [serverField release];
    [portField release];
    [phoneNumber release];
    [autoUpdateControl release];
    [nameField release];
    [super dealloc];
}
@end
