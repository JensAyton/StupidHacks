/*	Two subclasses of NSNumber, implementing 64-bit integer and floating-point
	numbers. This is a documented safe thing to do, so it's not evil like the
	header. However, these classes don't have init methods and can never be
	released, so they're not very useful as is.
*/

#import <Foundation/Foundation.h>


@interface JAIntegerNumber: NSNumber
{
@private
	long long				_value;
}

@end


@interface JAFloatNumber: NSNumber
{
@private
	double					_value;
}

@end


@implementation JAIntegerNumber

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


- (id) copy
{
	return self;
}


- (id) copyWithZone:(NSZone *)zone
{
	if (zone == [self zone])  return self;
	return [[NSNumber allocWithZone:zone] initWithLongLong:_value];
}


// NSValue required methods

- (void) getValue:(void *)value
{
	*((long long *)value) = _value;
}


- (const char *) objCType
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
	return [self descriptionWithLocale:nil];
}


- (NSComparisonResult) compare:(NSNumber *)other
{
	long long otherVal;
	BOOL gotValue = NO;
	if ([other respondsToSelector:@selector(longLongValue)])
	{
		otherVal = [other longLongValue];
		gotValue = YES;
	}
	else if ([other respondsToSelector:@selector(intValue)])
	{
		otherVal = [other intValue];
		gotValue = YES;
	}
	
	if (gotValue)
	{
		if (otherVal > _value)  return NSOrderedAscending;
		if (otherVal < _value)  return NSOrderedDescending;
	}
	
	return NSOrderedSame;
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


// *** JAFloatNumber ***

@implementation JAFloatNumber

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


- (id) copy
{
	return self;
}


- (id) copyWithZone:(NSZone *)zone
{
	if (zone == [self zone])  return self;
	return [[NSNumber allocWithZone:zone] initWithDouble:_value];
}


// NSValue required methods

- (void) getValue:(void *)value
{
	*((long long *)value) = _value;
}


- (const char *) objCType
{
	return @encode(long long);
}


// NSNumber methods
- (long long) doubleValue
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


- (long) longLongValue
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
	return [self descriptionWithLocale:nil];
}


- (NSComparisonResult) compare:(NSNumber *)other
{
	if ([other respondsToSelector:@selector(doubleValue)])
	{
		double otherVal = [other doubleValue];
		if (otherVal > _value)  return NSOrderedAscending;
		if (otherVal < _value)  return NSOrderedDescending;
	}
	return NSOrderedSame;
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
	return [[[NSString alloc] initWithFormat:@"%0.7g" locale:locale, _value] autorelease];
}

@end
