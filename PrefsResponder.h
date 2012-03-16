//
//  PrefsResponder.h
//  viewer
//
//  Created by Sam Anklesaria on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PrefsResponder <NSObject>
- (void)mapChosen: (int)type;
- (void)mapTrackingChanged: (bool)type;
- (void)restartSerial: (NSString *)port;
@end