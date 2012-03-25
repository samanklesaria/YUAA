//
//  main.m
//  yuaaServer
//
//  Created by Sam Anklesaria on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    signal(SIGPIPE, SIG_IGN);
    return NSApplicationMain(argc, (const char **)argv);
}
