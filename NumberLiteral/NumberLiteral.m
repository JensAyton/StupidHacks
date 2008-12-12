#import <Foundation/Foundation.h>
#import "JANumberLiteral.h"
#import "objc/objc.h"


static NSNumber *GetNumber(void);


int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSNumber *n = GetNumber();
	
	// Verify that toll-free bridging works
	long value;
	CFNumberGetValue((CFNumberRef)n, kCFNumberLongType, &value);
	
    NSLog(@"Hello, World! %@ = %li (%@)", n, value, [n class]);
	
    [pool drain];
    return 0;
}


static NSNumber *GetNumber(void)
{
	return $N(42.0);
}
