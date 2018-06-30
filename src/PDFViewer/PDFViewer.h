//
//  PDFViewer.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 12.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PDFView;
@class PDFDocument;

@interface PDFViewer : NSObject {
    IBOutlet NSView *view;
    IBOutlet id delegate;
    IBOutlet PDFView *pdfView;
    
    /** the pdf document to be shown */
    PDFDocument *document;
    
    /** view loaded? */
    BOOL isLoaded;
}

- (id)initWithDelegate:(id)aDelegate;
- (id)initWithDocument:(PDFDocument *)aDoc;

- (void)setView:(NSView *)aView;
- (NSView *)view;

- (void)setDelegate:(id)aDelegate;
- (id)delegate;

- (void)setDocument:(PDFDocument *)aPDFDoc;
- (PDFDocument *)document;

@end
