//
//  NSData+Hash.m
//  ZincWallet
//
//  Created by Aaron Voisine on 5/13/13.
//  Copyright (c) 2013 zinc. All rights reserved.
//

#import "NSData+Hash.h"
//#import "rmd160.h"
#import <CommonCrypto/CommonDigest.h>
#import <openssl/ripemd.h>

//#define RMDsize 160

@implementation NSData (Hash)

+ (instancetype)dataWithHex:(NSString *)hex
{
    return [[self alloc] initWithHex:hex];
}

- (instancetype)initWithHex:(NSString *)hex
{
    if (hex.length % 2) return nil;
        
    NSMutableData *d = [NSMutableData dataWithCapacity:hex.length/2];
    const char *s = [hex UTF8String];
    uint8_t b = 0;
        
    for (NSUInteger i = 0; i < hex.length; i++) {
        switch (s[i]) {
            case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':
                b += s[i] - '0';
                break;
            case 'A': case 'B': case 'C': case 'D': case 'E': case 'F':
                b += s[i] + 10 - 'A';
                break;
            case 'a': case 'b': case 'c': case 'd': case 'e': case 'f':
                b += s[i] + 10 - 'a';
                break;
            default:
                return [self initWithData:d];
        }
        
        if (i % 2) {
            [d appendBytes:&b length:1];
            b = 0;
        }
        else b *= 16;
    }
    
    return [self initWithData:d];
}

- (NSString *)toHex
{
    NSMutableString *hex = [NSMutableString stringWithCapacity:self.length*2];
    uint8_t *bytes = (uint8_t *)self.bytes;
    
    for (NSUInteger i = 0; i < self.length; i++) {
        [hex appendFormat:@"%02x", bytes[i]];
    }
    
    return hex;
}

- (NSData *)reverse
{
    size_t l = self.length;
    NSMutableData *d = [NSMutableData dataWithLength:l];
    uint8_t *b1 = d.mutableBytes;
    const uint8_t *b2 = self.bytes;
    
    for (size_t i = 0; i < l; i++) {
        b1[i] = b2[l - i - 1];
    }
    
    return d;
}

- (NSData *)RMD160
{
    // openssl implementation
    NSMutableData *d = [NSMutableData dataWithLength:RIPEMD160_DIGEST_LENGTH];

    RIPEMD160(self.bytes, self.length, d.mutableBytes);
    
    return d;
///////////////
//    // standalone rmd160.c implementation
//    byte*         message = (byte *)self.bytes;
//    dword         MDbuf[RMDsize/32];   /* contains (A, B, C, D(, E))   */
//    static byte   hashcode[RMDsize/8]; /* for final hash-value         */
//    dword         X[16];               /* current 16-word chunk        */
//    unsigned int  i;                   /* counter                      */
//    dword         length;              /* length in bytes of message   */
//    dword         nbytes;              /* # of bytes not yet processed */
//    
//    /* initialize */
//    MDinit(MDbuf);
//    length = (dword)self.length;
//        
//    /* process message in 16-word chunks */
//    for (nbytes=length; nbytes > 63; nbytes-=64) {
//        for (i=0; i<16; i++) {
//            X[i] = BYTES_TO_DWORD(message);
//            message += 4;
//        }
//        compress(MDbuf, X);
//    }                                    /* length mod 64 bytes left */
//        
//    /* finish: */
//    MDfinish(MDbuf, message, length, 0);
//        
//    for (i=0; i<RMDsize/8; i+=4) {
//        hashcode[i]   =  MDbuf[i>>2];         /* implicit cast to byte  */
//        hashcode[i+1] = (MDbuf[i>>2] >>  8);  /*  extracts the 8 least  */
//        hashcode[i+2] = (MDbuf[i>>2] >> 16);  /*  significant bits.     */
//        hashcode[i+3] = (MDbuf[i>>2] >> 24);
//    }
//    
//    return [NSData dataWithBytes:hashcode length:RMDsize/8];
}

- (NSData *)SHA256
{
    NSMutableData *d = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(self.bytes, self.length, d.mutableBytes);
    
    return d;
}

- (NSData *)SHA256_2
{
    NSMutableData *d = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(self.bytes, self.length, d.mutableBytes);
    CC_SHA256(d.bytes, d.length, d.mutableBytes);
    
    return d;
}

@end