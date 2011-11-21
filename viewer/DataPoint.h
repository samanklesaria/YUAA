//
//  DataPoint.h
//  Babelon iPhone
//
//  Created by Stephen Hall on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DataPoint : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate; 
    NSString *creationDate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
-(id)initWithCoordinate:(CLLocationCoordinate2D)c;
- (NSString *)subtitle;
- (NSString *)title;

@end
