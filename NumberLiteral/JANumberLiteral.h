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
	
	struct JAFloatLiteralDefs { const int *isa; double value; };
	static NSNumber *number = (NSNumber *)&((struct JAFloatLiteralDefs){JAFloatLiteralClassObject, 42.0});
	
	The "static" here is critical; without it, the object would be built on
	the stack and be invalidated when your function or method returned. The
	JANUMBERLITERAL_CONSTANT() hides this for you by creating the static
	variable in an inner scope and returning a pointer to it.
	
	The initializer for a static variable must be a constant expression. The
	isa field is made a constant expression by using a quirk of the C++ type
	system (there are so many...) which was inspired by a weird gcc error
	message and some digging around in clang source. The value field is a
	constant expression if the parameter to the macro is. The top level macro,
	$N(), will recognize non-constant expressions and create autoreleased
	NSNumbers for them instead of using JANUMBERLITERAL_CONSTANT().
	
	(Note: there is a long-standing "bug" in gcc which causes it to think all
	expressions that are known constants at compile time are constant
	expressions. This isn't strictly true, but has no negative effects; it
	just means that things like $N(x-x) generate constants even though the C
	specification doesn't classify x-x as a constant expression.)
*/

#import <Foundation/Foundation.h>


/*	Determine whether a number is a float or an int by natevw. NOTE: this
	evaluates its argument multiple times and is thus side-effect free.
	This is OK as long as it's only used on known constant expressions, as is
	the case in this header.
*/
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

/*	JANUMBERLITERAL_IS_FLOAT_TYPE_2() tells us whether an expression has
	floating-point type without evaluating it and is always constant-foldable.
	Unfortunately it's not available in C++, becuase hey, we've got the
	convenience of overloading (see above).
*/
#define JANUMBERLITERAL_IS_FLOAT_TYPE_2(n)	(__builtin_types_compatible_p(__typeof__(n), float) || \
											__builtin_types_compatible_p(__typeof__(n), double) || \
											__builtin_types_compatible_p(__typeof__(n), long double))

#define JANUMBERLITERAL_DYNAMIC(n)			(JANUMBERLITERAL_IS_FLOAT_TYPE_2(n) ? \
												[NSNumber numberWithDouble:n] \
											:\
												[NSNumber numberWithLongLong:n] \
											)

#endif

/*	Apart from the other ways it's evil, this only works in the old fragile
	runtime, and only in Objective-C++.
*/
#if !defined(__OBJC2__) && defined(__cplusplus)


/*	Get us some pointers to the class objects we need. These are declared as
	arrays because that lets them be constant expressions and external symbols
	at the same time (but only in C++).
	
	Normally, an identifier becomes a linker symbol by prefixing it with an
	underscore. The linker symbols for class objects are prefixed with dots
	instead, specifically so you can't refer to them as identifiers. We can
	get around this using the gcc asm label extension - that's section 5.37
	in the gcc 4.2 manual. Thanks to <sys/cdefs.h> for showing me the way.
 */
extern int JAFloatLiteralClassObject[]		__asm__(".objc_class_name_JAFloatNumber");
extern int JAIntegerLiteralClassObject[]	__asm__(".objc_class_name_JAIntegerNumber");


/*	These macros actually create our objects. NOTE: the result of these MUST
	be assigned to a static pointer. JANUMBERLITERAL_CONSTANT() does this for
	you.
*/
#define JANUMBERLITERAL_CONSTANT_FLOAT(n)	((NSNumber *)&((struct {const int *isa; double value;}){JAFloatLiteralClassObject, (n)}))
#define JANUMBERLITERAL_CONSTANT_INT(n)		((NSNumber *)&((struct {const int *isa; long long value;}){JAIntegerLiteralClassObject, (n)}))


/*	JANUMBERLITERAL_CONSTANT() calls  JANUMBERLITERAL_CONSTANT_FLOAT() or
	JANUMBERLITERAL_CONSTANT_INT(), whichever is appropriate, assigns the
	result to a static variable so that it doesn't evaporate, and returns
	the value.
*/
#define JANUMBERLITERAL_CONSTANT(n)			({static NSNumber *result = \
											(JANUMBERLITERAL_IS_FLOAT_TYPE(n) ? \
												JANUMBERLITERAL_CONSTANT_FLOAT(n) \
											: \
												JANUMBERLITERAL_CONSTANT_INT(n) \
											); \
											result; })	


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
	Always use JANUMBERLITERAL_DYNAMIC().
*/

#warning JANumberLiteral only works in Objective-C++ in the old 32-bit runtime, falling back to sensible behaviour.

#define $N(n)	JANUMBERLITERAL_DYNAMIC(n)

#endif
