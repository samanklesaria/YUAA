//
//  Helium_HelpAppDelegate.m
//  Helium Help
//
//  Created by Sam Anklesaria on 11/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Helium_HelpAppDelegate.h"

@implementation Helium_HelpAppDelegate
@synthesize finalPressureOutput = _finalPressureOutput;

@synthesize pressureSlider = _pressureSlider;
@synthesize heightSlider = _heightSlider;
@synthesize heightField = _heightField;
@synthesize pressureField = _pressureField;
@synthesize volumeSlider = _volumeSlider;
@synthesize volumeField = _volumeField;
@synthesize heliumOutput = _heliumOutput;
@synthesize radiusOutput = _radiusOutput;
@synthesize volumeOutput = _volumeOutput;
@synthesize window = _window;
@synthesize pressureOutput = _pessureOutput;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
     
    [self.window makeKeyAndVisible];
    [self updateStats];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    if (_heightSlider)
        [_heightSlider release];
    [_heightField release];
    if (_pressureSlider)
        [_pressureSlider release];
    [_pressureField release];
    if (_volumeSlider)
        [_volumeSlider release];
    [_volumeField release];
    [_pessureOutput release];
    [_heliumOutput release];
    [_volumeOutput release];
    [_radiusOutput release];
    [_finalPressureOutput release];
    [super dealloc];
}

- (void) updateStats {
    double l = .0065; 
    double h = [self.heightField.text doubleValue];
    double t = 196.5 + 0.001*h; // holds only above 20,000 m
    double v = 325.47; // using 5m bursting radius at 100,000m
    double to = 288.15; // kelvin
    double r = 8.31447;
    double m = 0.0289644;
    double g = 9.81;
    double po = 101325;
    
    double p1 = po * pow((1 - (l*11000)/to),(g*m/(r*l)));
    double p2 = p1 * pow((1 - (.001*22000)/to),(g*m/(r*0.001)));    
    
    double moles = p2*v/(r*t);
    double vo = moles*r*to/po; // volume on the ground
    double radius = cbrt(3*vo/(4.0*3.14159));
    
    double initialPressure = [self.pressureField.text doubleValue];
    double tankVolume = [self.heightField.text doubleValue];
    double initialMoles = initialPressure * tankVolume / (r*to);
    double finalMoles = initialMoles - moles;
    double finalPressure = r*t * finalMoles / tankVolume;
    
    self.pressureOutput.text = [NSString stringWithFormat: @"%.3f pascals", p2];
    
    self.heliumOutput.text = [NSString stringWithFormat: @"%.3f moles", moles];
    self.volumeOutput.text = [NSString stringWithFormat: @"%.3f meters^3" ,vo];
    self.radiusOutput.text = [NSString stringWithFormat: @"%.3f meters", radius];
    self.finalPressureOutput.text = [NSString stringWithFormat: @"%.3f pascals",finalPressure];
 
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)pressureChanged:(UISlider *)sender {
    float str = [sender value]; // not sure about this
    self.pressureField.text = [NSString stringWithFormat: @"%3f", str];
    [self updateStats];
}

- (IBAction)heightChanged:(UISlider *)sender {
    float str = [sender value];
    self.heightField.text = [NSString stringWithFormat: @"%3f", str];
    [self updateStats];
}
- (IBAction)volumeChanged:(UISlider *)sender {
    float str = [sender value];
    self.volumeField.text = [NSString stringWithFormat: @"%3f", str];
    [self updateStats];
}

- (IBAction)heightFieldChanged:(UITextField *)sender {
    [self.heightSlider setValue: [sender.text floatValue]];
    [self updateStats];
}

- (IBAction)pressureFieldChanged:(UITextField *)sender {
    [self.pressureSlider setValue: [sender.text floatValue]];
    [self updateStats];
}

- (IBAction)volumeFieldChanged:(UITextField *)sender {
    [self.volumeSlider setValue: [sender.text floatValue]];
    [self updateStats];
}
@end
