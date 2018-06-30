// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <CocoLogger/CocoLogger.h>
#import <SifSqlite/SifSqlite.h>
#import "MBElementBaseController.h"
#import "MBElement.h"
#import "MBElementValue.h"
#import "MBDBDocumentEntry.h"
#import "MBDBSqliteDocumentEntry.h"
#import "MBDBSqlite.h"

@interface MBElementBaseController (privateAPI)

- (void)setSingleInstanceDocPool:(NSMutableDictionary *)aDict;
- (NSMutableDictionary *)createElementDictFromDbData:(NSArray *)dbData;
- (NSMutableDictionary *)createElementValueDictFromDbData:(NSArray *)dbData;

- (void)buildChildListRecursiveForElement:(MBElement *)parent withSourceList:(NSMutableArray *)tmpElemList;

@end

//------------------------------------------------------------------
//------------------ privateAPI implementation ---------------------
//------------------------------------------------------------------
@implementation MBElementBaseController (privateAPI)

- (void)setSingleInstanceDocPool:(NSMutableDictionary *)aDict {
    [aDict retain];
    [singleInstanceDocPool release];
    singleInstanceDocPool = aDict;
}

/**
 \brief the root element list is the child list of the root element
*/
- (NSArray *)rootElementList {
	return [rootElement children];
}

/**
\brief build the element tree recursive
 */
- (void)buildChildListRecursiveForElement:(MBElement *)parent withSourceList:(NSMutableArray *)tmpElemList {
	if(parent != nil) {
		if(tmpElemList != nil) {
			int i = 0;
			MBElement *elem = nil;
			NSString *pTreeinfo = nil;
			NSString *eTreeinfo = nil;
			//NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];	// availabe in 10.4
			NSMutableArray *removeArray = [NSMutableArray arrayWithCapacity:[tmpElemList count]];
			NSEnumerator *iter = [tmpElemList objectEnumerator];
			while((elem = [iter nextObject])) {
				// check, if child is a level deeper than parent
				if([elem treelevel] == ([parent treelevel] + 1)) {
					// yea
					// check, if treeinfo of parent is part of treeinfo of child
					pTreeinfo = [parent treeinfo];
					if(pTreeinfo == nil) {
						CocoLog(LEVEL_ERR, @"parent treeinfo is nil!");
					}
					eTreeinfo = [elem treeinfo];
					if(eTreeinfo == nil) {
						CocoLog(LEVEL_ERR, @"element treeinfo is nil!");
					}
					
					NSMutableArray *subStrings = [NSMutableArray arrayWithArray:[eTreeinfo componentsSeparatedByString:@"."]];
					// remove last entry
					[subStrings removeObjectAtIndex:0];
					[subStrings removeLastObject];
					NSString *subtreeinfo = [NSString stringWithFormat:@".%@", [subStrings componentsJoinedByString:@"."]];					
					if(subtreeinfo != nil) {
						if([pTreeinfo isEqualToString:subtreeinfo] == YES) {
							// we found a child, add it
							[parent addChild:elem];
							// add this to out indexes
							[removeArray addObject:elem];
							//[indexes addIndex:i];
						}
					} else {
						CocoLog(LEVEL_WARN, @"have a nil subtreeinfo!");
					}
				}
				
				// increment index
				i++;
			}
			
			// delete all indexes from array
			//[tmpElemList removeObjectsAtIndexes:indexes];
			[tmpElemList removeObjectsInArray:removeArray];
			
			if([tmpElemList count] > 0) {
				// go find child for every child we just found
				MBElement *child = nil;
				NSEnumerator *enumerator = [[parent children] objectEnumerator];
				while((child = [enumerator nextObject])) {
					// go down
					[self buildChildListRecursiveForElement:child withSourceList:tmpElemList];
				}
			} else {
				CocoLog(LEVEL_INFO, @"have no further elements im templist, ready!");
			}
		}
	} else {
		CocoLog(LEVEL_ERR, @"have nil parent!");
	}
}

/**
 Create dictionary of elements from db row data with elementid as key 
 @param dbData row data as NSDictionaries
 */
- (NSMutableDictionary *)createElementDictFromDbData:(NSArray *)dbData {
	NSMutableDictionary *ret = nil;
	
	if(dbData != nil) {
		ResultRow *row = nil;
		MBElement *elem = nil;
		ret = [NSMutableDictionary dictionaryWithCapacity:[dbData count]];
		NSEnumerator *enumerator = [dbData objectEnumerator];
		while((row = [enumerator nextObject])) {
			elem = [[[MBElement alloc] initWithReadingFromRow:row] autorelease];
			if(elem != nil) {
				// add it to dictionary
				[ret setObject:elem forKey:[NSNumber numberWithInt:[elem elementid]]];
			} else {
				CocoLog(LEVEL_WARN, @"got nil element from init!");
			}
		}
	} else {
		CocoLog(LEVEL_WARN, @"got nil dbData!");
	}
	
	return ret;
}

/**
 Create dictionary of elementvalue objects from db row data with valueid as key
 @param dbData row data as NSDictionaries
 */
- (NSMutableDictionary *)createElementValueDictFromDbData:(NSArray *)dbData {
	NSMutableDictionary *ret = nil;
	
	if(dbData != nil) {
		ResultRow *row = nil;
		MBElementValue *value = nil;
		ret = [NSMutableDictionary dictionaryWithCapacity:[dbData count]];
		NSEnumerator *enumerator = [dbData objectEnumerator];
		while((row = [enumerator nextObject])) {
			value = [[[MBElementValue alloc] initWithReadingFromRow:row] autorelease];
			if(value != nil) {
				// add it to dictionary
				[ret setObject:value forKey:[NSNumber numberWithInt:[value valueid]]];
			} else {
				CocoLog(LEVEL_WARN, @"got nil value from init!");
			}				
		}
	} else {
		CocoLog(LEVEL_WARN, @"got nil dbData!");
	}
	
	return ret;
}

- (NSMutableDictionary *)createDocumentEntryDictFromDbData:(NSArray *)dbData {
	NSMutableDictionary *ret = nil;
	
	if(dbData != nil) {
		ResultRow *row = nil;
		MBDBDocumentEntry *entry = nil;
		ret = [NSMutableDictionary dictionaryWithCapacity:[dbData count]];
		NSEnumerator *enumerator = [dbData objectEnumerator];
		while((row = [enumerator nextObject])) {
			entry = [[[MBDBSqliteDocumentEntry alloc] initWithReadingFromRow:row] autorelease];
			if(entry != nil) {
				// add it to dictionary
				[ret setObject:entry forKey:[NSNumber numberWithInt:[entry docId]]];
			} else {
				CocoLog(LEVEL_WARN, @"got nil value from init!");
			}				
		}
	} else {
		CocoLog(LEVEL_WARN, @"got nil dbData!");
	}
	
	return ret;    
}

@end

@implementation MBElementBaseController

static MBElementBaseController *sharedSingleton;

+ (MBElementBaseController *)standardController {
	if(sharedSingleton == nil) {
		sharedSingleton = [[MBElementBaseController alloc] init];
	}
	
	return sharedSingleton;
}

/**
 Init will create the element base, so this object is ready for use
 ElementBase with all elements and elementvalues has to be build using -buildElementBase
 After Init set a doc storage path.
 This ElementBaseController will use the shared db connection. If you want it to use something else you have to set it.
 */
- (id)init {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc MBElementBaseController!");
	} else {
		// set state
		state = InitState;

        // has to be set from outside
        [self setDbAccess:[MBDBSqlite sharedConnection]];
        
		// set root element nil
		[self setRootElement:nil];
		
		// set default memory footprint
		[self setMemoryFootprint:SmallMemFootprintType];
		
		// set default oversize export path
		[self setOversizeDataExportPath:@"/tmp"];
		[self setOversizeDataImportPath:@"/tmp"];
		
        // set default to si path storage
        [self setDocStorageType:DocStorageFS];
        
        // init single instance pool
        [self setSingleInstanceDocPool:[NSMutableDictionary dictionary]];

		// set state
		state = NormalState;
	}
	
	return self;
}

- (void)dealloc {
	// release root element
	[self setRootElement:nil];
	// release oversizeExportPath
	[self setOversizeDataExportPath:nil];
	[self setOversizeDataImportPath:nil];
    [self setDocStoragePath:nil];
    [self setSingleInstanceDocPool:nil];
    [self setDbAccess:nil];

	// dealloc object
	[super dealloc];
}

- (void)setDbAccess:(MBDBAccess *)aDbAccess {
    if(dbAccess != aDbAccess) {
        [aDbAccess retain];
        [dbAccess release];
        dbAccess = aDbAccess;        
    }
}

- (MBDBAccess *)dbAccess {
    return dbAccess;
}

/**
 \brief set memory footprint. there are three settings (small, medium, large)
*/
- (void)setMemoryFootprint:(MBMemFootprintType)aValue {
	memoryFootprint = aValue;
}

- (MBMemFootprintType)memoryFootprint {
	return memoryFootprint;
}

/**
 Single instance storage type
 */
- (DocStorageType)docStorageType  {
    return docStorageType;
}

- (void)setDocStorageType:(DocStorageType)value  {
    if (docStorageType != value)  {
        docStorageType = value;
    }
}

/**
 \brief single instance storage path setting
 */
- (NSString *)docStoragePath {
    return docStoragePath;
}

/**
 Sets doc storage path.
 Creates the directory if it does not exist.
 Throws exception on error.
 */
- (void)setDocStoragePath:(NSString *)value {
    if (docStoragePath != value) {
        [docStoragePath release];
        docStoragePath = [value copy];
        
        if(docStoragePath && [docStoragePath length] > 0) {
            // if this folder does not exist, create it
            NSFileManager *fm = [NSFileManager defaultManager];
            BOOL isDir = NO;
            if(([fm fileExistsAtPath:docStoragePath isDirectory:&isDir]) && (isDir == NO)) {
                NSString *msg = [NSString stringWithFormat:@"Doc storage path at %@ is not a directory!", docStoragePath];
                CocoLog(LEVEL_ERR, @"%@", msg);
                [[NSException exceptionWithName:@"DocStorageCreate" reason:msg userInfo:nil] raise];
            } else if([fm fileExistsAtPath:docStoragePath] == NO) {
                // create folder
                if([fm createDirectoryAtPath:docStoragePath attributes:nil] == NO) {
                    NSString *msg = [NSString stringWithFormat:@"Error on creating doc storage directory at path: %@", docStoragePath];
                    CocoLog(LEVEL_ERR, @"%@", msg);
                    [[NSException exceptionWithName:@"DocStorageCreate" reason:msg userInfo:nil] raise];
                }
            }            
        }
    }
}

/**
 \brief check dictionary for a document entry with the given hash
 if not available load and add to dictionary
 */
- (MBDBDocumentEntry *)documentEntryForHash:(NSString *)docHash {
    MBDBDocumentEntry *entry = nil;
    
    entry = [singleInstanceDocPool objectForKey:docHash];
    if(entry == nil) {
        // try to load, if not available in db, return nil
        // otherwise add to pool
        entry = [MBDBSqliteDocumentEntry dbDocumentEntryByQueryingForDocHash:docHash];
        if([entry docId] == -1) {
            entry = nil;
        } else {
            // add to pool
            [singleInstanceDocPool setObject:entry forKey:docHash];
        }
    }
    
    return entry;
}

- (MBDBDocumentEntry *)documentEntryForId:(int)Id {
    MBDBDocumentEntry *entry = nil;
    
    NSNumber *idNum = [NSNumber numberWithInt:Id];
    entry = [singleInstanceDocPool objectForKey:idNum];
    if(entry == nil) {
        // try to load, if not available in db, return nil
        // otherwise add to pool
        entry = [MBDBSqliteDocumentEntry dbDocumentEntryByQueryingForDocId:Id];
        if([entry docId] == -1) {
            entry = nil;
        } else {
            // add to pool
            [singleInstanceDocPool setObject:entry forKey:idNum];
        }
    }
    
    return entry;    
}


/**
 \brief all valuedata that is larger than DEFAULT_DATA_HOLD_SIZE id exported to that path
 if export path is nil, the data is not exported
*/
- (void)setOversizeDataExportPath:(NSString *)aPath {
	[aPath retain];
	[oversizeDataExportPath release];
	oversizeDataExportPath = aPath;
}

- (NSString *)oversizeDataExportPath {
	return oversizeDataExportPath;
}

- (void)setOversizeDataImportPath:(NSString *)aPath {
	[aPath retain];
	[oversizeDataImportPath release];
	oversizeDataImportPath = aPath;
}

- (NSString *)oversizeDataImportPath {
	return oversizeDataImportPath;
}

/**
 \brief set the root element, gets retained here, since it is not existant in any list
*/
- (void)setRootElement:(MBElement *)rootElem {
	[rootElem retain];
	[rootElement release];
	rootElement = rootElem;
}

- (MBElement *)rootElement {
	return rootElement;
}

- (void)addElementToRootList:(MBElement *)elem {
	if(elem != nil) {
		[rootElement addChild:elem];
	}
}

- (void)removeElementFromRootList:(MBElement *)elem {
	if(elem != nil) {
		[rootElement removeChild:elem];
	}
}

- (NSArray *)rootElementList {
	return [rootElement children];
}

/**
\brief build the element base tree
 */
- (void)buildElementBase {
	// get db connection
	MBDBAccess *dbCon = [self dbAccess];
	
    if(dbCon == nil) {
        [[NSException exceptionWithName:@"ErrorBuildElementBase" reason:@"DBAccess instance nil!" userInfo:nil] raise];
    }
    
	// set controller state
	state = LoadingState;
	
	BOOL complete = YES;
	if(complete) {
		// id first start?
		if([dbCon firstStart]) {
			// set controller state
			state = NormalState;

			// begin transaction
			[dbCon sendBeginTransaction];
			
			// create rootElement
			MBElement *root = [[[MBElement alloc] initWithDbAndIdentifier:ROOTELEMENT_ID] autorelease];
			// set parent
			[root setParent:nil];
			// set root Element
			[self setRootElement:root];

			// commit transaction
			[dbCon sendCommitTransaction];
		} else {
			// load complete element list from db
			NSArray *dbElemList = [dbCon listAllElements];
			
			// load all element values
			NSArray *dbElemValList = [dbCon listAllElementValuesWithoutData];
			NSArray *dbElemValDataList = [NSArray array];

			// create temp element array
			NSMutableDictionary *tmpElemDict = [self createElementDictFromDbData:dbElemList];
			NSMutableDictionary *tmpElemValList = [self createElementValueDictFromDbData:dbElemValList];			
			
			// check if we have to fetch data
			int byteSize = [elementController memoryFootprint];
            //byteSize = 0;
			if(byteSize > 0) {
				dbElemValDataList = [dbCon listElementValueDataLowerThanSize:byteSize];
				
				// loop over data at copy set in elementValues
				NSEnumerator *iter = [dbElemValDataList objectEnumerator];
				NSNumber *valId = nil;
				NSString *dataString = nil;
				ResultRow *aRow = nil;
				MBElementValue *elemVal = nil;
				while((aRow = [iter nextObject])) {
					valId = [NSNumber numberWithInt:[[[aRow findColumnForName:@"id"] value] intValue]];
					dataString = [[aRow findColumnForName:@"valuedata"] value];
					
					// get the right elementvalue
					elemVal = [tmpElemValList objectForKey:valId];
					// set the value
					[elemVal setMemoryValueDataWithConversation:dataString];
				}
			}
						
			// set elementvalues
			MBElementValue *elemval = nil;
			MBElement *elem = nil;
			NSEnumerator *iter = [tmpElemValList keyEnumerator];
			id key;
			while((key = [iter nextObject]))  {
				elemval = [tmpElemValList objectForKey:key];
				if(elemval == nil) {
					CocoLog(LEVEL_WARN, @"elemval for key is nil!");
				} else {
					elem = [tmpElemDict objectForKey:[NSNumber numberWithInt:[elemval elementid]]];
					if(elem == nil) {
						CocoLog(LEVEL_WARN, @"element for key is nil!");
					} else {
						// add elementvalue to element
						[elem addElementValue:elemval];
					}
				}
			}	
			
			// build element tree recursively		
			NSMutableArray *tmpElemList = [[[NSMutableArray alloc] initWithArray:[tmpElemDict allValues]] autorelease];
			// build root level elements
			int maxtreelevel = 0;
			// build index of elements that are to be removed
			//NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];	// available in 10.4
			NSMutableArray *removeArray = [NSMutableArray array];
			// first root element
			// reverse enumerator
			iter = [tmpElemList objectEnumerator];
			int i = 0;
			while((elem = [iter nextObject])) {
				// get max treelevel
				if([elem treelevel] > maxtreelevel) {
					maxtreelevel = [elem treelevel];
				}
				
				if([elem treelevel] == 1) {
					if([[elem identifier] isEqualToString:ROOTELEMENT_ID]) {
						// found root element
						[self setRootElement:elem];
					}
					// add this index to out indexset
					//[indexes addIndex:i];
					[removeArray addObject:elem];
				}

				// increment index
				i++;
			}
			// delete all indexes we found
			//[tmpElemList removeObjectsAtIndexes:indexes];
			[tmpElemList removeObjectsInArray:removeArray];

			// build tree recursive
			[self buildChildListRecursiveForElement:rootElement withSourceList:tmpElemList];
			
            // update instance counts here
            NSLog(@"Instance count update...");
            NSDictionary *docEntries = [self createDocumentEntryDictFromDbData:[dbCon listDocumentEntries]];
            iter = [docEntries objectEnumerator];
            MBDBDocumentEntry *entry = nil;
            while((entry = [iter nextObject])) {
                [entry setInstanceCount:[dbCon scannedInstanceCountForDocId:[entry docId]]];
            }
            NSLog(@"Instance count update...done");
            
			/*
			// set controller state
			state = NormalState;
			
			NSLog(@"TEST: creating some elements... !");
			// make some tests
			// create elements with elementvalues
			MBDBSqlite *dbCon = [MBDBSqlite sharedDbConnection];
			// start transaction
			[dbCon sendBeginTransaction];
			elem = nil;
			for(int i = 0;i < 10;i++)
			{
				elem = [[[MBElement alloc] initWithDb] autorelease];
				// add to root
				[rootElement addChild:elem];
				// create values for this element
				for(int j = 0;j < 10;j++)
				{
					MBElementValue *elemval = [[[MBElementValue alloc] initWithDb] autorelease];
					// add value to element
					[elem insertObject:elemval inElementValuesAtIndex:j];
				}
				
				// create some children
				for(int k = 0;k < 10;k++)
				{
					MBElement *child = [[[MBElement alloc] initWithDb] autorelease];
					// add to element
					[elem insertObject:child inChildrenAtIndex:k];

					// create values for child element
					for(int m = 0;m < 10;m++)
					{
						MBElementValue *elemval = [[[MBElementValue alloc] initWithDb] autorelease];
						// add value to element
						[child insertObject:elemval inElementValuesAtIndex:m];
					}
				}
			}
			NSLog(@"done creating!");
			// end transaction
			NSLog(@"start saving to db...");
			[dbCon sendCommitTransaction];
			NSLog(@"done saving!");
			
			// start transaction
			[dbCon sendBeginTransaction];
			NSLog(@"deleting all created...");
			[elem delete];
			[rootElement removeChild:elem];
			[dbCon sendCommitTransaction];
			NSLog(@"done deleting!");
			
			// kick application up
			//[NSApp terminate:nil];
			 */
		}
	} else {
        // load dynamic level for level
        [self loadChildElementsForElement:nil withIdentifier:nil];
	}
	
	// set controller state
	state = NormalState;
}

/**
 Load the childlist and attributes for the children
*/
- (void)loadChildElementsForElement:(MBElement *)aElement withIdentifier:(NSString *)aIdentifier {
	// get db connection
	MBDBAccess *dbCon = [self dbAccess];
	
    if(!dbCon) {
        [[NSException exceptionWithName:@"LoadChildrenForElement" reason:@"DBAccess instance nil!" userInfo:nil] raise];    
    }
    
	// load the complete level for this element
	NSArray *dbElemList = nil;
	if(aElement == nil) {
		// load root
		dbElemList = [dbCon listChildElementsById:-1 withIdentifier:aIdentifier];
	} else {
		// load complete element list from db
		dbElemList = [dbCon listChildElementsById:[aElement elementid] withIdentifier:aIdentifier];
	}
	NSMutableDictionary *tmpElemDict = [self createElementDictFromDbData:dbElemList];

	// load elementvalues of the complete level
	NSArray *dbElementValueList = nil;
	if(aElement == nil) {
		// load all root elements with 
		dbElementValueList = [dbCon listAllLevelElementValuesByElementId:-1 
												   withElementIdentifier:aIdentifier
											  withElementValueIdentifier:nil];
	} else {
		dbElementValueList = [dbCon listAllLevelElementValuesByElementId:[aElement elementid] 
												   withElementIdentifier:aIdentifier 
											  withElementValueIdentifier:nil];
	}
	NSMutableDictionary *tmpElementValueDict = [self createElementValueDictFromDbData:dbElementValueList];

	// connect elementvalues to elements
	MBElementValue *elemval = nil;
	MBElement *elem = nil;
	NSEnumerator *iter = [tmpElementValueDict keyEnumerator];
	id key;
	while((key = [iter nextObject]))  {
		elemval = [tmpElementValueDict valueForKey:key];
		if(elemval == nil) {
			CocoLog(LEVEL_WARN, @"elemval for key is nil!");
		} else {
			elem = [tmpElemDict objectForKey:[NSNumber numberWithInt:[elemval elementid]]];
			if(elem == nil) {
				CocoLog(LEVEL_WARN, @"element for key is nil!");
			} else {
				// add elementvalue to element
				[elem addElementValue:elemval];
			}
		}
	}		
	
	// connect elements to parents
	iter = [tmpElemDict objectEnumerator];
	elem = nil;
	while((elem = [iter nextObject])) {
		// if aElement is nil, set rootElement as parent
		if(aElement == nil) {
			aElement = rootElement;
		}
		
		[aElement addChild:elem];
	}	
}

// controller state
- (void)setState:(int)aState {
	state = aState;
}

- (int)state {
	return state;
}

/**
 \brief deletes all items that are in the array
*/
- (void)removeObjects:(NSArray *)objects {
	if([objects count] > 0) {
		NSEnumerator *iter = [objects objectEnumerator];
		id item = nil;
		while((item = [iter nextObject])) {
			if([item isKindOfClass:[MBElement class]]) {
				MBElement *elem = item;
				
				// delete the item
				[elem delete];
				
				// chec, if this is a root element
				MBElement *parent = [elem parent];
				// get the parent and tell him ti remove its child
				[parent removeChild:elem];
			} else {
				MBElement *elem = [item element];
				// is elementValue
				// delete the elementValue
				[item delete];
				
				// now get the element and tel the element to delete its elementValue
				[elem removeElementValue:item];
			}
		}
	}
}

/**
\brief remove the given item
 it can be element or elementValue. 
 */
- (void)removeObject:(id)aObject {
	if(aObject != nil) {
		if([aObject isKindOfClass:[MBElement class]]) {
			MBElement *elem = aObject;
			
			// delete the item
			[elem delete];
			
			// chec, if this is a root element
			MBElement *parent = [elem parent];
			// get the parent and tell him ti remove its child
			[parent removeChild:elem];
		} else {
			MBElement *elem = [aObject element];
			// is elementValue
			// delete the elementValue
			[aObject delete];
			
			// now get the element and tel the element to delete its elementValue
			[elem removeElementValue:aObject];
		}
	} else {
		CocoLog(LEVEL_WARN, @"item is nil!");
	}
}

- (void)addElementValue:(MBElementValue *)elemval 
			  toElement:(MBElement *)elem 
	withConnectingValue:(BOOL)dbConnected
			   isMoveOp:(BOOL)moveOp 
		  isTransaction:(BOOL)transaction {
	if(elemval != nil) {
		if(elem != nil) {
			// begin db transaction
			if(transaction) {
				[dbAccess sendBeginTransaction];
			}

			// should the child be connected?
			if(dbConnected) {
				[elemval setIsDbConnected:YES writeIndex:NO];
			}
			
			// we have to hold a reference
			[elemval retain];
			
			// is this a move operation?
			if(moveOp) {
				// remove the elementValue from the old element
				if([elemval element] != nil) {
					[[elemval element] removeElementValue:elemval];
				} else {
					// if the elementValue has no element this is an error
					CocoLog(LEVEL_ERR, @"elementValue has no element!");
				}
			}				

			// add elementValue
			[elem addElementValue:elemval];
			
			// release elementValue
			[elemval release];

			// commit db transaction
			if(transaction) {
				[dbAccess sendCommitTransaction];
			}			
		} else {
			CocoLog(LEVEL_WARN, @"elem is nil!");
		}
	} else {
		CocoLog(LEVEL_WARN, @"elemval is nil!");
	}	
}

/**
 Moves an element to be a child of the given element
 */
- (void)addElement:(MBElement *)child 
		 toElement:(MBElement *)parent 
withConnectingChild:(BOOL)dbConnected 
		  isMoveOp:(BOOL)moveOp 
	 isTransaction:(BOOL)transaction {
	if(child != nil) {
		// begin db transaction
		if(transaction) {
			[dbAccess sendBeginTransaction];
		}
		
		// should the child be connected?
		if(dbConnected) {
			[child setIsDbConnected:YES];
		}
				
		// hold a reference to the child
		[child retain];

		// is this a move operation?
		if(moveOp) {
			[[child parent] removeChild:child];
		}
		
		// if parent is nil, set rootElement as parent
		if(parent == nil) {
			parent = rootElement;
		}
		// add element
		[parent addChild:child];
		
		// release child
		[child release];
		
		// commit db transaction
		if(transaction) {
			[dbAccess sendCommitTransaction];
		}		
	} else {
		CocoLog(LEVEL_WARN, @"child is nil!");
	}
}

/**
 Add mixed items, element or elementValue to an element
 @param[in] moveOp is this a move operation?
*/
- (void)addItems:(NSArray *)items 
	   toElement:(MBElement *)aElem 
withConnectingChild:(BOOL)dbConnected
		isMoveOp:(BOOL)moveOp 
   isTransaction:(BOOL)transaction {

	if([items count] > 0) {
		// begin db transaction
		if(transaction) {
			[dbAccess sendBeginTransaction];
		}

		NSEnumerator *iter = [items objectEnumerator];
		id item = nil;
		while((item = [iter nextObject])) {
			// should the child be connected?
			if(dbConnected) {
				[item setIsDbConnected:YES];
			}
			
			// check class
			if([item isKindOfClass:[MBElement class]]) {
				MBElement *elem = item;

				// hold a reference to the child
				[elem retain];
				
				// is this a move operation?
				if(moveOp) {
					[[elem parent] removeChild:elem];
				}				
				
				// if aElem is nil, set rootElement as parent
				if(aElem == nil) {
					aElem = rootElement;
				}
				// add item to element
				[aElem addChild:elem];
					
				// release the reference
				[elem release];
			} else if([item isKindOfClass:[MBElementValue class]]) {
				MBElementValue *elemval = item;
				
				if(aElem != nil) {
					// we have to hold a reference
					[elemval retain];

					// is this a move operation?
					if(moveOp) {
						// remove the elementValue from the old element
						if([elemval element] != nil) {
							[[elemval element] removeElementValue:elemval];
						} else {
							// if the elementValue has no element this is an error
							CocoLog(LEVEL_ERR, @"elementValue has no element!");
						}
					}				
					
					// add to element
					[aElem addElementValue:elemval];
					
					// release the elementValue
					[elemval release];
				} else {
					CocoLog(LEVEL_WARN, @"elementValues cannot added to a nil element!");
				}
			} else {
				CocoLog(LEVEL_WARN, @"unrecognized class in items array!");
			}
		}
		
		// commit db transaction
		if(transaction) {
			[dbAccess sendCommitTransaction];
		}		
	} else {
		CocoLog(LEVEL_WARN, @"items array is empty!");
	}
}

@end

