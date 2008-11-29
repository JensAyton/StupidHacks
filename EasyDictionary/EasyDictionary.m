// This horrible hack is hereby placed in the public domain. I recommend never using it for anything.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


#if 0
#define LOG NSLog
#else
#define LOG(...) do {} while (0)
#endif


static NSString *PropertyNameFromSetter(NSString *setterName)
{
	setterName = [setterName substringFromIndex:3];                // Remove "set"
	NSString *firstChar = [[setterName substringToIndex:1] lowercaseString];
	NSString *tail = [setterName substringFromIndex:1];
	tail = [tail substringToIndex:[tail length] - 1];        // Remove ":"
	return [firstChar stringByAppendingString:tail];        // Convert first char to lowercase.
}


static id DynamicDictionaryGetter(id self, SEL _cmd)
{
	return [self objectForKey:NSStringFromSelector(_cmd)];
}


static void DynamicDictionarySetter(id self, SEL _cmd, id value)
{
	NSString *key = PropertyNameFromSetter(NSStringFromSelector(_cmd));
	
	if (value == nil)
	{
		[self removeObjectForKey:key];
	}
	else
	{
		[self setObject:value forKey:key];
	}
}


@implementation NSDictionary (DynamicAccessors)

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
	NSString *selStr = NSStringFromSelector(sel);
	// Only handle selectors with no colon.
	if ([selStr rangeOfString:@":"].location == NSNotFound)
	{
		LOG(@"Generating dynamic accessor -%@", selStr);
		return class_addMethod(self, sel, (IMP)DynamicDictionaryGetter, @encode(id(*)(id, SEL)));
	}
	else
	{
		return [super resolveInstanceMethod:sel];
	}
}

@end


@implementation NSMutableDictionary (DynamicAccessors)

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
	NSString *selStr = NSStringFromSelector(sel);
	// Only handle selectors beginning with "set", ending with a colon and with no intermediate colons.
	// Also, to simplify PropertyNameFromSetter, we requre a length of at least 5 (2 + "set").
	if ([selStr hasPrefix:@"set"] &&
		[selStr hasSuffix:@":"] &&
		[selStr rangeOfString:@":" options:0 range:NSMakeRange(0, [selStr length] - 1)].location == NSNotFound &&
		[selStr length] >= 6)
	{
		LOG(@"Generating dynamic accessor -%@ for property \"%@\"", selStr, PropertyNameFromSetter(selStr));
		return class_addMethod(self, sel, (IMP)DynamicDictionarySetter, @encode(id(*)(id, SEL, id)));
	}
	else
	{
		return [super resolveInstanceMethod:sel];
	}
}

@end
