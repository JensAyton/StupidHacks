#import <Foundation/Foundation.h>
#import "SillyString.h"


int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    NSLog(@"%@", [@"Hello" : @", " : @"World!" : @"  " : [NSNumber numberWithInt:42]]);
	
    [pool drain];
    return 0;
}
