//
//  SecurityUtil.h
//  Smile
//
//  Created by 蒲晓涛 on 12-11-24.
//  Copyright (c) 2012年 BOX. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "SecurityUtil.h"
#import "GTMBase64.h"
#import "NSData+AES.h"
#import <CommonCrypto/CommonCryptor.h>


@implementation SecurityUtil

#pragma mark - base64

+ (NSString*)encodeBase64String:(NSString * )input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]; 
    data = [GTMBase64 encodeData:data]; 
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return base64String;
}

+ (NSString*)decodeBase64String:(NSString * )input { 
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]; 
    data = [GTMBase64 decodeData:data]; 
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return base64String;
}

+ (NSString*)encodeBase64Data:(NSData *)data {
	data = [GTMBase64 encodeData:data]; 
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return base64String;
}

+ (NSString*)decodeBase64Data:(NSData *)data {
	data = [GTMBase64 decodeData:data]; 
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return base64String;
}


#pragma mark - AES加密
//将string转成带密码的data
+(NSString*)encryptAESData:(NSString*)string app_key:(NSString*)key gIv:(NSString *)gIv
{
    //将nsstring转化为nsdata
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //使用密码对nsdata进行加密
    NSData *encryptedData = [data AES128EncryptWithKey:key gIv:gIv];
//    NSLog(@"加密后的字符串 :%@",[encryptedData base64Encoding]);
    
    return [encryptedData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


#pragma mark - AES解密
//将带密码的data转成string
+(NSString*)decryptAESData:(NSData*)data  app_key:(NSString*)key gIv:(NSString *)gIv
{
    //使用密码对data进行解密
    NSData *decryData = [data AES128DecryptWithKey:key gIv:gIv];
    //将解了密码的nsdata转化为nsstring
    NSString *str = [[NSString alloc] initWithData:decryData encoding:NSUTF8StringEncoding];
    return str;
}


+ (NSData *)AES128DecryptData:(NSData*)data key:(NSString *)key gIv:(NSString *)gIv {//解密
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [gIv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        NSData* data123= [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        return data123;
    }
    free(buffer);
    return nil;
}


// 将带密码的string转成string 解密
+(NSString*)decryptAESNString:(NSString *)str app_key:(NSString *)key gIv:(NSString *)gIv
{
    NSData *EncryptData1 = [GTMBase64 decodeString:str];
//    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
//    
//    
//    NSData *decryStr = [data AES128DecryptWithKey:key];
//    NSString *decryptStr = [[NSString alloc] initWithData:decryStr encoding:NSUTF8StringEncoding];
    
    NSData *decryData = [SecurityUtil AES128DecryptData:EncryptData1 key:key gIv:gIv];
    //将解了密码的nsdata转化为nsstring
    NSString *decryptStr = [[NSString alloc] initWithData:decryData encoding:NSUTF8StringEncoding];
    
    
    return decryptStr;

}


+(NSData*)decryptAESWithData:(NSData*)data  app_key:(NSString*)key gIv:(NSString *)gIv
{
    //使用密码对data进行解密
    NSData *decryData = [data AES128DecryptWithKey:key gIv:gIv];
    return decryData;
}


@end
