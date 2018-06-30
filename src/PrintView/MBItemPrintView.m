//
//  MBItemPrintView.m
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 29.11.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author$
// $HeadURL$
// $LastChangedBy$
// $LastChangedDate$
// $Rev$

#import "MBItemPrintView.h"
#define ITEM_VSPACE 30.0
#define ITEMVALUE_VSPACE 70.0
#define VALUE_HTABSPACE 20.0

@interface MBItemPrintView (privateAPI)

- (void)drawItemValue:(MBItemValue *)itemValue inRect:(NSRect)rect;
- (void)drawItem:(MBItem *)item inRect:(NSRect)rect;
- (NSArray *)generateFlatArrayWithArray:(NSArray *)input;

@end

@implementation MBItemPrintView (privateAPI)

- (void)drawItemValue:(MBItemValue *)itemValue inRect:(NSRect)rect;
{
	// we need bold attributes
	NSMutableDictionary *attrib = [NSMutableDictionary dictionary];
	[attrib setObject:MBSmallTableViewFont forKey:NSFontAttributeName];	
	
	// get type
	NSString *typeString = nil;
	NSString *valueString = nil;
	switch([itemValue valuetype])
	{
		case SimpleTextItemValueType:
			typeString = SIMPLETEXT_ITEMVALUE_TYPE_NAME;
			valueString = [itemValue valueDataAsString];
			break;
		case NumberItemValueType:
		{
			typeString = NUMBER_ITEMVALUE_TYPE_NAME;
			
			NSString *formatString = nil;
			// create NSNumberformatter for formatted number string
			if([(MBNumberItemValue *)itemValue useGlobalFormat] == YES)
			{
				formatString = [userDefaults valueForKey:MBDefaultsNumberFormatKey];
			}
			else
			{
				formatString = [(MBNumberItemValue *)itemValue formatterString];
			}
			
			NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
			[formatter setFormat:formatString];
			// convert Number to String
			valueString = [formatter stringForObjectValue:[itemValue valueData]];
			
			break;
		}
		case CurrencyItemValueType:
		{
			typeString = CURRENCY_ITEMVALUE_TYPE_NAME;

			NSString *formatString = nil;
			// create NSNumberformatter for formatted number string
			if([(MBCurrencyItemValue *)itemValue useGlobalFormat] == YES)
			{
				formatString = [userDefaults valueForKey:MBDefaultsCurrencyFormatKey];
			}
			else
			{
				formatString = [(MBCurrencyItemValue *)itemValue formatterString];
			}
			
			NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
			[formatter setFormat:formatString];
			// convert Number to String
			valueString = [formatter stringForObjectValue:[itemValue valueData]];

			break;
		}
		case BoolItemValueType:
			typeString = BOOL_ITEMVALUE_TYPE_NAME;
			break;
		case DateItemValueType:
		{
			typeString = DATE_ITEMVALUE_TYPE_NAME;

			NSString *formatString = nil;
			BOOL allowNatLanguage = NO;
			// create NSDateFormatter for formatted number string
			if([(MBDateItemValue *)itemValue useGlobalFormat] == YES)
			{
				formatString = [userDefaults valueForKey:MBDefaultsDateFormatKey];
				allowNatLanguage = (BOOL)[[userDefaults valueForKey:MBDefaultsDateFormatAllowNaturalLanguageKey] intValue];
			}
			else
			{
				formatString = [(MBDateItemValue *)itemValue formatterString];
				allowNatLanguage = [(MBDateItemValue *)itemValue allowNaturalLanguage];
			}

			NSDateFormatter *formatter = [[[NSDateFormatter alloc] initWithDateFormat:formatString 
																 allowNaturalLanguage:allowNatLanguage] autorelease];
			// convert Number to String
			valueString = [formatter stringForObjectValue:[itemValue valueData]];

			break;
		}
		case URLItemValueType:
			// add blue color and underline for url
			typeString = URL_ITEMVALUE_TYPE_NAME;
			valueString = [itemValue valueDataAsString];
			break;
		case ExtendedTextItemValueType:
			typeString = EXTENDEDTEXT_ITEMVALUE_TYPE_NAME;
			valueString = [itemValue valueDataAsString];
			break;
		case ImageItemValueType:
			typeString = IMAGE_ITEMVALUE_TYPE_NAME;
			valueString = [itemValue valueDataAsString];
			break;
		case FileItemValueType:
			typeString = FILE_ITEMVALUE_TYPE_NAME;
			valueString = [itemValue valueDataAsString];
			break;
	}
	
	NSString *dataString = nil;
	dataString = [NSString stringWithFormat:@"Name: %@\nType: %@\nValue: %@\nComment: %@",
		[itemValue name],
		typeString,
		valueString,
		[itemValue comment]];
	
	[dataString drawInRect:rect withAttributes:attributes];
	// draw line below
	NSBezierPath *line = [NSBezierPath bezierPath];
	[line setLineWidth:1.0];
	[line moveToPoint:NSMakePoint(rect.origin.x,(rect.origin.y + (rect.size.height-5.0)))];
	[line lineToPoint:NSMakePoint((rect.origin.x + rect.size.width),(rect.origin.y + (rect.size.height-5.0)))];
	[line stroke];
}

- (void)drawItem:(MBItem *)item inRect:(NSRect)rect
{
	NSString *dataString = nil;
	dataString = [NSString stringWithFormat:@"Item name: %@ \t has %d values",[item name],[[item itemValues] count]];
	
	// we need bold attributes
	NSMutableDictionary *attrib = [NSMutableDictionary dictionary];
	[attrib setObject:MBStdBoldTableViewFont forKey:NSFontAttributeName];	
	[dataString drawInRect:rect withAttributes:attrib];	
}

- (NSArray *)generateFlatArrayWithArray:(NSArray *)input;
{
	NSMutableArray *ret = [NSMutableArray array];
	
	NSEnumerator *iter = [input objectEnumerator];
	MBCommonItem *ci = nil;
	while((ci = [iter nextObject]))
	{
		if(NSLocationInRange([ci identifier],ITEM_ID_RANGE))
		{
			MBItem *item = (MBItem *)ci;
			// add the item itself
			[ret addObject:item];
			// add all itemvalues next
			[ret addObjectsFromArray:[item itemValues]];
		}
		else if(NSLocationInRange([ci identifier],ITEMVALUE_ID_RANGE))
		{
			// add the itemvalue
			[ret addObject:ci];			
		}
	}
	
	return ret;
}

@end

@implementation MBItemPrintView

- (id)initWithItems:(NSArray *)array printInfo:(NSPrintInfo *)pi;
{
	NSRange pageRange;
	NSRect frame;
	
	// get data out of printInfo
	paperSize = [pi paperSize];
	leftMargin = [pi leftMargin];
	topMargin = [pi topMargin];
	
	items = [[self generateFlatArrayWithArray:array] retain];
	
	// get numnber of pages
	[self knowsPageRange:&pageRange];
	
	// the view must be gig enough to hold the first and the last page
	frame = NSUnionRect([self rectForPage:pageRange.location],[self rectForPage:NSMaxRange(pageRange)-1]);
	
	// attributes for printing
	attributes = [[NSMutableDictionary alloc] init];
	[attributes setObject:MBSmallTableViewFont forKey:NSFontAttributeName];
	
	// call superclass's designated initializer
	return [super initWithFrame:frame];
}

- (void)dealloc
{
	// release some stuff
	[items release];
	[attributes release];
	
	[super dealloc];
}

// flip page origin
- (BOOL)isFlipped
{
	return YES;
}

- (NSRect)rectForPage:(int)page
{
	NSRect ret;
	ret.size = paperSize;
	
	// number of pages start with 1
	ret.origin.y = (page - 1) * paperSize.height;
	ret.origin.x = 0.0;
	
	return ret;
}

- (int)itemsPerPage
{
	float ipp = (paperSize.height - (2.0 * topMargin)) / ITEMVALUE_VSPACE;
	return (int)ipp;
}

- (BOOL)knowsPageRange:(NSRange *)r
{
	int ipp = [self itemsPerPage];
	
	// Page count starts at 1
	int count = [items count];
	r->location = 1;
	r->length = (count / ipp);
	if(count % ipp > 0)
	{
		r->length = r->length + 1;
	}
	
	return YES;
}

- (NSRect)rectForItem:(int)i
{
	NSRect result;
	int ipp = [self itemsPerPage];

	float space = 0.0;
	
	MBCommonItem *ci = [items objectAtIndex:i];
	if(NSLocationInRange([ci identifier],ITEMVALUE_ID_RANGE))
	{
		space = ITEMVALUE_VSPACE;
	}
	else
	{
		space = ITEM_VSPACE;
	}
	
	result.size.height = space;
	result.size.width = paperSize.width - (2 * leftMargin);
	result.origin.x = leftMargin;

	int page = i / ipp;
	int indexOnPage = i % ipp;
	result.origin.y = (page * paperSize.height) + topMargin + (indexOnPage * space);
	
	return result;
}

- (void)drawRect:(NSRect)rect
{
	int count = [items count];
	
	for(int i = 0;i < count;i++)
	{
		NSRect personRect = [self rectForItem:i];
		if(NSIntersectsRect(rect,personRect))
		{
			MBCommonItem *ci = [items objectAtIndex:i];
			if(NSLocationInRange([ci identifier],ITEMVALUE_ID_RANGE))
			{
				personRect.size.width -= VALUE_HTABSPACE;
				personRect.origin.x += VALUE_HTABSPACE;

				MBItemValue *itemval = (MBItemValue *)ci;
				[self drawItemValue:itemval inRect:personRect];
			}
			else if(NSLocationInRange([ci identifier],ITEM_ID_RANGE))
			{
				MBItem *item = (MBItem *)ci;
				[self drawItem:item inRect:personRect];
			}
		}
	}
}

@end
