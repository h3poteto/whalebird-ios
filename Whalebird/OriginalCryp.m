//
//  RNEncryptor+OriginalCryp.m
//  Whalebird
//
//  Created by akirafukushima on 2014/12/17.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

#import "OriginalCryp.h"

@implementation OriginalCryp

+ (NSData *)encryptData:(NSData *)data password:(NSString *)password error:(NSError **)error {
    
    return [self encryptData:data withSettings:kRNCryptorAES256Settings password:password error:error];
}

+ (NSString *)stringFromData:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
