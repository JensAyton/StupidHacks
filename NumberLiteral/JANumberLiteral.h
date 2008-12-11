//
//  JANumberLiteral.h
//  NumberLiteral
//
//  Created by Jens Ayton on 2008-12-10.
//  Copyright 2008 Jens Ayton. All rights reserved.
//

#import <Foundation/Foundation.h>


extern int JAIntegerLiteralClassObject[] __asm(".objc_class_name_JAIntegerLiteralNumber");
extern int JAFloatLiteralClassObject[] __asm(".objc_class_name_JAFloatLiteralNumber");

#define $N(n)  (__builtin_constant_p(n) ? \
					({static NSNumber *result = \
						( (n) ? ((n) / (2 * (n))) : (((n) + 1) / 2) ) ? \
							(NSNumber *)&((struct { const int *isa; double value;}){ JAFloatLiteralClassObject, (n)}) \
						: \
							(NSNumber *)&((struct { const int *isa; long long value;}){ JAIntegerLiteralClassObject, (n)}) \
					; \
					result; }) \
				: \
					@"Not a constant!" )
						
