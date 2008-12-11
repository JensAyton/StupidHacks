#import <Foundation/Foundation.h>
#import "JANumberLiteral.h"
#import "objc/objc.h"


static NSNumber *GetNumber(void);


int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSNumber *n = GetNumber();
    NSLog(@"Hello, World! %@", n);
	
    [pool drain];
    return 0;
}


extern unsigned X;

static NSNumber *GetNumber(void)
{
	NSNumber *n = $N(42);
	return n;
}
