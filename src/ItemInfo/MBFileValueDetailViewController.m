//
//  MBFileValueDetailViewController.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 08.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBFileValueDetailViewController.h"
#import "MBItemValue.h"
#import "globals.h"
#import "MBFileItemValue.h"

@interface MBFileValueDetailViewController (privateAPI)

- (void)updateFileAttributes:(NSDictionary *)aDict;

@end

@implementation MBFileValueDetailViewController (privateAPI)

- (void)updateFileAttributes:(NSDictionary *)aDict {
	if([currentItemValue encryptionState] != EncryptedState) {
		id val = [aDict valueForKey:NSFileSize];
		// filesize
		if(val != nil) {
			[fileSizeLabel setObjectValue:val];
		} else {
			[fileSizeLabel setStringValue:MBLocaleStr(@"Unknown")];
		}
		
		// creationdate
		val = [aDict valueForKey:NSFileCreationDate];
		if(val != nil) {
			[fileCreationDateLabel setObjectValue:val];
		} else {
			[fileCreationDateLabel setStringValue:MBLocaleStr(@"Unknown")];
		}

		// mofifydate
		val = [aDict valueForKey:NSFileModificationDate];
		if(val != nil) {
			[fileModificationDateLabel setObjectValue:val];
		} else {
			[fileModificationDateLabel setStringValue:MBLocaleStr(@"Unknown")];
		}

		// ownername
		val = [aDict valueForKey:NSFileOwnerAccountName];
		if(val != nil) {
			[fileOwnerNameLabel setObjectValue:val];
		} else {
			[fileOwnerNameLabel setStringValue:MBLocaleStr(@"Unknown")];
		}

		// permission
		val = [aDict valueForKey:NSFilePosixPermissions];
		if(val != nil) {
			[filePosixPermissionsLabel setObjectValue:val];
		} else {
			[filePosixPermissionsLabel setStringValue:MBLocaleStr(@"Unknown")];
		}
	} else {
		[fileSizeLabel setStringValue:MBLocaleStr(@"Unknown")];
		[fileCreationDateLabel setStringValue:MBLocaleStr(@"Unknown")];
		[fileModificationDateLabel setStringValue:MBLocaleStr(@"Unknown")];
		[fileOwnerNameLabel setStringValue:MBLocaleStr(@"Unknown")];
		[filePosixPermissionsLabel setStringValue:MBLocaleStr(@"Unknown")];
	}
}

@end


@implementation MBFileValueDetailViewController

- (id)init {
	self = [super init];
	if(self) {
	}
	
	return self;
}

- (void)dealloc {
	// dealloc object
	[super dealloc];
}

- (void)awakeFromNib {
    // set progressindiocator to threaded
    [progressIndicator setUsesThreadedAnimation:YES];
}

- (void)displayInfo {
    
    [super displayInfo];
    
	MBFileItemValue *itemval = (MBFileItemValue *)currentItemValue;	
	if(itemval != nil) {
		if([itemval encryptionState] != EncryptedState) {
			// set filetype
			NSString *linkValue = [itemval linkValueAsString];
			if([linkValue length] > 0) {
				NSString *extension = [linkValue pathExtension];
				[filetypeLabel setStringValue:extension];
				
				// display icon for filetype
				NSImage *extIcon = [[NSWorkspace sharedWorkspace] iconForFileType:extension];
				[fileIconImageView setImage:extIcon];
			}
		} else {
			// filetype
			[filetypeLabel setStringValue:MBLocaleStr(@"Unknown")];
			
			// fileicon
			[fileIconImageView setImage:nil];
		}
		
		// display file attributes
		[self updateFileAttributes:[itemval fileAttributesDict]];
	}
}

#pragma mark - Actions

- (IBAction)acc_ExternButton:(id)sender {
    [super acc_ExternButton:sender];
	if(currentItemValue != nil) {
		// set filetype
		[filetypeLabel setStringValue:@""];
		[self updateFileAttributes:nil];
	}
}

- (IBAction)acc_InternButton:(id)sender {
    [super acc_InternButton:sender];
	if(currentItemValue != nil) {
		// set filetype
		[filetypeLabel setStringValue:@""];
		[self updateFileAttributes:nil];
	}
}

- (IBAction)acc_LinkValueInput:(id)sender {
    [super acc_LinkValueInput:sender];
	if(currentItemValue != nil) {
        NSString *value = [sender stringValue];
		if([value length] > 0) {
			NSString *extension = [value pathExtension];
			[filetypeLabel setStringValue:extension];
            
			// display icon for filetype
			NSImage *extIcon = [[NSWorkspace sharedWorkspace] iconForFileType:extension];
			[fileIconImageView setImage:extIcon];
			
			// display fileattributes
			[self updateFileAttributes:[(MBFileItemValue *)currentItemValue fileAttributesDict]];
		}
	}		
}

@end
