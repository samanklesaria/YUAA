//
//  GraphLogic.h
//  viewer
//
//  Created by Sam Anklesaria on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatPoint.h"
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#else
#import <CorePlot/CorePlot.h>
#import <Cocoa/Cocoa.h>
#endif

@interface GraphLogic : NSObject <CPTPlotDataSource> {
    CPTXYGraph *graph;
    CPTGraphHostingView *graphView;
    StatPoint *dataForPlot;
    NSArray *bayOpenData;
    NSArray *bayCloseData;
}

- (void)showDataSource: (StatPoint *)stat named:(NSString *)name;
- (NSMutableArray *)mkColorArray: (NSUInteger)length;
- (id) initWithGraphView: (CPTGraphHostingView *)gv;

@end
