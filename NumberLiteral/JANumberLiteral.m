//
//  JANumberLiteral.m
//  NumberLiteral
//
//  Created by Jens Ayton on 2008-12-10.
//  Copyright 2008 Jens Ayton. All rights reserved.
//

#import "JANumberLiteral.h"


@interface JAIntegerLiteralNumber: NSNumber
{
@private
	long long				_value;
}

@end


@interface JAFloatLiteralNumber: NSNumber
{
@private
	double					_value;
}

@end


@implementation JAIntegerLiteralNumber

// Like a singleton, we can't be released
- (id) retain
{
	return self;
}


- (void) release
{
}


- (id) autorelease
{
	return self;
}


- (NSUInteger) retainCount
{
	return INT_MAX;
}


// NSValue required methods

- (void)getValue:(void *)value
{
	*((long long *)value) = _value;
}


- (const char *)objCType
{
	return @encode(long long);
}


// NSNumber methods
- (long long) longLongValue
{
	return _value;
}


/*	NSNumber actually provides these by calling -longLongValue, but that's
	undocumented.
	
	NSNumber's default implementations handle overflow C-style, by pretending
	the problem doesn't exist, so it's easy to replicate.
*/
- (char) charValue
{
	return _value;
}


- (unsigned char) unsignedCharValue
{
	return _value;
}


- (short) shortValue
{
	return _value;
}


- (unsigned short) unsignedShortValue
{
	return _value;
}


- (int) intValue
{
	return _value;
}


- (unsigned int) unsignedIntValue
{
	return _value;
}


- (long) longValue
{
	return _value;
}


- (unsigned long) unsignedLongValue
{
	return _value;
}


- (unsigned long long) unsignedLongLongValue
{
	return _value;
}


- (float) floatValue
{
	return _value;
}


- (double) doubleValue
{
	return _value;
}


- (BOOL) boolValue
{
	return _value;
}


- (NSInteger) integerValue
{
	return _value;
}


- (NSUInteger) unsignedIntegerValue
{
	return _value;
}


- (NSString *) stringValue
{
	return [NSString stringWithFormat:@"%lli", _value];
}


- (NSComparisonResult) compare:(NSNumber *)otherNumber
{
	return _value;
}


- (BOOL) isEqualToNumber:(NSNumber *)number
{
	/*	This is valid because -objCType is restricted to a set of single-char
		values - see documentation.
	*/
	char type = [number objCType][0];
	switch (type)
	{
		case 'f':
		case 'd':
			// Floating point
			return [number doubleValue] == [self doubleValue];
			break;
		
		default:
			return [number longLongValue] == [self longLongValue];
	}
}


- (NSString *) descriptionWithLocale:(id)locale
{
	return [[[NSString alloc] initWithFormat:@"%lli" locale:locale, _value] autorelease];
}

@end
