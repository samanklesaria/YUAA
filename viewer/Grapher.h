//
//  GraphView.h
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "StatPoint.h"

@interface Grapher : UIViewController <CPTPlotDataSource>
{
    CPTXYGraph *graph;
    CPTGraphHostingView *graphView;
    StatPoint *dataForPlot;
}

- (void)showDataSource: (StatPoint *)stat named:(NSString *)name;
- (NSMutableArray *)mkColorArray: (NSUInteger)length;

@property (nonatomic, retain) IBOutlet CPTGraphHostingView *graphView;


@end
