// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBElementBaseController.h"

@interface MBElementBaseController (privateAPI)

- (void)setControllerState:(int)aState;

- (void)createElementBase;

- (NSMutableDictionary *)createElementDictFromDbData:(NSArray *)dbData;
- (NSMutableDictionary *)elementDict;
- (void)setElementDict:(NSMutableDictionary *)aDict;

- (NSMutableDictionary *)createAttributeDictFromDbData:(NSArray *)dbData;
- (NSMutableDictionary *)attributeDict;
- (void)setAttributeDict:(NSMutableDictionary *)aDict;

- (NSMutableDictionary *)createValueDictFromDbData:(NSArray *)dbData;
- (NSMutableDictionary *)valueDict;
- (void)setValueDict:(NSMutableDictionary *)aDict;

- (void)setRootElementList:(NSMutableArray *)aList;

- (void)buildChildListRecursiveForElement:(MBElement *)parent withSourceList:(NSMutableArray *)tmpElemList;

// element navigation array
- (void)setElementNavigationBuffer:(NSMutableArray *)aArray;
- (NSMutableArray *)elementNavigationBuffer;

// sorting
- (void)sortChildrenOfElement:(MBElement *)parent usingSortDescriptors:(NSArray *)newDescriptors;

@end

@implementation MBElementBaseController

/**
 \brief our shared instance singleton
*/
+ (MBElementBaseController *)standardController
{
	static MBElementBaseController *sharedSingleton;

	if(sharedSingleton == nil)
	{
		sharedSingleton = [[MBElementBaseController alloc] init];
	}
	
	return sharedSingleton;
}

/**
 \brief init will create the element base, so this object is ready for use
 */
- (id)init
{
	self = [super init];
	if(self == nil)
	{
		MBLOG(MBLOG_ERR,@"cannot alloc MBElementBaseController!");		
	}
	else
	{
		// set controller state init
		[self setControllerState:InitState];
		
		// init our element array
		rootElementList = [[NSMutableArray alloc] init];
		
		// init navigation array
		[self setElementNavigationBuffer:[NSMutableArray array]];
		elementNavigationBufferIndex = -1;
		
		// init dicts
		[self setElementDict:[NSMutableDictionary dictionary]];
		[self setAttributeDict:[NSMutableDictionary dictionary]];		
		
		// init current elements
		[self setCurrentElementSelection:[NSArray array]];
		// init current attribute
		[self setCurrentAttributeSelection:[NSArray array]];
		
		// create element base
		[self createElementBase];
		
		// init the undo manager
		undoManager = [[NSUndoManager alloc] init];
		[undoManager setLevelsOfUndo:10];
		//[undoManager setGroupsByEvent:NO];
		
		// set controller state normal
		[self setControllerState:NormalState];
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc
{
	// get rid of undo manager
	[self setUndoManager:nil];

	// get rid of undoElement
	[self setUndoElement:nil];
	
	// release out element array
	[self setRootElementList:nil];
	// init dicts
	[self setElementDict:nil];
	[self setAttributeDict:nil];		

	// lists
	[self setCurrentElementSelection:nil];
	
	[self setElementNavigationBuffer:nil];
	
	// dealloc object
	[super dealloc];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
/**
\brief gets called if the nib file has been loaded. all gfx objacts are available now.
 */
- (void)awakeFromNib
{
	if(self != nil)
	{
		/*
		// register notification
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(selectedElementChanged:)
													 name:MBSelectedElementChangedNotification object:nil];

		// register notification
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(selectedAttributeChanged:)
													 name:MBSelectedAttributeChangedNotification object:nil];
		 */
	}	
}


//--------------------------------------------------------------------
//----------- own methods ---------------------------------------
//--------------------------------------------------------------------
- (int)controllerState
{
	return controllerState;
}

- (void)setUndoElement:(MBElement *)aElement
{
	[aElement retain];
	[undoElement release];
	undoElement = aElement;
}

- (MBElement *)undoElement
{
	return undoElement;
}

- (void)setTrashcanElement:(MBElement *)aElement
{
	trashcanElement = aElement;
}

- (MBElement *)trashcanElement
{
	return trashcanElement;
}

/**
 \brief get the undo manager
*/
- (NSUndoManager *)undoManager
{
	return undoManager;
}

/**
 \brief set the undo manager
*/
- (void)setUndoManager:(NSUndoManager *)aManager
{
	if(aManager != undoManager)
	{
		[aManager retain];
		[undoManager release];
		undoManager = aManager;
	}
}

/**
 \brief select the last visited element in visited array.
 @returns: number of elements that are possible to go backward
*/
- (int)elementNavigationBackward
{
	/*
	if((elementNavigationBufferIndex > 0) && (elementNavigationBufferIndex < [elementNavigationBuffer count]))
	{
		// decrement index and grab the element with the index
		--elementNavigationBufferIndex;
		MBElement *elem = [elementNavigationBuffer objectAtIndex:elementNavigationBufferIndex];
		if(elem == nil)
		{
			MBLOG(MBLOG_WARN,@"[MBElementBaseController -elementNavigationBackward]: element is nil!"); 
		}
		else
		{
			// send notification that element navigatioln controls should select another element
			MBSendNotifyElementSelectionShouldChange(elem);
		}
	}
	 */

	return elementNavigationBufferIndex;
}

/**
\brief select the next element in visited elements array in forward direction
 @returns: number of elements that are possible to go forward
 */
- (int)elementNavigationForward
{
	/*
	if((elementNavigationBufferIndex > 0) && (elementNavigationBufferIndex < [elementNavigationBuffer count]))
	{
		// increment index and grab the element with the index
		elementNavigationBufferIndex++;
		MBElement *elem = [elementNavigationBuffer objectAtIndex:elementNavigationBufferIndex];
		if(elem == nil)
		{
			MBLOG(MBLOG_WARN,@"[MBElementBaseController -elementNavigationBackward]: element is nil!"); 
		}
		else
		{
			// send notification that element navigatioln controls should select another element
			MBSendNotifyElementSelectionShouldChange(elem);
		}
	}
	*/
	
	return ([elementNavigationBuffer count] - elementNavigationBufferIndex);
}

/**
\brief sets the current selected (in outlineview) elements. Can be 0 or more elements. we support multiple selection.
*/
- (void)setCurrentElementSelection:(NSMutableArray *)aSelection
{
	[aSelection retain];
	[currentElementSelection release];
	currentElementSelection = aSelection;
	
	// send notification of changed selected element
	// mainly, this is for all views that display information of the selected element
	MBSendNotifyElementSelectionChanged(currentElementSelection);
}

/**
\brief returns the current selection of elements
*/
- (NSMutableArray *)currentElementSelection
{
	return currentElementSelection;
}

/**
\brief sets the current selected (in tableview) attribute. Only a reference is saved here.
 @param aAttribute the attribute that has been selected
 */
- (void)setCurrentAttributeSelection:(NSMutableArray *)aSelection
{
	[aSelection retain];
	[currentAttributeSelection release];
	currentAttributeSelection = aSelection;
	
	// send notification of changed selected element
	MBSendNotifyAttributeSelectionChanged(currentAttributeSelection);
}

/**
\brief returns a reference of the current selected attribute
 
 @returns reference of current selected attribute
 */
- (NSMutableArray *)currentAttributeSelection
{
	return currentAttributeSelection;
}

/**
 \brief tries to figure out the current selection, which is either attribute or element selection
*/
- (NSMutableArray *)currentSelection
{
	if([currentAttributeSelection count] > 0)
	{
		return currentAttributeSelection;
	}
	else
	{
		return currentElementSelection;
	}	
}

/**
\brief returns the current element list
 @returns NSArray with all elements
*/
- (NSMutableArray *)rootElementList
{
	return rootElementList;
}

/**
\brief get the all attributes of the given element
 */
- (NSMutableArray *)attribListOfElement:(MBElement *)aElement
{
	NSMutableArray *ret = nil;
	
	if(aElement != nil)
	{
		ret = [aElement attributeList];
	}
	
	return ret;
}

/**
\brief add new element. this is just a wrapper for -addNewElementByType:
 */
- (void)addNewElement
{
	[self addNewElementByType:NormalElementType];
}

/**
\brief adds an element to the root level of the element array
 this method opens a new db transaction
 @param elem the MBElement to be added
 */
- (void)addRootElement:(MBElement *)elem
{	
	if(elem != nil)
	{
		[self addElement:elem toElement:nil isMoveOp:NO withTransaction:YES];
	}
	else
	{
		MBLOG(MBLOG_WARN,@"[MBElementBaseController -addRootElement:]: element to add is nil!");
	}
}

/**
\brief delete the elements that currently are selected
 
 if no element is selected, do nothing
 */
- (void)delCurrentElementSelection
{
	[self removeItems:currentElementSelection];
	
	// send notification
	MBSendNotifyElementTreeChanged(nil);
	// clean selection
	[self setCurrentElementSelection:[NSArray array]];
}

- (void)delCurrentAttributeSelection
{
	// remove attribute
	[self removeItems:currentAttributeSelection];
	
	// send notification
	MBSendNotifyAttributeListChanged(nil);
	// clean selection
	[self setCurrentAttributeSelection:[NSArray array]];	
}

/**
 \brief delete the current selection. either this is an element or an attribute
*/
- (void)delCurrentSelection
{
	// first check, if there is a selection
	// if it is not, nothing can be deleted
	if(([currentAttributeSelection count] == 0) && ([currentElementSelection count] == 0))
	{
		// no element can be selected
		// bring up alert sheet
		NSWindow *mainWindow = [GlobalWindows mainAppWindow];
		if(mainWindow != nil)
		{
			NSBeginAlertSheet(MBLocaleStr(@"Warning"),
							  MBLocaleStr(@"OK"),nil,nil,
							  mainWindow,nil,nil,nil,nil,
							  MBLocaleStr(@"CannotDelCurrentSelection"));
		}
		else
		{
			MBLOG(MBLOG_WARN,@"[MBElementBaseController -delCurrentSelection:] mainWindow not available, cannot open sheet!");
		}
	}
	else
	{
		if([currentAttributeSelection count] > 0)
		{
			[self delCurrentAttributeSelection];
		}
		else
		{
			[self delCurrentElementSelection];
		}
	}
}

//------------------------------------------------------------------
// registering and deregistering elements and attribute
//------------------------------------------------------------------
/**
 \brief every new element has to register here
*/
- (void)registerNewElement:(MBElement *)aElem withId:(int)aId
{
	NSString *idAsString = [[NSNumber numberWithInt:aId] stringValue];
	
	if([elementDict valueForKey:idAsString] == nil)
	{
		[elementDict setObject:aElem forKey:idAsString];
	}
	else
	{
		MBLOG(MBLOG_ERR,@"[MBElementBaseController -registerNewElement:withId:] element already exists!");
	}
}

/**
\brief every new attribute has to register here
 */
- (void)registerNewAttribute:(MBAttribute *)aAttrib withId:(int)aId
{
	NSString *idAsString = [[NSNumber numberWithInt:aId] stringValue];
	
	if([attributeDict valueForKey:idAsString] == nil)
	{
		[attributeDict setObject:aAttrib forKey:idAsString];
	}
	else
	{
		MBLOG(MBLOG_ERR,@"[MBElementBaseController -registerNewAttribute:withId:] attribute already exists!");
	}	
}

/**
\brief on deleting an element, every element and children have to deregister here
 */
- (void)deregisterElementWithId:(int)aId
{
	NSString *idAsString = [[NSNumber numberWithInt:aId] stringValue];

	[elementDict removeObjectForKey:idAsString];
}

/**
\brief on deleting an attribute or element, every attribute to deregister here
 */
- (void)deregisterAttributeWithId:(int)aId
{
	NSString *idAsString = [[NSNumber numberWithInt:aId] stringValue];
	
	[attributeDict removeObjectForKey:idAsString];
}

/**
\brief get an element instance for an id
 */
- (MBElement *)elementForElementId:(int)aId
{
	NSString *idAsString = [[NSNumber numberWithInt:aId] stringValue];

	return [elementDict valueForKey:idAsString];
}

/**
\brief get an attribute instance for an id
 */
- (MBAttribute *)attributeForAttributeId:(int)aId
{
	NSString *idAsString = [[NSNumber numberWithInt:aId] stringValue];
	
	return [attributeDict valueForKey:idAsString];
}

/**
 \brief this will sort the element data to the only sort key = sortorder
*/
- (void)sortElementData
{
	// make sort descriptor
	NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"sortorder" ascending:YES];
	NSArray *mySDs = [NSArray arrayWithObject:sd];
	
	// sort root list
	[rootElementList sortUsingDescriptors:mySDs];

	// we must sort recursive
	NSEnumerator *iter = [rootElementList objectEnumerator];
	MBElement *elem = nil;
	while((elem = [iter nextObject]))
	{
		[self sortChildrenOfElement:elem usingSortDescriptors:mySDs];
	}
}

@end

//------------------------------------------------------------------
//------------------ privateAPI implementation ---------------------
//------------------------------------------------------------------
@implementation MBElementBaseController (privateAPI)

/**
 \brief set the controller state
*/
- (void)setControllerState:(int)aState
{
	controllerState = aState;
}

/**
\brief build the element base tree
 */
- (void)createElementBase
{
	// get db connection
	MBDBSqlite *dbCon = [MBDBSqlite dbConnection];
	
	// load complete element list from db
	NSArray *dbElemList = [dbCon listAllElements];
	NSArray *dbAttribList = [dbCon listAllAttributes];
	NSArray *dbValueList = [dbCon listAllBasicValues];
	
	// create temp element array
	NSMutableDictionary *tmpElemDict = [self createElementDictFromDbData:dbElemList];
	NSMutableDictionary *tmpAttribDict = [self createAttributeDictFromDbData:dbAttribList];
	NSMutableDictionary *tmpValueDict = [self createValueDictFromDbData:dbValueList];
	
	// we want to hold an instance of these dicts
	[self setElementDict:tmpElemDict];
	[self setAttributeDict:tmpAttribDict];
	
	BOOL error = NO;
	
	// check for availability of dicts. none of then must be nil
	if(tmpElemDict == nil)
	{
		MBLOG(MBLOG_ERR,@"[MBElementBaseController -createElementBase:] temp element dictionary is nil!");	
		
		error = YES;
	}
	if(tmpValueDict == nil)
	{
		MBLOG(MBLOG_ERR,@"[MBElementBaseController -createElementBase:] temp value dictionary is nil!");
		
		error = YES;
	}
	if(tmpAttribDict == nil)
	{
		MBLOG(MBLOG_ERR,@"[MBElementBaseController -createElementBase:] temp attribute dictionary is nil!");
		
		error = YES;
	}
	
	// check, if we may proceed
	if(error == NO)
	{
		// set attribute with value
		MBValue *value = nil;
		MBAttribute *attrib = nil;
		MBElement *elem = nil;
		NSEnumerator *valueKeys = [tmpValueDict keyEnumerator];
		id valueKey;
		while ((valueKey = [valueKeys nextObject])) 
		{
			value = [tmpValueDict valueForKey:valueKey];
			if(value == nil)
			{
				MBLOG(MBLOG_WARN,@"[MBElementBaseController -createElementBase:] value for key is nil!");
			}
			else
			{
				attrib = [tmpAttribDict valueForKey:[[NSNumber numberWithInt:[value attributeid]] stringValue]];
				if(attrib == nil)
				{
					MBLOG(MBLOG_WARN,@"[MBElementBaseController -createElementBase:] attribute for key is nil!");			
				}
				else
				{
					// set attribute with value
					[attrib setValue:value forAction:SET_FOR_INIT];
				}
			}
		}
		
		// make the same with attributes and elements
		NSEnumerator *attribKeys = [tmpAttribDict keyEnumerator];
		id attribKey;
		while((attribKey = [attribKeys nextObject])) 
		{
			attrib = [tmpAttribDict valueForKey:attribKey];
			if(attrib == nil)
			{
				MBLOG(MBLOG_WARN,@"[MBElementBaseController -createElementBase:] attribute for key is nil!");
			}
			else
			{
				elem = [tmpElemDict valueForKey:[[NSNumber numberWithInt:[attrib elementid]] stringValue]];
				if(elem == nil)
				{
					MBLOG(MBLOG_WARN,@"[MBElementBaseController -createElementBase:] element for key is nil!");			
				}
				else
				{
					// add attribute to element
					[elem addAttribute:attrib forAction:SET_FOR_INIT];
				}
			}
		}	
		
		// build element tree recursively		
		
		NSMutableArray *tmpElemList = [[[NSMutableArray alloc] initWithArray:[tmpElemDict allValues]] autorelease];
		// build root level elements
		int maxtreelevel = 0;
		// first root elements
		int i;
		for(i = [tmpElemList count]-1;i >= 0;i--)
		{
			elem = (MBElement *)[tmpElemList objectAtIndex:i];
			
			// get max treelevel
			if([elem treelevel] > maxtreelevel)
			{
				maxtreelevel = [elem treelevel];
			}
			
			if([elem treelevel] == 1)
			{
				// look for trashcan element
				if([elem elemtype] == TrashcanElementType)
				{
					// we found trashcan
					[self setTrashcanElement:elem];
				}
				
				// this is root element
				[rootElementList addObject:elem];
				// delete elemt from array
				[tmpElemList removeObjectAtIndex:i];
			}
		}
		
		// go through all root elements and set child elements recoursive
		MBElement *parent = nil;
		NSEnumerator *enumerator = [rootElementList objectEnumerator];
		while((parent = [enumerator nextObject]))
		{
			[self buildChildListRecursiveForElement:parent withSourceList:tmpElemList];
		}
		
		// create virtual UndoElement
		undoElement = [[MBElement alloc] initWithType:UndoElementType];
		
		// sort element list
		[self sortElementData];
	}
}

/**
\brief this method is used to recursive sort the all elements
 */
- (void)sortChildrenOfElement:(MBElement *)parent usingSortDescriptors:(NSArray *)newDescriptors
{
	if(parent != nil)
	{
		NSMutableArray *children = [parent childElementList];
		// sort at once
		[children sortUsingDescriptors:newDescriptors];
		// descent
		NSEnumerator *iter = [children objectEnumerator];
		MBElement *child = nil;
		while((child = [iter nextObject]))
		{
			[self sortChildrenOfElement:child usingSortDescriptors:newDescriptors];
		}
	}
	else
	{
		MBLOG(MBLOG_ERR,@"[MBVerticalMainViewController -sortChildrenOfElement:] got a nil parent!");	
	}
}

- (void)setElementNavigationBuffer:(NSMutableArray *)aArray
{
	[aArray retain];
	[elementNavigationBuffer release];
	elementNavigationBuffer = aArray;
}

- (NSMutableArray *)elementNavigationBuffer
{
	return elementNavigationBuffer;
}

/**
\brief (private) set elementList array
 @param aList initialized, not nil list of elements
 */
- (void)setRootElementList:(NSMutableArray *)aList
{
	[aList retain];
	[rootElementList release];
	rootElementList = aList;
}

/**
\brief build the element tree recursive
*/
- (void)buildChildListRecursiveForElement:(MBElement *)parent withSourceList:(NSMutableArray *)tmpElemList
{
	if(parent != nil)
	{
		if(tmpElemList != nil)
		{
			int listLen = [tmpElemList count];
			MBElement *elem = nil;
			NSString *pTreeinfo = nil;
			NSString *eTreeinfo = nil;
			for(int i = listLen-1;i >= 0;i--)
			{
				elem = [tmpElemList objectAtIndex:i];
				if(elem != nil)
				{
					// check, if child is a level deeper than parent
					if([elem treelevel] == ([parent treelevel]+1))
					{
						// yea
						// check, if treeinfo of parent is part of treeinfo of child
						pTreeinfo = [parent treeinfo];
						if(pTreeinfo == nil)
						{
							MBLOG(MBLOG_ERR,@"[MBElementBaseController -buildChildListRecursiveForElement:withSourceList:]: parent treeinfo is nil!");
						}
						eTreeinfo = [elem treeinfo];
						if(eTreeinfo == nil)
						{
							MBLOG(MBLOG_ERR,@"[MBElementBaseController -buildChildListRecursiveForElement:withSourceList:]: element treeinfo is nil!");
						}
						
						if([pTreeinfo length] > [eTreeinfo length])
						{
							MBLOG(MBLOG_WARN,@"[MBElementBaseController -buildChildListRecursiveForElement:withSourceList:]: cannot make substring, length out of bounds!");						
						}
						else
						{
							NSString *subtreeinfo = nil;
							// search for the last "." and make a substring
							for(int j = ([eTreeinfo length]-1);j >= 0;j--)
							{
								if([eTreeinfo characterAtIndex:j] == '.')
								{
									subtreeinfo = [eTreeinfo substringToIndex:j];
									break;
								}
							}
							
							if(subtreeinfo != nil)
							{
								if([pTreeinfo isEqualToString:subtreeinfo] == YES)
								{
									// we found a child, add it
									[parent addChild:elem forAction:ADD_FOR_INIT];
									// remove element from tmpElemList
									[tmpElemList removeObjectAtIndex:i];
								}
							}
							else
							{
								MBLOG(MBLOG_WARN,@"[MBElementBaseController -buildChildListRecursiveForElement:]: have a nil subtreeinfo!");
							}
						}
					}
				}
				else
				{
					MBLOG(MBLOG_WARN,@"[MBElementBaseController -buildChildListRecursiveForElement:] have nil child!");				
				}
			}
			
			if(listLen > 0)
			{
				// go find child for every child we just found
				MBElement *child = nil;
				NSEnumerator *enumerator = [[parent childElementList] objectEnumerator];
				while((child = [enumerator nextObject]))
				{
					// go down
					[self buildChildListRecursiveForElement:child withSourceList:tmpElemList];
				}
			}
			else
			{
				MBLOG(MBLOG_INFO,@"[MBElementBaseController -buildChildListRecursiveForElement:] have no further elements im templist, ready!");
			}
		}
	}
	else
	{
		MBLOG(MBLOG_WARN,@"[MBElementBaseController -buildChildListRecursiveForElement:] have nil parent!");
	}
}

/**
\brief create dictionary of elements from db row data with elementid as key
 
 @param dbData row data as NSDictionaries
 */
- (NSMutableDictionary *)createElementDictFromDbData:(NSArray *)dbData
{
	NSMutableDictionary *ret = nil;
	
	if(dbData != nil)
	{
		NSDictionary *dict = nil;
		MBElement *elem = nil;
		ret = [NSMutableDictionary dictionaryWithCapacity:[dbData count]];
		NSEnumerator *enumerator = [dbData objectEnumerator];
		while((dict = [enumerator nextObject]))
		{
			elem = [[[MBElement alloc] initWithReadingFromDict:dict] autorelease];
			if(elem != nil)
			{
				// add it to dictionary
				[ret setObject:elem forKey:[[NSNumber numberWithInt:[elem elementid]] stringValue]];
			}
			else
			{
				MBLOG(MBLOG_WARN,@"[MBElementBaseController -createElementDictFromDbData:] got nil element from init!");
			}
		}
	}
	else
	{
		MBLOG(MBLOG_WARN,@"[MBElementBaseController -createElementDictFromDbData:] got nil dbData!");
	}
	
	return ret;
}

- (NSMutableDictionary *)elementDict
{
	return elementDict;
}

- (void)setElementDict:(NSMutableDictionary *)aDict
{
	[aDict retain];
	[elementDict release];
	elementDict = aDict;
}

/**
\brief create dictionary with attributes from db row data with attributeid as key
 
 @param dbData row data as NSDictionaries
 */
- (NSMutableDictionary *)createAttributeDictFromDbData:(NSArray *)dbData
{
	NSMutableDictionary *ret = nil;
	
	if(dbData != nil)
	{
		NSDictionary *dict = nil;
		MBAttribute *attrib = nil;
		ret = [NSMutableDictionary dictionaryWithCapacity:[dbData count]];
		NSEnumerator *enumerator = [dbData objectEnumerator];
		while((dict = [enumerator nextObject]))
		{
			attrib = [[[MBAttribute alloc] initWithReadingFromDict:dict] autorelease];
			if(attrib != nil)
			{
				// add it to dict
				[ret setObject:attrib forKey:[[NSNumber numberWithInt:[attrib attributeid]] stringValue]];
			}
			else
			{
				MBLOG(MBLOG_WARN,@"[MBElementBaseController -createAttributeDictFromDbData:] got nil attrib from init!");
			}				
		}
	}
	else
	{
		MBLOG(MBLOG_WARN,@"[MBElementBaseController -createAttributeDictFromDbData:] got nil dbData!");
	}
	
	return ret;
}

- (NSMutableDictionary *)attributeDict
{
	return attributeDict;
}

- (void)setAttributeDict:(NSMutableDictionary *)aDict
{
	[aDict retain];
	[attributeDict release];
	attributeDict = aDict;
}

/**
 \brief create dictionary of value objects from db row data with valueid as key
 
 @param dbData row data as NSDictionaries
 */
- (NSMutableDictionary *)createValueDictFromDbData:(NSArray *)dbData
{
	NSMutableDictionary *ret = nil;
	
	if(dbData != nil)
	{
		NSDictionary *dict = nil;
		MBValue *value = nil;
		ret = [NSMutableDictionary dictionaryWithCapacity:[dbData count]];
		NSEnumerator *enumerator = [dbData objectEnumerator];
		while((dict = [enumerator nextObject]))
		{
			value = [[[MBValue alloc] initWithReadingFromDict:dict] autorelease];
			if(value != nil)
			{
				// add it to dictionary
				[ret setObject:value forKey:[[NSNumber numberWithInt:[value valueid]] stringValue]];
			}
			else
			{
				MBLOG(MBLOG_WARN,@"[MBElementBaseController -createValueDictFromDbData:] got nil value from init!");
			}				
		}
	}
	else
	{
		MBLOG(MBLOG_WARN,@"[MBElementBaseController -createValueDictFromDbData:] got nil dbData!");
	}
	
	return ret;
}

- (NSMutableDictionary *)valueDict
{
	return valueDict;
}

- (void)setValueDict:(NSMutableDictionary *)aDict
{
	[aDict retain];
	[valueDict release];
	valueDict = aDict;
}

@end

@implementation MBElementBaseController (transactions)

/**
 \brief moves all items to the trashcan
*/
- (void)moveItemsToTrashcan:(NSArray *)items
{
	[self addItems:items toElement:[self trashcanElement] isMoveOp:YES];
}

/**
 \brief deletes all items that are in the array
*/
- (void)removeItems:(NSArray *)items
{
	if([items count] > 0)
	{
		// get dbConnection and begin transaction
		MBDBSqlite *dbAccess = [MBDBSqlite dbConnection];
		[dbAccess sendBeginTransaction];

		NSEnumerator *iter = [items objectEnumerator];
		id item = nil;
		while((item = [iter nextObject]))
		{
			if([item isKindOfClass:[MBElement class]] == YES)
			{
				MBElement *elem = item;
				
				// delete the item
				[elem delete];
				
				// chec, if this is a root element
				MBElement *parent = [elem parent];
				if(parent == nil)
				{
					// it is, delete from root list
					[rootElementList removeObject:elem];
				}
				else
				{
					// get the parent and tell him ti remove its child
					[parent removeChild:elem];
				}
			}
			else
			{
				MBElement *elem = [item element];
				// is attribute
				// delete the attribute
				[item delete];
				
				// now get the element and tel the element to delete its attribute
				[elem removeAttribute:item];
			}
		}
		// end transaction
		[dbAccess sendCommitTransaction];
		
		// sort element list
		[self sortElementData];
		
		MBSendNotifyAttributeListChanged(nil);
		MBSendNotifyElementTreeChanged(nil);
	}
}

/**
\brief remove the given item
 it can be element or attribute. 
 */
- (void)removeItem:(id)aItem withTransaction:(BOOL)aSetting
{
	if(aItem != nil)
	{
		// get dbConnection and begin transaction
		MBDBSqlite *dbAccess = [MBDBSqlite dbConnection];

		if(aSetting == YES)
		{
			[dbAccess sendBeginTransaction];
		}
		
		if([aItem isKindOfClass:[MBElement class]] == YES)
		{
			MBElement *elem = aItem;
			
			// delete the item
			[elem delete];
			
			// chec, if this is a root element
			MBElement *parent = [elem parent];
			if(parent == nil)
			{
				// it is, delete from root list
				[rootElementList removeObject:elem];
			}
			else
			{
				// get the parent and tell him ti remove its child
				[parent removeChild:elem];
			}
			
			// sort element list
			[self sortElementData];
			
			if(aSetting == YES)
			{
				// update list
				MBSendNotifyElementTreeChanged(nil);
			}
		}
		else
		{
			MBElement *elem = [aItem element];
			// is attribute
			// delete the attribute
			[aItem delete];
			
			// now get the element and tel the element to delete its attribute
			[elem removeAttribute:aItem];

			if(aSetting == YES)
			{
				MBSendNotifyAttributeListChanged(elem);
			}
		}
				
		if(aSetting == YES)
		{
			[dbAccess sendCommitTransaction];
		}
	}
	else
	{
		MBLOG(MBLOG_WARN,@"[MBElementBaseController -removeItem:] item is nil!");
	}
}

- (void)addAttribute:(MBAttribute *)attrib toElement:(MBElement *)elem isMoveOp:(BOOL)moveOp withTransaction:(BOOL)aSetting
{
	if(attrib != nil)
	{
		if(elem != nil)
		{
			// get dbConnection and begin transaction
			MBDBSqlite *dbAccess = [MBDBSqlite dbConnection];

			if(aSetting == YES)
			{
				[dbAccess sendBeginTransaction];
			}
			
			// we have to hold a reference
			[attrib retain];
			
			// is this a move operation?
			if(moveOp == YES)
			{						
				// remove the attribute from the old element
				if([attrib element] != nil)
				{
					[[attrib element] removeAttribute:attrib];
				}
				else
				{
					// if the attribute has no element this is an error
					MBLOG(MBLOG_ERR,@"[MBElementBaseController -addAttribute:toElement:isMoveOp:withTransaction:]: attribute has no element!");
				}
			}				

			// add attribute
			[elem addAttribute:attrib forAction:ADD_FOR_NEW];
			
			if(aSetting == YES)
			{
				[dbAccess sendCommitTransaction];
			
				// send notification
				MBSendNotifyAttributeListChanged(elem);
			}
			
			// release attribute
			[attrib release];
		}
		else
		{
			MBLOG(MBLOG_WARN,@"[MBElementBaseController -addAttribute:toElement:]: elem is nil!");
		}
	}
	else
	{
		MBLOG(MBLOG_WARN,@"[MBElementBaseController -addAttribute:toElement:]: attrib is nil!");
	}	
}

/**
\brief moves an element to be a child of the given element
 */
- (void)addElement:(MBElement *)child toElement:(MBElement *)parent isMoveOp:(BOOL)moveOp withTransaction:(BOOL)transaction
{
	if(child != nil)
	{
		// get dbConnection and begin transaction
		MBDBSqlite *dbAccess = [MBDBSqlite dbConnection];

		if(transaction == YES)
		{
			[dbAccess sendBeginTransaction];
		}
		
		// hold a reference to the child
		[child retain];

		// is this a move operation?
		if(moveOp == YES)
		{
			// remove the child from the old parent
			if([child parent] != nil)
			{
				[[child parent] removeChild:child];
			}
			else
			{
				// this must be an root element
				[rootElementList removeObject:child];
			}
		}
		
		if(parent == nil)
		{
			// adding to root
			[child setParent:nil forAction:SET_FOR_NEW];
			// add to list
			[rootElementList addObject:child];
			// set the sortorder
			[child setSortorder:([rootElementList count]-[[MBElementType systemElementTypes] count])];
		}
		else
		{
			// add element
			[parent addChild:child forAction:ADD_FOR_NEW];
		}
		
		// release child
		[child release];
				
		// sort element list
		[self sortElementData];
		
		if(transaction == YES)
		{
			[dbAccess sendCommitTransaction];
		
			// send notification
			MBSendNotifyElementTreeChanged(parent);
		}
	}
	else
	{
		MBLOG(MBLOG_WARN,@"[MBElementBaseController -addElement:toElement:]: child is nil!");
	}
}

/**
 \brief add mixed items, element or attribute to an element
 @params[in] moveOp is this a move operation?
*/
- (void)addItems:(NSArray *)items toElement:(MBElement *)aElem isMoveOp:(BOOL)moveOp
{
	if([items count] > 0)
	{
		// get dbConnection and begin transaction
		MBDBSqlite *dbAccess = [MBDBSqlite dbConnection];
		[dbAccess sendBeginTransaction];
		
		NSEnumerator *iter = [items objectEnumerator];
		id item = nil;
		while((item = [iter nextObject]))
		{
			// check class
			if([item isKindOfClass:[MBElement class]] == YES)
			{
				MBElement *elem = item;

				// hold a reference to the child
				[elem retain];
				
				// is this a move operation?
				if(moveOp == YES)
				{
					// remove the child from the old parent
					if([elem parent] != nil)
					{
						[[elem parent] removeChild:elem];
					}
					else
					{
						// this must be an root element
						[rootElementList removeObject:elem];
					}
				}				
				
				if(aElem != nil)
				{
					// add item to element
					[aElem addChild:elem forAction:ADD_FOR_NEW];
				}
				else
				{
					// add to root
					[elem setParent:nil forAction:SET_FOR_NEW];
					// add to rootList
					[rootElementList addObject:elem];
					// set sortorder
					[elem setSortorder:([rootElementList count]-[[MBElementType systemElementTypes] count])];
				}
				
				// release the reference
				[elem release];
			}
			else if([item isKindOfClass:[MBAttribute class]] == YES)
			{
				MBAttribute *attrib = item;
				
				if(aElem != nil)
				{
					// we have to hold a reference
					[attrib retain];

					// is this a move operation?
					if(moveOp == YES)
					{						
						// remove the attribute from the old element
						if([attrib element] != nil)
						{
							[[attrib element] removeAttribute:attrib];
						}
						else
						{
							// if the attribute has no element this is an error
							MBLOG(MBLOG_ERR,@"[MBElementBaseController -addItems:toElement:isMoveOp:]: attribute has no element!");
						}
					}				
					
					// add to element
					[aElem addAttribute:attrib forAction:ADD_FOR_NEW];
					
					// release the attribute
					[attrib release];
				}
				else
				{
					MBLOG(MBLOG_WARN,@"[MBElementBaseController -addItems:toElement:]: attributes cannot added to a nil element!");				
				}
			}
			else
			{
				MBLOG(MBLOG_WARN,@"[MBElementBaseController -addItems:toElement:]: unrecognized class in items array!");			
			}
		}
		// commit
		[dbAccess sendCommitTransaction];
		
		// sort element list
		[self sortElementData];

		// send notification
		MBSendNotifyElementTreeChanged(nil);
		MBSendNotifyAttributeListChanged(nil);
	}
	else
	{
		MBLOG(MBLOG_WARN,@"[MBElementBaseController -addItems:toElement:]: items array is empty!");			
	}
}

/**
\brief add new attribute. if there is no currentselection inform user
 this method makes a new db transaction and must use no method of this class that opens another transaction
 @param aType add attribute of this type
 */
- (void)addNewAttributeByType:(int)aType
{
	if((aType == URLValueType) || (aType == FileValueType) || (aType == ImageValueType))
	{
		// bring up alert sheet
		NSWindow *mainWindow = [GlobalWindows mainAppWindow];
		if(mainWindow != nil)
		{
			NSBeginAlertSheet(MBLocaleStr(@"Not Implemented"),
							  MBLocaleStr(@"OK"),nil,nil,
							  mainWindow,nil,nil,nil,nil,
							  MBLocaleStr(@"Adding this kind of Attrobute is not implemented yet!"));		
		}
		else
		{
			MBLOG(MBLOG_WARN,@"[MBElementBaseController -addNewAttributeByType:] mainWindownot available, cannot open sheet!");
		}		
	}
	else
	{
		// first check, if there is a element selected
		// if it is not, no attribute can be added
		NSWindow *mainWindow = [GlobalWindows mainAppWindow];
		int selectionCount = [currentElementSelection count];
		if(selectionCount == 0)
		{
			// no element can be selected
			// bring up alert sheet
			NSBeginAlertSheet(MBLocaleStr(@"Warning"),
							  MBLocaleStr(@"OK"),nil,nil,
							  mainWindow,nil,nil,nil,nil,
							  MBLocaleStr(@"CannotAddAttributeNoSelectedElement"));
		}
		else if(selectionCount > 1)
		{
			// more than one element selected
			// bring up alert sheet
			NSBeginAlertSheet(MBLocaleStr(@"Warning"),
							  MBLocaleStr(@"OK"),nil,nil,
							  mainWindow,nil,nil,nil,nil,
							  MBLocaleStr(@"Please select ONE Element!"));
		}
		else
		{
			// get dbConnection and begin transaction
			MBDBSqlite *dbAccess = [MBDBSqlite dbConnection];
			[dbAccess sendBeginTransaction];
			
			// create attribute
			MBAttribute *attrib = [[[MBAttribute alloc] initWithDb] autorelease];
			
			// create value
			MBValue *value = [[[MBValue alloc] initWithDbAndType:aType] autorelease];
			
			// add value to attribute
			[attrib setValue:value forAction:SET_FOR_NEW];
			
			// add attribute to current selected element
			MBElement *elem = [currentElementSelection objectAtIndex:0];
			[elem addAttribute:attrib forAction:ADD_FOR_NEW];
			
			// end transaction
			[dbAccess sendCommitTransaction];
			
			// prepare for undo manager
			[[undoManager prepareWithInvocationTarget:self] removeItem:attrib withTransaction:YES];
			if(![undoManager isUndoing])
			{
				[undoManager setActionName:MBLocaleStr(@"UndoAddAttribute")];
			}
			
			// send notification to update the attribute tableview
			MBSendNotifyAttributeListChanged(nil);
		}
	}
}

/**
\brief add a new element by specified type
 */
- (void)addNewElementByType:(int)aElementType
{
	// get mainwindow
	NSWindow *mainWindow = [GlobalWindows mainAppWindow];

	// check for type
	if((aElementType == TemplateElementType) ||
	   (aElementType == ContactElementType))
	{
		// bring up alert sheet
		NSBeginAlertSheet(MBLocaleStr(@"Not Implemented"),
						  MBLocaleStr(@"OK"),nil,nil,
						  mainWindow,nil,nil,nil,nil,
						  MBLocaleStr(@"Adding this kind of Element is not implemented yet!"));		
	}
	else
	{
		int selectionCount = [currentElementSelection count];
		if(selectionCount > 1)
		{
			// more than one element selected
			// bring up alert sheet
			NSBeginAlertSheet(MBLocaleStr(@"Warning"),
							  MBLocaleStr(@"OK"),nil,nil,
							  mainWindow,nil,nil,nil,nil,
							  MBLocaleStr(@"Please select ONE Element!"));
		}
		else
		{
			// get dbConnection and begin transaction
			MBDBSqlite *dbAccess = [MBDBSqlite dbConnection];
			[dbAccess sendBeginTransaction];
			
			// create new element
			MBElement *newElem = [[[MBElement alloc] initWithDbAndType:aElementType] autorelease];
			
			if(selectionCount == 0)
			{
				// adding to root
				[newElem setParent:nil forAction:SET_FOR_NEW];
				// add to list
				[rootElementList addObject:newElem];
				// set sortorder for this new element
				[newElem setSortorder:(([rootElementList count]+1)-[[MBElementType systemElementTypes] count])];
			}
			else
			{
				MBElement *elem = [currentElementSelection objectAtIndex:0];
				// add element
				// sortorder is set in -addChild:
				[elem addChild:newElem forAction:ADD_FOR_NEW];
			}
			
			// write to db
			[dbAccess sendCommitTransaction];

			// prepare for undo manager
			[[undoManager prepareWithInvocationTarget:self] removeItem:newElem withTransaction:YES];
			if(![undoManager isUndoing])
			{
				[undoManager setActionName:MBLocaleStr(@"UndoAddElement")];
			}
			
			// sort element tree
			[self sortElementData];
			
			// send notification
			MBSendNotifyElementTreeChanged([newElem parent]);
		}
	}
}

@end

