//
//  PrefsViewController.m
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PrefsViewController.h"

@implementation PrefsViewController
@synthesize prefs;
@synthesize delegate;

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
    
    if (prefs.localServer != nil) {
        localServerField.text = prefs.localServer;
    }
    if (prefs.port != 0) {
        portField.text = [NSString stringWithFormat: @"%i", prefs.port];
    }
    if (prefs.deviceName != nil) {
        deviceNameField.text = prefs.deviceName;
    }
    mapView.selectedSegmentIndex = prefs.autoAdjust;
}

- (void)viewDidUnload
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    [deviceNameField release];
    [postServerField release];
    [localServerField release];
    [portField release];
    [mapType release];
    [mapView release];
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
    if (textField == localServerField) {
        prefs.localServer = localServerField.text;
        [defaults setObject: prefs.localServer forKey:@"server"];
    }
    if (textField == portField) {
        int a = [portField.text intValue];
        if (a != 0) {
            prefs.port = a;
            [defaults setObject: [NSString stringWithFormat: @"%i", prefs.port] forKey:@"port"];
        }
    }
    if (textField == deviceNameField) {
        prefs.deviceName = deviceNameField.text;
        [defaults setObject: prefs.deviceName forKey:@"deviceName"];
    }
}

- (IBAction)mapChanged:(UISegmentedControl *)sender {
    [delegate mapChosen: [sender selectedSegmentIndex]];
}

- (IBAction)updateChanged:(UISegmentedControl *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    prefs.autoAdjust = [sender selectedSegmentIndex];
    switch ([sender selectedSegmentIndex]) {
        case 0:
            [delegate mapTrackingChanged: NO];
            break;
        case 1:
            [delegate mapTrackingChanged: YES];
            break;
        case 2:
            [delegate mapTrackingChanged: NO];
            break;  
    }
    [defaults setInteger: (NSInteger)[sender selectedSegmentIndex] forKey: @"autoAdjust"];
}

- (void)dealloc {
    [deviceNameField release];
    [postServerField release];
    [localServerField release];
    [portField release];
    [mapType release];
    [mapView release];
    [super dealloc];
}
@end
