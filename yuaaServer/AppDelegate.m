//
//  AppDelegate.m
//  yuaaServer
//
//  Created by Sam Anklesaria on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "StatPoint.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        processor = [[Processor alloc] init];
        df = [NSDateFormatter new];
        [df setDateFormat: @"HH:mm:ss"];
        return self;
    }
    return self;
}    

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    prefsViewController = [[PrefsPopupController alloc] initWithNibName:@"PrefsPopupController" bundle:nil];
    prefs = [[Prefs alloc] init];
    prefsViewController.prefs = prefs;
    prefsViewController.delegate = self;
    [prefsViewController view];
    [FlightData instance];
    processor = [[Processor alloc] initWithPrefs: prefs];
    processor.delegate = self;
    networkManager = [[NetworkManage alloc] initWithDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConnections:) name:@"connectionUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebuildPortList) name:AMSerialPortListDidAddPortsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebuildPortList) name:AMSerialPortListDidRemovePortsNotification object:nil];
    popOver = [[NSPopover alloc] init];
    portList = prefsViewController.serialPortCell;
    akpsend = [[AKPSender alloc] initWithNibName:@"AKPSender" bundle:nil];
    popOver.behavior = NSPopoverBehaviorSemitransient;
    [self rebuildPortList];
    [NSThread detachNewThreadSelector: @selector(defibrillator) toTarget:self withObject:nil];
    graphLogic = [[GraphLogic alloc] initWithGraphView: graphHostingView];
    
    NSString *mapString = [[NSBundle mainBundle] pathForResource:@"map" ofType:@"html"];
    NSURL *mapFileURL = [NSURL URLWithString:mapString];
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:mapFileURL]];
    [[[webView mainFrame] frameView] setAllowsScrolling:NO];
    [webView setNeedsDisplay:YES];
    currentView = webView;
}

-(void)restartSerial:(NSString *)port {
    NSLog(@"Restaring serial");
    if ([port isEqualToString: @"Test Data"]) {
        [NSThread detachNewThreadSelector:@selector(parseDemoFile) toTarget:self withObject:nil];
    } else {
        NSArray *a = [[AMSerialPortList sharedPortList] serialPorts];
        for (AMSerialPort *s in a) {
            //NSLog(@"S: %@",s);
            if ([[s description] rangeOfString:port].length != 0) {
                NSLog(@"Connecting to Arduino");
                [currentSerialPort free];
                [currentSerialPort autorelease];
                currentSerialPort = [s retain];
                [currentSerialPort setDelegate:self];
                if (![currentSerialPort open]) {
                    NSLog(@"Error opening port.");
                    return;
                } else {
                    akpsend.serialPort = currentSerialPort;
                    [currentSerialPort readDataInBackground];
                }
                break;
            }
        }
    }
}

- (void) defibrillator {
    [NSTimer scheduledTimerWithTimeInterval: 1 target: self selector:@selector(heartbeat) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] run];
}

- (void) heartbeat {
    [sourceList reloadData];
    if (lastUpdate)
        lastReceivedCell.title = [@"Last Update: " stringByAppendingString: [df stringFromDate: lastUpdate]];
    if (!currentLog) {
        NSRange range;
        range = NSMakeRange ([[textForLog string] length], 0);
        [textForLog scrollRangeToVisible: range];
    } else [tableForLog reloadData];
}

-(void)updateConnections:(NSNotification *)notif {
    int number = [[notif object] intValue];
    FlightData *f = [FlightData instance];
    [f.netLogData addObject: @"Connections changed"];
    [connectionField setStringValue:[NSString stringWithFormat:@"Connections: %i",number]];
}

-(void)rebuildPortList {
    [portList removeAllItems];
    NSArray *a = [[AMSerialPortList sharedPortList] serialPorts];
    
    for (int i=0;i<[a count];i++) {
        [portList addItemWithTitle:[(AMSerialPort *)[a objectAtIndex:i] name]];
    }
    [portList addItemWithTitle: @"Test Data"];
}

- (void)serialPortReadData:(NSDictionary *)dDictionary {
	AMSerialPort *port = [dDictionary valueForKey:@"serialPort"];
	NSData *d = [dDictionary valueForKey:@"data"];
    [networkManager writeData:d];
    NSString *str = [[[NSString alloc] initWithData: d encoding:NSASCIIStringEncoding] autorelease];
    const char *d_unsafe = [d bytes];
    [lastUpdate autorelease];
    lastUpdate = [[NSDate date] retain];
    lastReceivedCell.title = [df stringFromDate: [NSDate date]];
    [[textForLog textStorage] beginEditing];
    [[[textForLog textStorage] mutableString] appendString:str];
    [[textForLog textStorage] endEditing];
    int i;
    for (i=0; i < [d length]; i++) {
            [processor updateData: *(d_unsafe+i)];
    }
    [port readDataInBackground];
}

- (void)parseDemoFile {
    NSLog(@"Starting demo");
    const char *filePath = [[[NSBundle mainBundle] pathForResource: @"demo" ofType: nil] cStringUsingEncoding:NSASCIIStringEncoding];
    FILE *p = fopen(filePath, "r");
    char c;
    while (!feof(p)) {
        c = fgetc(p);
        [processor updateData: c];
    }
    fclose(p);
    // should I update logs too? yeah, I should. 
    
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    FlightData *f = [FlightData instance];
    if (aTableView == tableForLog) {
        return [currentLog objectAtIndex: rowIndex];
    } else {
        if ([[aTableColumn identifier] isEqualToString: @"tag"]) {
            if (rowIndex == 0) {
                return @"Location";
            }
            if (rowIndex == 1) {
                return @"Orientation";
            }
            if (rowIndex == 2) {
                return @"Pictures";
            }            
            NSString *t = [f.nameArray objectAtIndex:rowIndex -3];
            NSString *humanName = [f.plistData objectForKey: t];
            NSString *result = (humanName != NULL) ? humanName : t;
            return result;
            
        } else {
            NSDate *updatedDate;
            NSString *body;
            if (rowIndex == 0) {
                updatedDate = f.lastLocTime;
                if (f.lat && f.lon) {
                    body = [NSString stringWithFormat: @"Lat: %f, Lon: %f", f.lat, f.lon];
                } else body = @"";
            } else if (rowIndex == 1) {
                updatedDate = f.lastIMUTime;
                body = [NSString stringWithFormat: @"Yaw: %.2f, Pitch: %.2f, Roll: %.2f",
                        f.rotationZ, f.rotationY, f.rotationX];
            } else if (rowIndex == 2) {
                body = [NSString stringWithFormat: @"%d", [f.pictures count]];
                updatedDate = f.lastImageTime;
            } else {
                NSString *tag = [f.nameArray objectAtIndex:rowIndex -3];
                StatPoint *stat = [f.balloonStats objectForKey: tag];
                if (stat.lastTime) {
                    updatedDate = stat.lastTime;
                }
                NSNumber *n = [(NSDictionary *)[(NSArray *)[stat points] lastObject] objectForKey: @"y"];
                body = [n description];
            }
            
            if (updatedDate) {
                return [NSString stringWithFormat: @"%@ (%@)", body, [df stringFromDate: updatedDate]];
            }
            return body;
        }
    }
}
        
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == tableForLog) {
        if (currentLog)
            [currentLog count];
        return 0;
    } else {
        FlightData *f = [FlightData instance];
        NSInteger a = [f.nameArray count] + 3;
        return a;
    }
}

- (void) serverStatus: (bool) status {
    serverUpCell.title = status ? @"YES" : @"NO";
}

- (IBAction)changeLogView:(NSPopUpButtonCell *)sender {
    NSString *logType = [[sourceCell selectedItem] title];
    if ([logType isEqualToString: @"Serial Data"]) {
        [logText setHidden: NO];
        [logTable setHidden: YES];
        currentLog = NULL;
    } else {
        [logText setHidden: YES];
        [logTable setHidden: NO];
        FlightData *f = [FlightData instance];
        if ([logType isEqualToString: @"Parsing Log"]) currentLog = f.parseLogData;
        if ([logType isEqualToString: @"Network Log"]) currentLog = f.netLogData;
        
    }
}


- (void)mapChosen: (int)type {
    // how do I do this?
}

- (void)mapTrackingChanged: (bool)type {
    // how do I do this?
}

-(void)receivedPicture {
    [serverPicController addedImage];
}

-(void)receivedLocation {
    // how do i do this?
}

- (IBAction)showPrefs:(NSButton *)sender {
    [popOver close];
    NSSize mysize;
    mysize.width = 258;
    mysize.height = 121;
    popOver.contentSize = mysize;
    popOver.contentViewController = prefsViewController;
    [popOver showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxXEdge];
}

- (IBAction)sendAKP:(id)sender {
    [popOver close];
    NSSize mysize;
    mysize.width = 215;
    mysize.height = 33;
    popOver.contentSize = mysize;
    popOver.contentViewController = akpsend;
    [popOver showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxXEdge];
    [akpsend showMe];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSUInteger i = [sourceList selectedRow];
    [currentView setHidden: YES];
    switch (i) {
        case 0:
            [webView setHidden: NO];
            currentView = webView;
            break;
        case 1:
            NSLog(@"OpenGL Time");
            [openGLView setHidden: NO];
            currentView = openGLView;
            break;
        case 2:
            NSLog(@"Picture Time");
            [serverPicController.view setHidden: NO];
            currentView = serverPicController.view;
            break;
        default:
            [graphHostingView setHidden: NO];
            currentView = graphHostingView;
            FlightData *f = [FlightData instance];
            NSString *tag = [f.nameArray objectAtIndex: i -2];
            StatPoint *tmp = [f.balloonStats objectForKey: tag];
            [graphLogic showDataSource: tmp named: tag];
    }
}


@end
