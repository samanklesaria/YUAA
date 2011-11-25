//
//  GraphView.m
//  viewer
//
//  Created by Sam Anklesaria on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Grapher.h"
#import "SharedData.h"

@implementation Grapher
@synthesize graphView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // other stuff
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)viewDidLoad 
{
    [super viewDidLoad];
    
    // Create graph from theme
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
	CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [graph applyTheme:theme];
	CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.graphView;
    hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    hostingView.hostedGraph = graph;
	
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
        myplot.identifier = [NSNumber numberWithInt: i];
        myplot.dataSource = self;
        [graph addPlot: myplot];
    }
    [colorArray release];

}

-(void)dealloc 
{
    [graphView release];
    [super dealloc];
}

-(void)showDataSource: (StatPoint *)stat named: (NSString *)name {
    // you need to remove the other plots if we're reusing the graph object.
    // ensure the car updates and the balloon updates stay in the same frame
    // take backup into account
    [dataForPlot release];
    dataForPlot = stat;
    [dataForPlot retain];
    double minval = stat.minval;
    double maxval = stat.maxval;
    [self setTitle: name];
    double yrange = MAX(maxval - minval, 2);
    double xrange = MAX([stat.points count], 5);
    double xlength = MAX([stat.points count] / 5, 1);
    double ylength = MAX((maxval - minval) / 10, 1);
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
    
    [x.labelExclusionRanges release];
    NSArray *xexclusionRanges = [NSArray arrayWithObjects:
                                 [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(-1*backupx)], 
                                 [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(backupx) length:CPTDecimalFromFloat(minval)],
                                 nil];
	x.labelExclusionRanges = xexclusionRanges;
    [graph reloadData];
}

- (NSMutableArray *)mkColorArray: (NSUInteger)length {
    NSMutableArray *endArray = [[NSMutableArray alloc] initWithCapacity:length];
    NSArray *colors = [[NSArray alloc] initWithObjects: [CPTColor greenColor], [CPTColor redColor], [CPTColor yellowColor], [CPTColor whiteColor], [CPTColor orangeColor], nil];
    NSUInteger i;
    for (i = 0; i < length; i++) {
        NSUInteger idx = i % [colors count];
        [endArray addObject:[colors objectAtIndex:idx]];
    }
    return endArray;
}


- (void)viewDidUnload
{
    [self setGraphView:nil];
    [dataForPlot release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    int idx = [(NSNumber *)plot.identifier intValue];
    SharedData *s = [SharedData instance];
    switch (idx) {
        case -1: return [dataForPlot.points count];
        case 0: return [s.bayOpenData count]; 
        case 1: return [s.bayCloseData count];
    }
    return 0;
}

// check that there are multiple numbers being plotted
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{
    SharedData *s = [SharedData instance];
    int idx = [(NSNumber *)plot.identifier intValue];
    NSDictionary *p;
    switch (idx) {
        case -1: {
            p = [dataForPlot.points objectAtIndex: index];
            break;
        }
        case 0: {
            p = [dataForPlot.bayNumToPoints objectForKey: [s.bayOpenData objectAtIndex: index]];
            break;
        }
        case 1: {
            p = [dataForPlot.bayNumToPoints objectForKey: [s.bayCloseData objectAtIndex: index]];
            break;
        }
    }
    return [p valueForKey: ((fieldEnum == 0) ? @"x" : @"y")];
}

@end
