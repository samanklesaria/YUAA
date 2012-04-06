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
#import "Prefs.h"
#import "FlightData.h"
#import "PrefsResponder.h"
#import <Quartz/Quartz.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, PrefsResponder, NSTableViewDelegate, NSTableViewDataSource, NetworkManageDelegate> {
    NetworkManage *networkManager;
    AMSerialPort *currentSerialPort;
    IBOutlet NSPopUpButtonCell *sourceCell;
    NSPopover *popOver;
    NSFileHandle *log;
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
    IBOutlet NSView *picView;
    NSPopUpButtonCell *portList;
    NSArray *currentLog;
    NSArray *currentLogCopy;
    NSDate *lastUpdate;
    IBOutlet CPTGraphHostingView *graphHostingView;
    GraphLogic *graphLogic;
    IBOutlet NSImageView *imageView;
    NSView *currentView;
    IBOutlet NSView *specialHost;
    IBOutlet NSTextField *imageCounter;
    Prefs *prefs;
    int imageIndex;
}
- (IBAction)goLeft:(id)sender;
- (IBAction)goRight:(id)sender;
- (IBAction)changeLogView:(NSPopUpButtonCell *)sender;
- (IBAction)showPrefs:(NSButton *)sender;
- (IBAction)sendAKP:(id)sender;

@property (assign) IBOutlet NSWindow *window;

- (void) scroller;
-(void) showPictures;
-(void) addedImage;
- (void) updatePics;
-(void)rebuildPortList;
- (void)defibrillator;
- (void) parseDemoFile;
@end

