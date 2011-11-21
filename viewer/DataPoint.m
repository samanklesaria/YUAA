//
//  DataPoint.m
//  Babelon iPhone
//
//  Created by Stephen Hall on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataPoint.h"


@implementation DataPoint
@synthesize coordinate;

- (NSString *)subtitle{
	return [NSString stringWithFormat:@"Lon: %f Lat: %f",coordinate.longitude,coordinate.latitude];
}

- (NSString *)title {
    return creationDate;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)c {
	coordinate=c;
    creationDate = [[[NSDate date] description] retain];
	return self;
}

-(void)dealloc {
    [creationDate release];
    [super dealloc];
}

@end
