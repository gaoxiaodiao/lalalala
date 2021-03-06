//
//  SecT113R1Curve.m
//  
//
//  Created by Pallas on 5/31/16.
//
//  Complete

#import "SecT113R1Curve.h"
#import "SecT113R1Point.h"
#import "SecT113FieldElement.h"

#import "CategoryExtend.h"
#import "BigInteger.h"
#import "Hex.h"

@interface SecT113R1Curve ()

@property (nonatomic, readwrite, retain) SecT113R1Point *m_infinity;

@end

@implementation SecT113R1Curve
@synthesize m_infinity = _m_infinity;

static int const SecT113R1_DEFAULT_COORDS = COORD_LAMBDA_PROJECTIVE;

- (id)init {
    if (self = [super initWithM:113 withK1:9 withK2:0 withK3:0]) {
        @autoreleasepool {
            SecT113R1Point *tmpPoint = [[SecT113R1Point alloc] initWithCurve:self withX:nil withY:nil];
            [self setM_infinity:tmpPoint];
            BigInteger *tmpa = [[BigInteger alloc] initWithSign:1 withBytes:[Hex decodeWithString:@"003088250CA6E7C7FE649CE85820F7"]];
            [self setM_a:[self fromBigInteger:tmpa]];
            BigInteger *tmpb = [[BigInteger alloc] initWithSign:1 withBytes:[Hex decodeWithString:@"00E8BEE4D3E2260744188BE0E9C723"]];
            [self setM_b:[self fromBigInteger:tmpb]];
            BigInteger *tmporder = [[BigInteger alloc] initWithSign:1 withBytes:[Hex decodeWithString:@"0100000000000000D9CCEC8A39E56F"]];
            [self setM_order:tmporder];
#if !__has_feature(objc_arc)
            if (tmpPoint != nil) [tmpPoint release]; tmpPoint = nil;
            if (tmpa != nil) [tmpa release]; tmpa = nil;
            if (tmpb != nil) [tmpb release]; tmpb = nil;
            if (tmporder != nil) [tmporder release]; tmporder = nil;
#endif
            [self setM_cofactor:[BigInteger Two]];
            [self setM_coord:SecT113R1_DEFAULT_COORDS];            
        }
        return self;
    } else {
        return nil;
    }
}

- (void)dealloc {
#if !__has_feature(objc_arc)
    [self setM_infinity:nil];
    [super dealloc];
#endif
}

- (ECCurve*)cloneCurve {
    return [[[SecT113R1Curve alloc] init] autorelease];
}

- (BOOL)supportsCoordinateSystem:(int)coord {
    switch (coord) {
        case COORD_LAMBDA_PROJECTIVE: {
            return YES;
        }
        default: {
            return NO;
        }
    }
}

- (ECPoint*)infinity {
    return self.m_infinity;
}

- (int)fieldSize {
    return 113;
}

- (ECFieldElement*)fromBigInteger:(BigInteger*)x {
    return [[[SecT113FieldElement alloc] initWithBigInteger:x] autorelease];
}

- (ECPoint*)createRawPoint:(ECFieldElement*)x withY:(ECFieldElement*)y withCompression:(BOOL)withCompression {
    return [[[SecT113R1Point alloc] initWithCurve:self withX:x withY:y withCompression:withCompression] autorelease];
}

- (ECPoint*)createRawPoint:(ECFieldElement*)x withY:(ECFieldElement*)y withZS:(NSMutableArray*)zs withCompression:(BOOL)withCompression {
    return [[[SecT113R1Point alloc] initWithCurve:self withX:x withY:y withZS:zs withCompression:withCompression] autorelease];
}

- (BOOL)isKoblitz {
    return NO;
}

- (int)M {
    return 113;
}

- (BOOL)isTrinomial {
    return YES;
}

- (int)K1 {
    return 9;
}

- (int)K2 {
    return 0;
}

- (int)K3 {
    return 0;
}

@end
