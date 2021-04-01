//
//  Converter.h
//  ObjectiveApp
//
//  Created by Orlando Chen on 2021/3/24.
//

#ifndef Converter_h
#define Converter_h

#import <Foundation/Foundation.h>

@interface Converter : NSObject

// MARK: convert nsstring to nsdata
+ (NSData*)cvtStringToData:(NSString*) str;

// MARK: convert nsdata to nsstring
+ (NSString*)cvtDataToString:(NSData*) data;

// MARK: convert c string to nsdata
+ (NSData*)cvtCStringToData:(char*) cstr length: (NSInteger) length;

// MARK: convert nsdata to c string
+ (char*)cvtDataToCString:(NSData*) data;

// MARK: convert c string to nsstring
+ (NSString*)cvtCStringToString:(char*) cstr length: (NSInteger) length;

// MARK: convert c byte array to nsdata
+ (NSData*)cvtCBytesToData: (unsigned char*) bytes length: (NSInteger) length;

// MARK:　convert nsdata to c byte array
+ (unsigned char*)cvtDataToCBytes: (NSData*) data length: (NSInteger*) length_out;

@end


#endif /* Converter_h */
