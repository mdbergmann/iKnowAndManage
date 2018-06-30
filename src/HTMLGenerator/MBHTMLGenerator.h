//
//  MBHTMLGenerator.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 28.12.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

// generating options
// default options
#define MBHTMLGenLinkItems				@"HTMLGenLinkItems"
#define MBHTMLGenExportData				@"HTMLGenExportData"
#define MBHTMLGenCopyLocalExternals		@"HTMLGenCopyLocalExternals"
#define MBHTMLGenCopyRemoteExternals	@"HTMLGenCopyRemoteExternals"
#define MBHTMLGenMakeLinkURLs			@"HTMLGenMakeLinkURLs"
// extended options for paths
#define MBHTMLGenExportPath				@"HTMLGenExportPath"
#define MBHTMLGenStyleSheetPath			@"HTMLGenStyleSheetPath"
#define MBHTMLGenTemplatesPath			@"HTMLGenTemplatesPath"
#define MBHTMLGenExportFilesPath		@"HTMLGenExportFilesPath"
#define MBHTMLGenExportImagesPath		@"HTMLGenExportImagesPath"
#define MBHTMLGenExportETextsPath		@"HTMLGenExportETextsPath"

// path proposals
#define ETextsRelPath	@"etexts"
#define FilesRelPath	@"files"
#define ImagesRelPath	@"images"
#define ThumbsRelPath	@"thumbnails"

@interface MBHTMLGenerator : NSObject  {
}

+ (NSString *)encodeHTMLEntitiesInString:(NSString *)source;

+ (MBHTMLGenerator *)defaultGenerator;
+ (NSDictionary *)defaultPrintOptions;
+ (NSDictionary *)defaultExportOptions;

- (NSString *)generateHTMLForItemList:(NSArray *)itemList toOutputDir:(NSString *)path options:(NSDictionary *)options;
- (NSString *)generateHTMLForItemValueList:(NSArray *)itemValueList toOutputDir:(NSString *)path options:(NSDictionary *)options;

@end
