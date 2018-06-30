/* MBElementBaseController */

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>
#import "MBBaseDefinitions.h"

@class MBDBAccess;
@class MBElement;
@class MBDBDocumentEntry;
@class MBElementValue;

// define for simpler access to ElementBaseController
#define elementController	[MBElementBaseController standardController]

@interface MBElementBaseController : NSObject {
    
    /** the db connection */
    MBDBAccess *dbAccess;
    
	// our root
	MBElement *rootElement;
	
	// oversize export path
	NSString *oversizeDataExportPath;
	NSString *oversizeDataImportPath;
	
	// memory footprint
	MBMemFootprintType memoryFootprint;
    
    // storage type for single instance
    DocStorageType docStorageType;
    
    // the path for external single instance storage
    NSString *docStoragePath;
    
    // single instance pool dictionary
    NSMutableDictionary *singleInstanceDocPool;
    
	// controller state
	int state;
}

// singleton for shared instance
+ (MBElementBaseController *)standardController;
- (void)buildElementBase;
- (void)loadChildElementsForElement:(MBElement *)aElement withIdentifier:(NSString *)aIdentifier;

// root element
- (void)setRootElement:(MBElement *)rootElem;
- (MBElement *)rootElement;

// root Element child list
- (NSArray *)rootElementList;

// database access
- (void)setDbAccess:(MBDBAccess *)aDbAccess;
- (MBDBAccess *)dbAccess;

// controller state
- (void)setState:(int)aState;
- (int)state;

// memory footprint
- (void)setMemoryFootprint:(MBMemFootprintType)aValue;
- (MBMemFootprintType)memoryFootprint;

// SI storage type
- (DocStorageType)docStorageType;
- (void)setDocStorageType:(DocStorageType)value;

// SI storage path
- (NSString *)docStoragePath;
- (void)setDocStoragePath:(NSString *)value;

// SI pool methods
- (MBDBDocumentEntry *)documentEntryForHash:(NSString *)docHash;
- (MBDBDocumentEntry *)documentEntryForId:(int)id;

// oversize export path
- (void)setOversizeDataExportPath:(NSString *)aPath;
- (NSString *)oversizeDataExportPath;
- (void)setOversizeDataImportPath:(NSString*)aPath;
- (NSString *)oversizeDataImportPath;

// root list maintenance
- (void)addElementToRootList:(MBElement *)elem;
- (void)removeElementFromRootList:(MBElement *)elem;

// adding element
- (void)addElement:(MBElement *)child 
		 toElement:(MBElement *)parent 
withConnectingChild:(BOOL)dbConnected 
		  isMoveOp:(BOOL)moveOp 
	 isTransaction:(BOOL)transaction;

// adding mixed stuff
- (void)addItems:(NSArray *)items 
	   toElement:(MBElement *)aElem 
withConnectingChild:(BOOL)dbConnected 
		isMoveOp:(BOOL)moveOp 
   isTransaction:(BOOL)transaction;

// adding elementvalues
- (void)addElementValue:(MBElementValue *)value 
			  toElement:(MBElement *)parent 
	withConnectingValue:(BOOL)dbConnected 
			   isMoveOp:(BOOL)moveOp 
		  isTransaction:(BOOL)transaction;

// removing item
- (void)removeObject:(id)aObjact;
- (void)removeObjects:(NSArray *)objects;

@end
