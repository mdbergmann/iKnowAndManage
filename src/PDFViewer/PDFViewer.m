//
//  PDFViewer.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 12.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>
#import <CocoLogger/CocoLogger.h>
#import "PDFViewer.h"


@implementation PDFViewer

- (id)init {
    self = [super init];
    if(self) {
        // load nib
        if(![NSBundle loadNibNamed:@"PDFViewer" owner:self]) {
            CocoLog(LEVEL_ERR, @"[PDFViewer -init] couldn't load nib!");
        }
    }
    
    return self;
}

- (id)initWithDelegate:(id)aDelegate {
    self = [self init];
    if(self) {
        [self setDelegate:aDelegate];
    }
    
    return self;
}

- (id)initWithDocument:(PDFDocument *)aDoc {
    self = [self init];
    if(self) {
        [self setDocument:aDoc];
    }
    
    return self;
}

- (void)awakeFromNib {
    isLoaded = YES;
    // if we have a document already, show it
    if(document) {
        [pdfView setDocument:document];
    }
}

- (void)dealloc {
    [self setDocument:nil];
    [super dealloc];
}

- (void)setView:(NSView *)aView {
    view = aView;
}

- (NSView *)view {
    return view;
}

- (void)setDelegate:(id)aDelegate {
    delegate = aDelegate;
}

- (id)delegate {
    return delegate;
}

- (void)setDocument:(PDFDocument *)aPDFDoc {
    [aPDFDoc retain];
    [document release];
    document = aPDFDoc;
    
    if(isLoaded) {
        [pdfView setDocument:document];
    }
}

- (PDFDocument *)document {
    return document;
}

@end
