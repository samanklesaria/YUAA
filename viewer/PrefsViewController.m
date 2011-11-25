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
@synthesize remoteServer;
@synthesize remotePort;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    SharedData *s = [SharedData instance];
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        s.server = [defaults stringForKey: @"localserver"];
        serverField.text = s.server;
        portField.text = [defaults objectForKey: @"localport"];
        s.port = [portField.text integerValue];
        s.remoteServer = [defaults stringForKey: @"remoteserver"];
        remoteServer.text = s.remoteServer;
        remotePort.text = [defaults objectForKey: @"remoteport"];
        s.remotePort = [remotePort.text integerValue];
        [self updateConnector];
    }
    return self;
}

- (void) updateConnector {
    if ([SharedData instance].server && [[SharedData instance].server length] > 0 && [SharedData instance].port) {
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
    scrollView.contentSize = CGSizeMake(320, 450); //325 448
	[scrollView flashScrollIndicators];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setServerField:nil];
    [self setPortField:nil];
    [self setPhoneNumber:nil];
    [scrollView release];
    scrollView = nil;
    [self setRemoteServer:nil];
    [self setRemotePort:nil];
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

// should erase invalid ports
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == serverField) {
        [[SharedData instance] setServer: textField.text];
        [self updateConnector];
    }
    if (textField == remoteServer)
        [[SharedData instance] setRemoteServer: textField.text];
    if (textField == portField) {
        int a = [portField.text intValue];
        if (a != 0) {
            [[SharedData instance] setPort: a];
            [self updateConnector];
        }
    }
    if (textField == remotePort) {
        int a = [textField.text integerValue];
        if (a != 0) {
            [[SharedData instance] setRemotePort: a];
        }
    }
    if (textField == phoneNumber)
        [[SharedData instance] setPhoneNumber: textField.text];
}


- (IBAction)adjustChanged:(UISwitch *)sender {
    [[SharedData instance] setAutoAdjust: sender.on];
}

NSMutableArray *logData;
NSString *server;
NSNumber *port;
NSString *mapType;
bool *autoAdjust;

- (IBAction)mapChanged:(UISegmentedControl *)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0: 
            [[SharedData instance] setMapType: MKMapTypeStandard];
            break;
        case 1: 
            [[SharedData instance] setMapType: MKMapTypeSatellite];
            break;
        case 2: 
            [[SharedData instance] setMapType: MKMapTypeHybrid];
            break;
    }
}

- (void)dealloc {
    SharedData *s = [SharedData instance];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: s.server forKey:@"localserver"];
    [defaults setObject: s.remoteServer forKey:@"remoteserver"];
    [defaults setObject: [NSString stringWithFormat: @"%i", s.port] forKey:@"localport"];
    [defaults setObject: [NSString stringWithFormat: @"%i", s.remotePort] forKey:@"remotePort"];
    [serverField release];
    [portField release];
    [phoneNumber release];
    [scrollView release];
    [remoteServer release];
    [remotePort release];
    [super dealloc];
}
@end
