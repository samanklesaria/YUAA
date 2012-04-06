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
   [log closeFile];
    [log release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        processor = [[Processor alloc] init];
        df = [NSDateFormatter new];
        [df setDateFormat: @"HH:mm:ss"];
        currentSerialPort = nil;
        return self;
    }
    return self;
}    

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *path= @"~/Library/Logs/YUAA.log";
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm isWritableFileAtPath: path]) {
        [fm createFileAtPath: path contents: [NSData data] attributes: nil];
    }
    log = [[NSFileHandle fileHandleForUpdatingAtPath: path] retain];
    
    prefsViewController = [[PrefsPopupController alloc] initWithNibName:@"PrefsPopupController" bundle:nil];
    [prefsViewController view];
    prefs = [[Prefs alloc] init];
    prefsViewController.prefs = prefs;
    prefsViewController.delegate = self;
    [prefsViewController view];
    [FlightData instance];
    processor = [[Processor alloc] initWithPrefs: prefs];
    processor.delegate = self;
    NSLog(@"Prefs.port is %ld", prefs.port);
    // if (prefs.port)
    //    networkManager = [[NetworkManage alloc] initWithDelegate:self port: prefs.port];
    networkManager = [[NetworkManage alloc] initWithDelegate:self port: 1343];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConnections:) name:@"connectionUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebuildPortList) name:AMSerialPortListDidAddPortsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebuildPortList) name:AMSerialPortListDidRemovePortsNotification object:nil];
    popOver = [[NSPopover alloc] init];
    portList = prefsViewController.serialPortCell;
    akpsend = [[AKPSender alloc] initWithNibName:@"AKPSender" bundle:nil];
    popOver.behavior = NSPopoverBehaviorSemitransient;
    [self rebuildPortList];
    [self restartSerial: [portList selectedItem].title];
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
    if (currentSerialPort) {
        [currentSerialPort autorelease];
    }
    if ([port isEqualToString: @"Test Data"]) {
        currentSerialPort = nil;
        [NSThread detachNewThreadSelector:@selector(parseDemoFile) toTarget:self withObject:nil];
    } else {
        NSArray *a = [[AMSerialPortList sharedPortList] serialPorts];
        for (AMSerialPort *s in a) {
            //NSLog(@"S: %@",s);
            if ([[s description] rangeOfString:port].length != 0) {
                NSLog(@"Connecting to Arduino");
                currentSerialPort = [s retain];
                [currentSerialPort setDelegate:self];
                if (![currentSerialPort open]) {
                    NSLog(@"Error opening port.");
                    [currentSerialPort autorelease];
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

- (void) restartPort:(NSInteger)port {
    /*
    NSLog(@"Restaring port");
    [networkManager release];
    networkManager = [[NetworkManage alloc] initWithDelegate:self port: port];
     */
}

-(void)newConnection:(NetworkConnection *)conn {
    [conn writeData: [processor lastData]];
}

- (void)recieveData: (NSData *)d {
    NSLog(@"Got data!");
    [currentSerialPort writeData:d error:NULL];
}

- (void) defibrillator {
    [NSTimer scheduledTimerWithTimeInterval: 1 target: self selector:@selector(heartbeat) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] run];
}

- (void) heartbeat {
    [sourceList reloadData];
    if (lastUpdate)
        lastReceivedCell.title = [@"Last Update: " stringByAppendingString: [df stringFromDate: lastUpdate]];
}

- (void) scroller {
    if (!currentLog) {
        NSRange range;
        range = NSMakeRange ([[textForLog string] length], 0);
        [textForLog scrollRangeToVisible: range];
    } else {
        // [tableForLog performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [tableForLog scrollRowToVisible: [currentLogCopy count] -1 ];
    }
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
    [log writeData: d];
    NSAttributedString *attr = [[[NSAttributedString alloc] initWithString: str] autorelease];
    [[textForLog textStorage] performSelectorOnMainThread:@selector(appendAttributedString:) withObject:attr waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(scroller) withObject:nil waitUntilDone:NO];
    [lastUpdate autorelease];
    lastUpdate = [[NSDate date] retain];
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
    char buffer[1024];
    int i = 0;
    while (!feof(p) && !currentSerialPort) {
        c = fgetc(p);
        [processor updateData: c];
        [lastUpdate autorelease];
        lastUpdate = [[NSDate date] retain];
        buffer[i++] = c;
        if (i == 1023) {
            NSData *d = [[[NSData alloc] initWithBytes: buffer length:i] autorelease];
            NSString *str = [[[NSString alloc] initWithData: d encoding:NSASCIIStringEncoding] autorelease];
            [networkManager writeData: d];
            NSAttributedString *attr = [[[NSAttributedString alloc] initWithString: str] autorelease];
            [[textForLog textStorage] performSelectorOnMainThread:@selector(appendAttributedString:) withObject:attr waitUntilDone:YES];
            
            [self performSelectorOnMainThread:@selector(scroller) withObject:nil waitUntilDone:NO];
            i=0;
        }
    }
    fclose(p);
    NSData *d = [[[NSData alloc] initWithBytes: buffer length:i] autorelease];
    NSString *str = [[[NSString alloc] initWithData: d encoding:NSASCIIStringEncoding] autorelease];
    [networkManager writeData: d];
    NSAttributedString *attr = [[[NSAttributedString alloc] initWithString: str] autorelease];
    [[textForLog textStorage] performSelectorOnMainThread:@selector(appendAttributedString:) withObject:attr waitUntilDone:YES];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    FlightData *f = [FlightData instance];
    if (aTableView == tableForLog) {
        NSString *str = [currentLogCopy objectAtIndex: rowIndex];
        return str;
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
            NSDate *updatedDate = nil;
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
            
            if (updatedDate != nil) {
                return [NSString stringWithFormat: @"%@ (%@)", body, [df stringFromDate: updatedDate]];
            } else
                return body;
        }
    }
}
        
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == tableForLog) {
        NSLog(@"I'm looking");
        if (currentLog) {
            currentLogCopy = currentLog;
            NSLog(@"Current log count is %ld", [currentLogCopy count]);
            return [currentLogCopy count];
        }
        return 0;
    } else {
        FlightData *f = [FlightData instance];
        NSInteger a = [f.nameArray count] + 3;
        return a;
    }
}

- (void) serverStatus: (bool) status {
    serverUpCell.title = status ? @"Server Up: YES" : @"Server Up: NO";
}

- (IBAction)changeLogView:(NSPopUpButtonCell *)sender {
    NSString *logType = [[sourceCell selectedItem] title];
    currentLog = NULL;
    if ([logType isEqualToString: @"Serial Data"]) {
        [logText setHidden: NO];
        [logTable setHidden: YES];
    } else {
        FlightData *f = [FlightData instance];
        if ([logType isEqualToString: @"Parsing Log"]) currentLog = f.parseLogData;
        if ([logType isEqualToString: @"Network Log"]) currentLog = f.netLogData;
        [logText setHidden: YES];
        [logTable setHidden: NO];
        
    }
    [self scroller];
}


- (void)mapChosen: (int)type {
    // how do I do this?
}

- (void)mapTrackingChanged: (bool)type {
    // how do I do this?
}

-(void)receivedPicture {
    [self addedImage];
}

-(void)receivedLocation {
    // how do i do this?
}

- (IBAction)showPrefs:(NSButton *)sender {
    [popOver close];
    NSSize mysize;
    mysize.width = 242;
    mysize.height = 83;
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
    akpsend.serialPort = currentSerialPort;
    [akpsend showMe];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSInteger i = [sourceList selectedRow];
    if (i >= 0) {
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
                if ([[[FlightData instance] pictures] count] > 0) {
                    [self showPictures];
                    currentView = picView;
                } else {
                    [currentView setHidden: YES];
                    [sourceList deselectRow: 2];
                }
                break;
            default:
                [graphHostingView setHidden: NO];
                currentView = graphHostingView;
                FlightData *f = [FlightData instance];
                NSString *tag = [f.nameArray objectAtIndex: i - 3];
                StatPoint *tmp = [f.balloonStats objectForKey: tag];
                [graphLogic showDataSource: tmp named: tag];
        }
    }
}

- (void) addedImage {
    FlightData *f = [FlightData instance];
    if (imageIndex == [f.pictures count] -2) {
        imageIndex++;
    }
    [self updatePics];
}

- (void)showPictures {
    FlightData *f = [FlightData instance];
    imageIndex = (int)[f.pictures count] - 1;
    [picView setHidden: NO];
    [self updatePics];
}

- (IBAction)goLeft:(id)sender {
    FlightData *f = [FlightData instance];
    if ([f.pictures count] <= ++imageIndex) imageIndex = 0;
    [imageView setImage: [f.pictures objectAtIndex: imageIndex]];
    imageCounter.stringValue = [NSString stringWithFormat: @"%d of %d", imageIndex + 1, [f.pictures count]];
}
- (IBAction)goRight:(id)sender {
    FlightData *f = [FlightData instance];
    if (--imageIndex < 0) imageIndex = (int)[f.pictures count] - 1;
    [imageView setImage: [f.pictures objectAtIndex: imageIndex]];
    imageCounter.stringValue = [NSString stringWithFormat: @"%d of %d", imageIndex + 1, [f.pictures count]];
}

- (void) updatePics {
    if (!(picView.isHidden)) {
        [imageView setImageScaling: NSImageScaleAxesIndependently];
        
        FlightData *f = [FlightData instance];
        if ([f.pictures count] > imageIndex) {
            [imageView setImage: [f.pictures objectAtIndex: imageIndex]];
        }
        if ([f.pictures count] > 0)
            imageCounter.stringValue = [NSString stringWithFormat: @"%d of %d", imageIndex + 1, (int)[f.pictures count]];
    }
}


@end
