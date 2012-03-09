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
        networkLog = [[NSMutableArray alloc] initWithCapacity: 128];
        return self;
    }
    return self;
}    

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    networkManager = [[NetworkManage alloc] initWithDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConnections:) name:@"connectionUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebuildPortList) name:AMSerialPortListDidAddPortsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebuildPortList) name:AMSerialPortListDidRemovePortsNotification object:nil];
    popOver = [[NSPopover alloc] init];
    prefs = [[PrefsPopupController alloc] initWithNibName:@"PrefsPopupController" bundle:nil];
    [prefs view];
    portList = prefs.serialPortCell;
    akpsend = [[AKPSender alloc] initWithNibName:@"AKPSender" bundle:nil];
    akpsend.networkLog = networkLog;
    picViewController = [[PicViewController alloc] initWithNibName:@"PicViewController" bundle:nil];
    [picViewController.view setHidden: YES];
    [specialHost addSubview: picViewController.view];
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

- (void) defibrillator {
    [NSTimer scheduledTimerWithTimeInterval: 1 target: self selector:@selector(heartbeat) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] run];
}

- (void) heartbeat {
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
    [networkLog addObject: @"Connections changed"];
    [connectionField setStringValue:[NSString stringWithFormat:@"Connections: %i",number]];
}

-(void)rebuildPortList {
    [portList removeAllItems];
    NSArray *a = [[AMSerialPortList sharedPortList] serialPorts];
    
    for (int i=0;i<[a count];i++) {
        [portList addItemWithTitle:[(AMSerialPort *)[a objectAtIndex:i] name]];
    }
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
        result *b = handle_char(*(d_unsafe+i), &pState);
        if (b) {
            NSLog(@"I got called");
            [processor updateData: b];
        }
    }
    [port readDataInBackground];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
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
            NSString *t = [processor.nameArray objectAtIndex:rowIndex -3];
            NSString *humanName = [processor.plistData objectForKey: t];
            NSString *result = (humanName != NULL) ? humanName : t;
            return result;
            
        } else {
            NSDate *updatedDate;
            NSString *body;
            if (rowIndex == 0) {
                updatedDate = processor.lastLocTime;
                if (processor.lat && processor.lon) {
                    body = [NSString stringWithFormat: @"Lat: %f, Lon: %f", processor.lat, processor.lon];
                } else body = @"";
            } else if (rowIndex == 1) {
                updatedDate = processor.lastIMUTime;
                body = [NSString stringWithFormat: @"Yaw: %.2f, Pitch: %.2f, Roll: %.2f",
                        processor.rotationZ, processor.rotationY, processor.rotationX];
            } else if (rowIndex == 2) {
                body = [NSString stringWithFormat: @"%d", [processor.pictures count]];
                updatedDate = processor.lastImageTime;
            } else {
                NSString *tag = [processor.nameArray objectAtIndex:rowIndex -3];
                StatPoint *stat = [processor.balloonStats objectForKey: tag];
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
        NSInteger a = [processor.nameArray count] + 3;
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
        if ([logType isEqualToString: @"POST Log"]) currentLog = processor.postLogData;
        if ([logType isEqualToString: @"Parsing Log"]) currentLog = processor.parseLogData;
        if ([logType isEqualToString: @"Network Log"]) currentLog = networkLog;
        
    }
}

- (IBAction)showPrefs:(NSButton *)sender {
    [popOver close];
    NSSize mysize;
    mysize.width = 243;
    mysize.height = 98;
    popOver.contentSize = mysize;
    popOver.contentViewController = prefs;
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
            [openGLView setHidden: NO];
            currentView = openGLView;
            break;
        case 2:
            [picViewController.view setHidden: NO];
            currentView = picViewController.view;
            break;
        default:
            [graphHostingView setHidden: NO];
            currentView = graphHostingView;
            // do more
    }
}

@end
