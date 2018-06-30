//
//  MBBaseDefinitions.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 05.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import <Cocoa/Cocoa.h>

#define MBElementBaseVersion @"2.0.0"

typedef enum {
	ADD_FOR_INIT = 0,
	ADD_FOR_NEW,
	SET_FOR_INIT,
	SET_FOR_NEW
}MBElementBaseAction;

typedef enum {
	StringValueType = 0,
	NumberValueType,
	BinaryValueType,
    ExternalBinaryValueType
}MBValueType;

// the state this controller and the elements can have
typedef enum ElementBaseState {
	LoadingState = 0,
	InitState,
	CopyState,
	EncodingState,
	DecodingState,
	UnRedoState,
	SetterState,
	DeallocState,
	NormalState
}ElementStateType;

// type of hashing
typedef enum HashType {
    HashNone = 0,
    HashSHA1,
    HashSHA256
}HashType;

// encryption type
typedef enum EncryptionType {
    EncryptionNone = 0,
    EncryptionBlowfish
}EncryptionType;

typedef enum MemoryFootprint {
	FullCacheMemFootprintType = -1,
	LoadEveryTimeMemFootprintType = 0,
	SmallMemFootprintType = 512,
	MediumMemFootprintType = (1024 * 8),
	LargeMemFootprintType = (1024 * 128)
}MBMemFootprintType;

/**
the storage type of the value for single instance
 */
typedef enum DocStorageType {
    DocStorageDB = 0,
    DocStorageFS
}DocStorageType;

// enum for gpreg flags
typedef enum _MBElemValGpRegFlags {
	MBElementValueHasIndex = 0x0001,            // bit 1
    MBElementValueSIStored = 0x0002,            // bit 2
    MBElementValueHashType = 0x000b,            // bit 3,4
    MBElementValueEncryptionType = 0x0030       // bit 5,6
}MBElemValGpRegFlags;

#define ROOTELEMENT_ID			@"-1"

#define STRING_VALUETYPE_NAME           @"String"
#define NUMBER_VALUETYPE_NAME           @"Number"
#define BINARY_VALUETYPE_NAME           @"Binary"

// for document data and storage type
#define DOC_STORAGETYPE_DB              @"DocStorageDB"
#define DOC_STORAGETYPE_FS              @"DocStorageFS"

// size threshold for single instance storing (1 kbyte)
#define SINGLE_INSTANCE_THRESHOLD (1024)

@interface MBBaseDefinitions : NSObject  {
}

+ (NSArray *)valueTypes;

@end
