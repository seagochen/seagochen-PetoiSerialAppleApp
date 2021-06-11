//
//  Converter.m
//  ObjectiveApp
//
//  Created by Orlando Chen on 2021/3/24.
//

#import "Converter.h"


@implementation Converter

+(NSData*) cvtStringToData: (NSString*) str
{
    NSData *data = nil;
    
    if (str != nil) {
        data = [str dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        data = [[NSData init] initWithCString: "" encoding: NSUTF8StringEncoding];
    }
    
    return data;
};

+(NSString*) cvtDataToString: (NSData*) data
{
    NSString *str = nil;
    
    if (data != nil) {
        str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else {
        str = [[NSString alloc] initWithCString: "" encoding:NSUTF8StringEncoding];
    }
    
    return str;
};

// MARK: convert nsdata to ns
+(NSData*) cvtCStringToData :(char*) cstr length:(NSInteger) length
{
    NSData *data = nil;
    
    if (cstr != nil) {
        data = [[NSData alloc] initWithBytes:cstr length:length];
    } else {
        
        data = [[NSData alloc] init];
    }
    
    return data;
};

// MARK: convert nsdata to c string
+(char*) cvtDataToCString: (NSData*) data
{
    char* cstr = nil;
    
    if (data != nil) {
        cstr = (char*)calloc([data length] + 1, sizeof(char));
        memcpy(cstr, [data bytes], [data length]);
    } else {
        cstr = (char*)calloc(1, sizeof(char));
    }
   
    return cstr;
};


// MARK: convert c string to nsstring
+(NSString*) cvtCStringToString:(char*) cstr length: (NSInteger) length
{
    NSString* str = nil;
    
    if (cstr != nil) {
        str = [[NSString alloc] initWithBytes:cstr length:length encoding:NSUTF8StringEncoding];
    } else {
        str = [[NSString alloc] init];
    }
    
    return str;
}

// MARK: convert c byte array to nsdata
+(NSData*) cvtCBytesToData: (unsigned char*) bytes length: (NSInteger) length
{
    NSData* data = nil;
    
    if (bytes != nil) {
        data = [[NSData alloc] initWithBytes:bytes length:length];
    } else {
        
        data = [[NSData alloc] init];
    }
    
    return data;
};

// MARK:　convert nsdata to c byte array
+(unsigned char*) cvtDataToCBytes: (NSData*) data length: (NSInteger*) length_out
{
    unsigned char* bytes = (unsigned char*)[data bytes];
    *length_out = [data length];
    return bytes;
};

@end
