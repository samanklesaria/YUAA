//
//  GraphLogic.m
//  viewer
//
//  Created by Sam Anklesaria on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphLogic.h"

@implementation GraphLogic

- (id) initWithGraphView: (CPTGraphHostingView *)gv {
    self = [self init];
    if (self) {
        graphView = gv;
        // Create graph from theme
        graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
        CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
        [graph applyTheme:theme];
        graphView.hostedGraph = graph;
        
        graph.paddingLeft = 10.0;
        graph.paddingTop = 10.0;
        graph.paddingRight = 10.0;
        graph.paddingBottom = 10.0;
        
        CPTScatterPlot *boundLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
        CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
        lineStyle.miterLimit = 1.0f;
        lineStyle.lineWidth = 3.0f;
        lineStyle.lineColor = [CPTColor blueColor];
        boundLinePlot.dataLineStyle = lineStyle;
        boundLinePlot.identifier = [NSNumber numberWithInt: -1];
        boundLinePlot.dataSource = self;
        [graph addPlot:boundLinePlot];
        
        CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
        symbolLineStyle.lineColor = [CPTColor blackColor];
        CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        plotSymbol.fill = [CPTFill fillWithColor:[CPTColor blueColor]];
        plotSymbol.lineStyle = symbolLineStyle;
        plotSymbol.size = CGSizeMake(10.0, 10.0);
        boundLinePlot.plotSymbol = plotSymbol;
        
        CPTColor *areaColor1 = [CPTColor colorWithComponentRed:0.3 green:0.3 blue:1.0 alpha:0.8];
        CPTGradient *areaGradient1 = [CPTGradient gradientWithBeginningColor:areaColor1 endingColor:[CPTColor clearColor]];
        areaGradient1.angle = -90.0f;
        CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient1];
        boundLinePlot.areaFill = areaGradientFill;
        boundLinePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];
        
        NSMutableArray *colorArray = [self mkColorArray: 2];
        NSUInteger i;
        for (i = 0; i < [colorArray count]; i++) {
            CPTScatterPlot *myplot = [[[CPTScatterPlot alloc] init] autorelease];
            CPTMutableLineStyle *newstyle = [CPTMutableLineStyle lineStyle];
            newstyle.lineWidth = 0;
            myplot.dataLineStyle = newstyle;
            CPTMutableLineStyle *newSymbolStyle = [CPTMutableLineStyle lineStyle];
            newSymbolStyle.lineColor = [colorArray objectAtIndex: i];
            CPTPlotSymbol *newSymbol = [CPTPlotSymbol crossPlotSymbol];
            newSymbol.fill = [CPTFill fillWithColor:[CPTColor blueColor]];
            newSymbol.lineStyle = symbolLineStyle;
            newSymbol.size = CGSizeMake(10.0, 10.0);
            myplot.plotSymbol = newSymbol;
            myplot.identifier = [NSNumber numberWithInteger: i];
            myplot.dataSource = self;
            [graph addPlot: myplot];
        }
    }
    return self;
}

-(void)dealloc 
{
    [graphView release];
    [super dealloc];
}

-(void)showDataSource: (StatPoint *)stat named: (NSString *)name {
    if (dataForPlot)
        [dataForPlot autorelease];
    dataForPlot = stat;
    [dataForPlot retain];
    double minval = stat.minval;
    double maxval = stat.maxval;
    double yrange = maxval - minval;
    if (yrange == 0) yrange = 1;
    double xrange = [stat.points count];
    if (xrange == 0) xrange = 1;
    double xlength = [stat.points count] / 5;
    if (xlength == 0) xlength = 1;
    double ylength = (maxval - minval) / 10;
    if (ylength == 0) ylength = 1;
    double backupy = minval -0.1 * yrange;
    double backupx = -0.15 * xrange;
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(backupx) length:CPTDecimalFromDouble(1.15 * xrange)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(backupy) length:CPTDecimalFromDouble(1.15 * yrange)];
    
    // Axes
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPTDecimalFromDouble(xlength);
    x.minorTicksPerInterval = 2;
    
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPTDecimalFromDouble(ylength);
    y.minorTicksPerInterval = 5;
    
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(minval);
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0);
    
    NSArray *xexclusionRanges = [NSArray arrayWithObjects:
                                 [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(-1*backupx)], 
                                 [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(backupx) length:CPTDecimalFromFloat(minval)],
                                 nil];
	x.labelExclusionRanges = xexclusionRanges;
    [graph reloadData];
}

- (NSMutableArray *)mkColorArray: (NSUInteger)length {
    NSMutableArray *endArray = [[[NSMutableArray alloc] initWithCapacity:length] autorelease];
    NSArray *colors = [NSArray arrayWithObjects: [CPTColor greenColor], [CPTColor redColor], [CPTColor yellowColor], [CPTColor whiteColor], [CPTColor orangeColor], nil];
    NSUInteger i;
    for (i = 0; i < length; i++) {
        NSUInteger idx = i % [colors count];
        [endArray addObject:[colors objectAtIndex:idx]];
    }
    return endArray;
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    int idx = [(NSNumber *)plot.identifier intValue];
    switch (idx) {
        case -1: return [dataForPlot.points count];
        case 0: if (bayOpenData) return [bayOpenData count]; else return 0;
        case 1: if (bayCloseData) return [bayCloseData count]; else return 0;
    }
    return 0;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{
    int idx = [(NSNumber *)plot.identifier intValue];
    NSDictionary *p = nil;
    switch (idx) {
        case -1: {
            p = [dataForPlot.points objectAtIndex: index];
            break;
        }
        case 0: {
            p = [dataForPlot.bayNumToPoints objectForKey: [bayOpenData objectAtIndex: index]];
            break;
        }
        case 1: {
            p = [dataForPlot.bayNumToPoints objectForKey: [bayCloseData objectAtIndex: index]];
            break;
        }
    }
    return [p valueForKey: ((fieldEnum == 0) ? @"x" : @"y")];
}

@end