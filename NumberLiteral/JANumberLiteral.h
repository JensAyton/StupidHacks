/*
	JANumberLiteral.h
	
	This code may be used freely for any purpose except actually using it to
	do real work. Seriously, this is a horrible hack that is not future-
	compatible, or even present-compatible. Study it as a demonstration of the
	nuts and bolts of Objective-C and then throw it away, or skip directly to
	step two and just throw it away.
	
	== What it does ==
	This code allows you to create "constant" NSNumbers in the data section of
	your application, in essentially the same way as the @"string" operator
	does. This is accomplished by packing a struct with the same layout as one
	of the custom implementations of NSNumber found in JANumberLiteral.h, and
	casting a pointer to the result. Ignoring the logic to handle float and
	integer types separately and the fallback for non-constants, it boils down
	to:
	
	struct JAFloatLiteralDefs { Class isa; double value; };
	static const JAFloatLiteralDefs object = { JAFloatLiteralClassObject, 42.0 };
	return (NSNumber *)&object;
	
	The "static" here is critical; without it, the object would be built on
	the stack and be invalidated when your function or method returned. The
	JANUMBERLITERAL_CONSTANT() hides this for you by creating the static
	variable in an inner scope and returning a pointer to it.
*/

#import <Foundation/Foundation.h>


/*	JANUMBERLITERAL_IS_FLOAT_TYPE() is true for floating-point types, false
	for other types, and undefined for non-numerical types. NOTE: the C++
	impelementation (by natevw) evaluates its argument multiple times and is
	thus not side-effect free. This is OK as it's only used on known constant
	expressions.
*/
#ifdef __cplusplus
#define JANUMBERLITERAL_IS_FLOAT_TYPE(x)	( \
												((x) > 0) ? \
													((x) / ((x) + 1)) \
												: \
													( (x) ? \
														((x) / ((x) - 1)) \
													: \
														(((x) + 1) / ((x) + 2)) \
													) \
											)
#else
#define JANUMBERLITERAL_IS_FLOAT_TYPE(n)	(__builtin_types_compatible_p(__typeof__(n), float) || \
											__builtin_types_compatible_p(__typeof__(n), double) || \
											__builtin_types_compatible_p(__typeof__(n), long double))
#endif



/*	JANUMBERLITERAL_DYNAMIC() is a non-evil macro to create an autoreleased
	NSNumber, choosing between integer and float types for you. If you want
	a $N() macro for real code, use this.
	
	See also: http://www.extinguishedscholar.com/wpglob/?p=346
*/

#ifdef __cplusplus
/*	Clean C++ implementation: use overloaded inlines to choose appropriate
	type. Unfortunately, the type promotion rules in C++ were defined by a
	rabid bonobo in heat, so we need these eight overrides to handle all
	fifteen native numerical types.
*/
inline NSNumber *JANumberLiteralMakeNSNumber(double n)  { return [NSNumber numberWithDouble:n]; }
inline NSNumber *JANumberLiteralMakeNSNumber(long double n)  { return [NSNumber numberWithDouble:n]; }
inline NSNumber *JANumberLiteralMakeNSNumber(int n)  { return [NSNumber numberWithInt:n]; }
inline NSNumber *JANumberLiteralMakeNSNumber(unsigned int n)  { return [NSNumber numberWithUnsignedInt:n]; }
inline NSNumber *JANumberLiteralMakeNSNumber(long n)  { return [NSNumber numberWithLong:n]; }
inline NSNumber *JANumberLiteralMakeNSNumber(unsigned long n)  { return [NSNumber numberWithUnsignedLong:n]; }
inline NSNumber *JANumberLiteralMakeNSNumber(long long n)  { return [NSNumber numberWithLongLong:n]; }
inline NSNumber *JANumberLiteralMakeNSNumber(unsigned long long n)  { return [NSNumber numberWithUnsignedLongLong:n]; }

#define JANUMBERLITERAL_DYNAMIC(n)			JANumberLiteralMakeNSNumber(n)
#else
#define JANUMBERLITERAL_DYNAMIC(n)			(JANUMBERLITERAL_IS_FLOAT_TYPE(n) ? \
												[NSNumber numberWithDouble:n] \
											:\
												[NSNumber numberWithLongLong:n] \
											)

#endif

/*	Apart from the other ways it's evil, this only works in the old fragile
	runtime.
*/
#if !defined(__OBJC2__)


/*	Get us some pointers to the class objects we need. These are declared as
	arrays because that lets them be constant expressions and external symbols
	at the same time (but only in C++).
	
	Normally, an identifier becomes a linker symbol by prefixing it with an
	underscore. The linker symbols for class objects are prefixed with dots
	instead, specifically so you can't refer to them as identifiers. We can
	get around this using the gcc asm label extension - that's section 5.37
	in the gcc 4.2 manual. Thanks to <sys/cdefs.h> for showing me the way.
 */
extern struct objc_class JAFloatLiteralClassObject		__asm__(".objc_class_name_JAFloatNumber");
extern struct objc_class JAIntegerLiteralClassObject	__asm__(".objc_class_name_JAIntegerNumber");


/*	These macros actually create our objects. NOTE: using these directly with
	non-constant expressions will break - the value will be overwritten.
*/
#define JANUMBERLITERAL_CONSTANT_FLOAT(n)	({ static const struct { Class isa; double value; } \
											object = { &JAFloatLiteralClassObject, (n) }; \
											(NSNumber *)&object; })
#define JANUMBERLITERAL_CONSTANT_INT(n)		({ static const struct { Class isa; long long value; } \
											object = { &JAIntegerLiteralClassObject, (n) }; \
											(NSNumber *)&object; })


/*	JANUMBERLITERAL_CONSTANT() calls  JANUMBERLITERAL_CONSTANT_FLOAT() or
	JANUMBERLITERAL_CONSTANT_INT(), whichever is appropriate.
*/
#define JANUMBERLITERAL_CONSTANT(n)			(JANUMBERLITERAL_IS_FLOAT_TYPE(n) ? \
												JANUMBERLITERAL_CONSTANT_FLOAT(n) \
											: \
												JANUMBERLITERAL_CONSTANT_INT(n) \
											)	


/*	Top-level macro $N() calls JANUMBERLITERAL_CONSTANT() for constants and
	JANUMBERLITERAL_DYNAMIC() for non-constants.
*/
#define $N(n)	(__builtin_constant_p(n) ? \
					JANUMBERLITERAL_CONSTANT(n) \
				: \
					JANUMBERLITERAL_DYNAMIC(n) \
				)

#else
/*	64-bit or iPhone runtime, or not Obj-C++ - object constant hack won't work.
	Always uses JANUMBERLITERAL_DYNAMIC().
*/

#warning JANumberLiteral only works in the old 32-bit runtime, falling back to sensible behaviour.

#define $N(n)	JANUMBERLITERAL_DYNAMIC(n)

#endif
