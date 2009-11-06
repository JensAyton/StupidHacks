// This horrible hack is hereby placed in the public domain. I recommend never using it for anything.

#import "SillyString.h"
#import <objc/runtime.h>
#import <stdarg.h>


static BOOL IsColonOnlySelector(SEL selector);
static NSUInteger ColonCount(SEL selector);
static NSString *SillyStringImplementation(id self, SEL _cmd, ...);


@implementation NSString (JASillyStringImpl)

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
	if (IsColonOnlySelector(sel))
	{
		NSUInteger i, colonCount = ColonCount(sel);
		NSMutableString *typeStr = [NSMutableString stringWithCapacity:colonCount + 3];
		[typeStr appendString:@"@@:"];
		for (i = 0; i != colonCount; ++i)
		{
			[typeStr appendString:@"@"];
		}
		
		return class_addMethod([self class], sel, (IMP)SillyStringImplementation, typeStr.UTF8String);
	}
	
	else return [super resolveInstanceMethod:sel];
}

@end


static BOOL IsColonOnlySelector(SEL selector)
{
	NSString *selString = NSStringFromSelector(selector);
	NSUInteger i, count = selString.length;
	for (i = 0; i < count; ++i)
	{
		if ([selString characterAtIndex:i] != ':')  return NO;
	}
	
	return YES;
}


static NSUInteger ColonCount(SEL selector)
{
	assert(IsColonOnlySelector(selector));
	return NSStringFromSelector(selector).length;
}


static NSString *SillyStringImplementation(id self, SEL _cmd, ...)
{
	NSUInteger i, count = ColonCount(_cmd);
	NSMutableString *string = [self mutableCopy];
	NSString *result = nil;
	
	@try
	{
		va_list args;
		id obj = nil;
		va_start(args, _cmd);
		for (i = 0; i != count; ++i)
		{
			obj = va_arg(args, id);
			if (obj == nil)  obj = @"";
			[string appendString:[obj description]];
		}
		va_end(args);
		
		result = [[string copy] autorelease];
	}
	@finally
	{
		[string release];
	}
	
	return result;
}
