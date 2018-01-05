//
//  KISAObjectIdentifiers.m
//  crypto
//
//  Created by JGehry on 6/13/16.
//  Copyright (c) 2016 pallas. All rights reserved.
//

#import "KISAObjectIdentifiers.h"

@implementation KISAObjectIdentifiers

+ (ASN1ObjectIdentifier *)id_seedCBC {
    static ASN1ObjectIdentifier *_id_seedCBC = nil;
    @synchronized(self) {
        if (!_id_seedCBC) {
            _id_seedCBC = [[ASN1ObjectIdentifier alloc] initParamString:@"1.2.410.200004.1.4"];
        }
    }
    return _id_seedCBC;
}

+ (ASN1ObjectIdentifier *)id_seedMAC {
    static ASN1ObjectIdentifier *_id_seedMAC = nil;
    @synchronized(self) {
        if (!_id_seedMAC) {
            _id_seedMAC = [[ASN1ObjectIdentifier alloc] initParamString:@"1.2.410.200004.1.7"];
        }
    }
    return _id_seedMAC;
}

+ (ASN1ObjectIdentifier *)pbeWithSHA1AndSEED_CBC {
    static ASN1ObjectIdentifier *_pbeWithSHA1AndSEED_CBC = nil;
    @synchronized(self) {
        if (!_pbeWithSHA1AndSEED_CBC) {
            _pbeWithSHA1AndSEED_CBC = [[ASN1ObjectIdentifier alloc] initParamString:@"1.2.410.200004.1.15"];
        }
    }
    return _pbeWithSHA1AndSEED_CBC;
}

+ (ASN1ObjectIdentifier *)id_npki_app_cmsSeed_wrap {
    static ASN1ObjectIdentifier *_id_npki_app_cmsSeed_wrap = nil;
    @synchronized(self) {
        if (!_id_npki_app_cmsSeed_wrap) {
            _id_npki_app_cmsSeed_wrap = [[ASN1ObjectIdentifier alloc] initParamString:@"1.2.410.200004.7.1.1.1"];
        }
    }
    return _id_npki_app_cmsSeed_wrap;
}

+ (ASN1ObjectIdentifier *)id_mod_cms_seed {
    static ASN1ObjectIdentifier *_id_mod_cms_seed = nil;
    @synchronized(self) {
        if (!_id_mod_cms_seed) {
            _id_mod_cms_seed = [[ASN1ObjectIdentifier alloc] initParamString:@"1.2.840.113549.1.9.16.0.24"];
        }
    }
    return _id_mod_cms_seed;
}

@end
