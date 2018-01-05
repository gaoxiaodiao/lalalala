//
//  Nat576.m
//  
//
//  Created by Pallas on 5/26/16.
//
//  Complete

#import "Nat576.h"
#import "CategoryExtend.h"
#import "BigInteger.h"
#import "Pack.h"

@implementation Nat576

// NSMutableArray == uint64_t[]
+ (void)copy64:(NSMutableArray*)x withZ:(NSMutableArray*)z {
    z[0] = x[0];
    z[1] = x[1];
    z[2] = x[2];
    z[3] = x[3];
    z[4] = x[4];
    z[5] = x[5];
    z[6] = x[6];
    z[7] = x[7];
    z[8] = x[8];
}

// return == uint64_t[9]
+ (NSMutableArray*)create64 {
    return [[NSMutableArray alloc] initWithSize:9];
}

// return == uint64_t[18]
+ (NSMutableArray*)createExt64 {
    return [[NSMutableArray alloc] initWithSize:18];
}

// NSMutableArray == uint64_t[]
+ (BOOL)eq64:(NSMutableArray*)x withY:(NSMutableArray*)y {
    for (int i = 8; i >= 0; --i) {
        if ([x[i] unsignedLongLongValue] != [y[i] unsignedLongLongValue]) {
            return NO;
        }
    }
    return YES;
}

// return == uint64_t[]
+ (NSMutableArray*)fromBigInteger64:(BigInteger*)x {
    if ([x signValue] < 0 || [x bitLength] > 576) {
        @throw [NSException exceptionWithName:@"Argument" reason:nil userInfo:nil];
    }
    
    NSMutableArray *z = nil;
    @autoreleasepool {
        z = [Nat576 create64];
        int i = 0;
        while ([x signValue] != 0) {
            z[i++] = @((uint64_t)[x longValue]);
            x = [x shiftRightWithN:64];
        }
    }
    return (z ? [z autorelease] : nil);
}

// NSMutableArray == uint64_t[]
+ (BOOL)isOne64:(NSMutableArray*)x {
    if ([x[0] unsignedLongLongValue] != 1UL) {
        return NO;
    }
    for (int i = 1; i < 9; ++i) {
        if ([x[i] unsignedLongLongValue] != 0UL) {
            return NO;
        }
    }
    return YES;
}

// NSMutableArray == uint64_t[]
+ (BOOL)isZero64:(NSMutableArray*)x {
    for (int i = 0; i < 9; ++i) {
        if ([x[i] unsignedLongLongValue] != 0UL) {
            return NO;
        }
    }
    return YES;
}

// NSMutableArray == uint64_t[]
+ (BigInteger*)toBigInteger64:(NSMutableArray*)x {
    BigInteger *retVal = nil;
    @autoreleasepool {
        NSMutableData *bs = [[NSMutableData alloc] initWithSize:72];
        for (int i = 0; i < 9; ++i) {
            uint64_t x_i = [x[i] unsignedLongLongValue];
            if (x_i != 0L) {
                [Pack UInt64_To_BE:x_i withBs:bs withOff:((8 - i) << 3)];
            }
        }
        retVal = [[BigInteger alloc] initWithSign:1 withBytes:bs];
#if !__has_feature(objc_arc)
        if (bs != nil) [bs release]; bs = nil;
#endif
        
    }
    return (retVal ? [retVal autorelease] : nil);
}

@end
