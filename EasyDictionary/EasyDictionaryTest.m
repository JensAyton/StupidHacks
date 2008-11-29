#import <Foundation/Foundation.h>


@interface NSDictionary (MyProperties)

@property (retain) NSString *stringProperty;
@property (retain) NSNumber *numberProperty;

@end


int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	dict.stringProperty = @"This is a string";
	dict.numberProperty = [NSNumber numberWithInt:42];
	
	NSLog(@"%@", dict);
	
    [pool drain];
    return 0;
}
