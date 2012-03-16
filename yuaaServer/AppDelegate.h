//
//  AppDelegate.h
//  yuaaServer
//
//  Created by Sam Anklesaria on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NetworkManage.h"
#import "AMSerialPort.h"
#import "AMSerialPortList.h"
#import "AMSerialPortAdditions.h"
#import "Parser.h"
#import "Processor.h"
#import "PrefsPopupController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "AKPSender.h"
#import <CorePlot/CorePlot.h>
#import "GraphLogic.h"
#import <WebKit/WebKit.h>
#import "ServerPicController.h"
#import "Prefs.h"
#import "FlightData.h"
#import "PrefsResponder.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, PrefsResponder, NSTableViewDelegate, NSTableViewDataSource> {
    NetworkManage *networkManager;
    AMSerialPort *currentSerialPort;
    IBOutlet NSPopUpButtonCell *sourceCell;
    NSPopover *popOver;
    PrefsPopupController *prefsViewController;
    AKPSender *akpsend;
    IBOutlet NSTableView *sourceList;
    IBOutlet NSView *logText;
    IBOutlet NSView *logTable;
    NSDateFormatter *df;
    IBOutlet NSTextView *textForLog;
    IBOutlet NSTableView *tableForLog;
    IBOutlet NSView *hostingView;
    IBOutlet NSTextFieldCell *serverUpCell;
    IBOutlet NSTextFieldCell *lastReceivedCell;
    IBOutlet NSTextFieldCell *connectionField;
    Processor *processor;
    IBOutlet WebView *webView;
    IBOutlet NSOpenGLView *openGLView;
    NSPopUpButtonCell *portList;
    NSArray *currentLog;
    NSDate *lastUpdate;
    IBOutlet CPTGraphHostingView *graphHostingView;
    GraphLogic *graphLogic;
    NSView *currentView;
    IBOutlet ServerPicController *serverPicController;
    IBOutlet NSView *specialHost;
    Prefs *prefs;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)changeLogView:(NSPopUpButtonCell *)sender;
- (IBAction)showPrefs:(NSButton *)sender;
- (IBAction)sendAKP:(id)sender;
-(void)rebuildPortList;
- (void)defibrillator;
- (void) parseDemoFile;
@end

