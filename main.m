//
//  main.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 18.03.05.
//  Copyright mabe 2005. All rights reserved.
//

#import "MBApplication.h"

int main(int argc, char *argv[])
{
	// start application
	//return NSApplicationMain(argc,  (const char **) argv);

	// create application
	MBApplication *app = (MBApplication *)[MBApplication sharedApplication];
 
	// init logging
	[app initLogging];	
	
	// load the main nib file
	[NSBundle loadNibNamed:@"MainMenu" owner:app];
	// run app - Main Eventloop
    [NSApp run];
	
	// deinit logging
	[app deinitLogging];

    return 0;
}
