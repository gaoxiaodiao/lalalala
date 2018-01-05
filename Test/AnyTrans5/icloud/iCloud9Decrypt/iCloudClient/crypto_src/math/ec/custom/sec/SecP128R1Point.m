//
//  SecP128R1Point.m
//  
//
//  Created by Pallas on 5/31/16.
//
//  Complete

#import "SecP128R1Point.h"
#import "ECCurve.h"
#import "SecP128R1FieldElement.h"
#import "SecP128R1Field.h"
#import "Nat128.h"
#import "Nat.h"

@implementation SecP128R1Point

/**
 * Create a point which encodes with point compression.
 *
 * @param curve
 *            the curve to use
 * @param x
 *            affine x co-ordinate
 * @param y
 *            affine y co-ordinate
 *
 * @deprecated Use ECCurve.createPoint to construct points
 */
- (id)initWithCurve:(ECCurve*)curve withX:(ECFieldElement*)x withY:(ECFieldElement*)y {
    if (self = [super initWithCurve:curve withX:x withY:y withCompression:NO]) {
        return self;
    } else {
        return nil;
    }
}

/**
 * Create a point that encodes with or without point compresion.
 *
 * @param curve
 *            the curve to use
 * @param x
 *            affine x co-ordinate
 * @param y
 *            affine y co-ordinate
 * @param withCompression
 *            if true encode with point compression
 *
 * @deprecated per-point compression property will be removed, refer
 *             {@link #getEncoded(boolean)}
 */
- (id)initWithCurve:(ECCurve*)curve withX:(ECFieldElement*)x withY:(ECFieldElement*)y withCompression:(BOOL)withCompression {
    if (self = [super initWithCurve:curve withX:x withY:y withCompression:withCompression]) {
        if ((x == nil) != (y == nil)) {
            @throw [NSException exceptionWithName:@"Argument" reason:@"Exactly one of the field elements is nil" userInfo:nil];
#if !__has_feature(objc_arc)
            [self release];
#endif
            return nil;
        }
        return self;
    } else {
        return nil;
    }
}

- (id)initWithCurve:(ECCurve*)curve withX:(ECFieldElement*)x withY:(ECFieldElement*)y withZS:(NSMutableArray*)zs withCompression:(BOOL)withCompression {
    if (self = [super initWithCurve:curve withX:x withY:y withZS:zs withCompression:withCompression]) {
        return self;
    } else {
        return nil;
    }
}

- (ECPoint*)detach {
    return [[[SecP128R1Point alloc] initWithCurve:nil withX:[self affineXCoord] withY:[self affineYCoord]] autorelease];
}

- (ECPoint*)add:(ECPoint*)b {
    if ([self isInfinity]) {
        return b;
    }
    if ([b isInfinity]) {
        return self;
    }
    if (self == b) {
        return [self twice];
    }
    
    ECPoint *retPoint = nil;
    @autoreleasepool {
        ECCurve *curve = [self curve];
        
        SecP128R1FieldElement *X1 = (SecP128R1FieldElement*)[self rawXCoord], *Y1 = (SecP128R1FieldElement*)[self rawYCoord];
        SecP128R1FieldElement *X2 = (SecP128R1FieldElement*)[b rawXCoord], *Y2 = (SecP128R1FieldElement*)[b rawYCoord];
        
        SecP128R1FieldElement *Z1 = (SecP128R1FieldElement*)([self rawZCoords][0]);
        SecP128R1FieldElement *Z2 = (SecP128R1FieldElement*)([b rawZCoords][0]);
        
        uint c;
        NSMutableArray *tt1 = [Nat128 createExt];
        NSMutableArray *t2 = [Nat128 create];
        NSMutableArray *t3 = [Nat128 create];
        NSMutableArray *t4 = [Nat128 create];
        
        BOOL Z1IsOne = [Z1 isOne];
        NSMutableArray *U2, *S2;
        if (Z1IsOne) {
            U2 = X2.x;
            S2 = Y2.x;
        } else {
            S2 = t3;
            [SecP128R1Field square:Z1.x withZ:S2];
            
            U2 = t2;
            [SecP128R1Field multiply:S2 withY:X2.x withZ:U2];
            
            [SecP128R1Field multiply:S2 withY:Z1.x withZ:S2];
            [SecP128R1Field multiply:S2 withY:Y2.x withZ:S2];
        }
        
        BOOL Z2IsOne = [Z2 isOne];
        NSMutableArray *U1, *S1;
        if (Z2IsOne) {
            U1 = X1.x;
            S1 = Y1.x;
        } else {
            S1 = t4;
            [SecP128R1Field square:Z2.x withZ:S1];
            
            U1 = tt1;
            [SecP128R1Field multiply:S1 withY:X1.x withZ:U1];
            
            [SecP128R1Field multiply:S1 withY:Z2.x withZ:S1];
            [SecP128R1Field multiply:S1 withY:Y1.x withZ:S1];
        }
        
        NSMutableArray *H = [Nat128 create];
        [SecP128R1Field subtract:U1 withY:U2 withZ:H];
        
        NSMutableArray *R = t2;
        [SecP128R1Field subtract:S1 withY:S2 withZ:R];
        
        // Check if b == this or b == -this
        if ([Nat128 isZero:H]) {
            if ([Nat128 isZero:R]) {
                // this == b, i.e. this must be doubled
#if !__has_feature(objc_arc)
                if (tt1) [tt1 release]; tt1 = nil;
                if (t2) [t2 release]; t2 = nil;
                if (t3) [t3 release]; t3 = nil;
                if (t4) [t4 release]; t4 = nil;
                if (H) [H release]; H = nil;
#endif
                retPoint = [self twice];
            } else {
                // this == -b, i.e. the result is the point at infinity
#if !__has_feature(objc_arc)
                if (tt1) [tt1 release]; tt1 = nil;
                if (t2) [t2 release]; t2 = nil;
                if (t3) [t3 release]; t3 = nil;
                if (t4) [t4 release]; t4 = nil;
                if (H) [H release]; H = nil;
#endif
                retPoint = [curve infinity];
            }
        } else {
            NSMutableArray *HSquared = t3;
            [SecP128R1Field square:H withZ:HSquared];
            
            NSMutableArray *G = [Nat128 create];
            [SecP128R1Field multiply:HSquared withY:H withZ:G];
            
            NSMutableArray *V = t3;
            [SecP128R1Field multiply:HSquared withY:U1 withZ:V];
            
            [SecP128R1Field negate:G withZ:G];
            [Nat128 mul:S1 withY:G withZZ:tt1];
            
            c = [Nat128 addBothTo:V withY:V withZ:G];
            [SecP128R1Field reduce32:c withZ:G];
            
            SecP128R1FieldElement *X3 = [[SecP128R1FieldElement alloc] initWithUintArray:t4];
            [SecP128R1Field square:R withZ:X3.x];
            [SecP128R1Field subtract:X3.x withY:G withZ:X3.x];
            
            SecP128R1FieldElement *Y3 = [[SecP128R1FieldElement alloc] initWithUintArray:G];
            [SecP128R1Field subtract:V withY:X3.x withZ:Y3.x];
            [SecP128R1Field multiplyAddToExt:Y3.x withY:R withZZ:tt1];
            [SecP128R1Field reduce:tt1 withZ:Y3.x];
            
            SecP128R1FieldElement *Z3 = [[SecP128R1FieldElement alloc] initWithUintArray:H];
            if (!Z1IsOne) {
                [SecP128R1Field multiply:Z3.x withY:Z1.x withZ:Z3.x];
            }
            if (!Z2IsOne) {
                [SecP128R1Field multiply:Z3.x withY:Z2.x withZ:Z3.x];
            }
            
            NSMutableArray *zs = [[NSMutableArray alloc] initWithObjects:Z3, nil];
            retPoint = [[[SecP128R1Point alloc] initWithCurve:curve withX:X3 withY:Y3 withZS:zs withCompression:self.isCompressed] autorelease];
#if !__has_feature(objc_arc)
            if (X3 != nil) [X3 release]; X3 = nil;
            if (Y3 != nil) [Y3 release]; Y3 = nil;
            if (Z3 != nil) [Z3 release]; Z3 = nil;
            if (zs != nil) [zs release]; zs = nil;
            if (tt1) [tt1 release]; tt1 = nil;
            if (t2) [t2 release]; t2 = nil;
            if (t3) [t3 release]; t3 = nil;
            if (t4) [t4 release]; t4 = nil;
            if (H) [H release]; H = nil;
            if (G) [G release]; G = nil;
#endif
        }
        
        [retPoint retain];
    }
    return (retPoint ? [retPoint autorelease] : nil);
}

- (ECPoint*)twice {
    if ([self isInfinity]) {
        return self;
    }
    
    ECCurve *curve = [self curve];
    
    SecP128R1FieldElement *Y1 = (SecP128R1FieldElement*)[self rawYCoord];
    if ([Y1 isZero]) {
        return [curve infinity];
    }
    
    SecP128R1Point *retVal = nil;
    @autoreleasepool {
        SecP128R1FieldElement *X1 = (SecP128R1FieldElement*)[self rawXCoord], *Z1 = (SecP128R1FieldElement*)([self rawZCoords][0]);
        
        uint c;
        NSMutableArray *t1 = [Nat128 create];
        NSMutableArray *t2 = [Nat128 create];
        
        NSMutableArray *Y1Squared = [Nat128 create];
        [SecP128R1Field square:Y1.x withZ:Y1Squared];
        
        NSMutableArray *T = [Nat128 create];
        [SecP128R1Field square:Y1Squared withZ:T];
        
        BOOL Z1IsOne = [Z1 isOne];
        
        NSMutableArray *Z1Squared = Z1.x;
        if (!Z1IsOne) {
            Z1Squared = t2;
            [SecP128R1Field square:Z1.x withZ:Z1Squared];
        }
        
        [SecP128R1Field subtract:X1.x withY:Z1Squared withZ:t1];
        
        NSMutableArray *M = t2;
        [SecP128R1Field add:X1.x withY:Z1Squared withZ:M];
        [SecP128R1Field multiply:M withY:t1 withZ:M];
        c = [Nat128 addBothTo:M withY:M withZ:M];
        [SecP128R1Field reduce32:c withZ:M];
        
        NSMutableArray *S = Y1Squared;
        [SecP128R1Field multiply:Y1Squared withY:X1.x withZ:S];
        c = [Nat shiftUpBit:4 withZ:S withZoff:2 withC:0];
        [SecP128R1Field reduce32:c withZ:S];
        
        c = [Nat shiftUpBits:4 withX:T withBits:3 withC:0 withZ:t1];
        [SecP128R1Field reduce32:c withZ:t1];
        
        SecP128R1FieldElement *X3 = [[SecP128R1FieldElement alloc] initWithUintArray:T];
        [SecP128R1Field square:M withZ:X3.x];
        [SecP128R1Field subtract:X3.x withY:S withZ:X3.x];
        [SecP128R1Field subtract:X3.x withY:S withZ:X3.x];
        
        SecP128R1FieldElement *Y3 = [[SecP128R1FieldElement alloc] initWithUintArray:S];
        [SecP128R1Field subtract:S withY:X3.x withZ:Y3.x];
        [SecP128R1Field multiply:Y3.x withY:M withZ:Y3.x];
        [SecP128R1Field subtract:Y3.x withY:t1 withZ:Y3.x];
        
        SecP128R1FieldElement *Z3 = [[SecP128R1FieldElement alloc] initWithUintArray:M];
        [SecP128R1Field twice:Y1.x withZ:Z3.x];
        if (!Z1IsOne) {
            [SecP128R1Field multiply:Z3.x withY:Z1.x withZ:Z3.x];
        }
        
        NSMutableArray *zs = [[NSMutableArray alloc] initWithObjects:Z3, nil];
        retVal = [[SecP128R1Point alloc] initWithCurve:curve withX:X3 withY:Y3 withZS:zs withCompression:self.isCompressed];
#if !__has_feature(objc_arc)
        if (X3 != nil) [X3 release]; X3 = nil;
        if (Y3 != nil) [Y3 release]; Y3 = nil;
        if (Z3 != nil) [Z3 release]; Z3 = nil;
        if (zs != nil) [zs release]; zs = nil;
        if (t1) [t1 release]; t1 = nil;
        if (t2) [t2 release]; t2 = nil;
        if (Y1Squared) [Y1Squared release]; Y1Squared = nil;
        if (T) [T release]; T = nil;
#endif
    }
    return (retVal ? [retVal autorelease] : nil);
}

- (ECPoint*)twicePlus:(ECPoint*)b {
    if (self == b) {
        return [self threeTimes];
    }
    if ([self isInfinity]) {
        return b;
    }
    if ([b isInfinity]) {
        return [self twice];
    }
    
    ECFieldElement *Y1 = [self rawYCoord];
    if ([Y1 isZero]) {
        return b;
    }
    ECPoint *retPoint = nil;
    @autoreleasepool {
        retPoint = [[self twice] add:b];
        [retPoint retain];
    }
    return (retPoint ? [retPoint autorelease] : nil);
}

- (ECPoint*)threeTimes {
    if ([self isInfinity] || [[self rawYCoord] isZero]) {
        return self;
    }
    
    ECPoint *retPoint = nil;
    @autoreleasepool {
        // NOTE: Be careful about recursions between twicePlus and threeTimes
        retPoint = [[self twice] add:self];
        [retPoint retain];
    }
    return (retPoint ? [retPoint autorelease] : nil);
}

- (ECPoint*)negate {
    if ([self isInfinity]) {
        return self;
    }
    
    ECPoint *retPoint = nil;
    @autoreleasepool {
        retPoint = [[SecP128R1Point alloc] initWithCurve:[self curve] withX:[self rawXCoord] withY:[[self rawYCoord] negate] withZS:[self rawZCoords] withCompression:[self isCompressed]];
    }
    return (retPoint ? [retPoint autorelease] : nil);
}

@end
