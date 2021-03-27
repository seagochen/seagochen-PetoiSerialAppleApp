//
//  DataBuffer.h
//  ObjectiveApp
//
//  Created by Orlando Chen on 2021/3/25.
//

#ifndef DataBuffer_h
#define DataBuffer_h

#import <Foundation/Foundation.h>

@interface DataBuffer : NSObject

- (id)init;

- (id)initWithCapacity: (NSInteger)capacity;

- (void)dealloc;

- (void)appendData: (NSData*)data;

- (NSData*)getBuffer;

- (NSInteger)getBufferSize;

- (NSInteger)getRestSize;

- (NSData*)tryGetToken;

+ (void)print: (NSData*)data;

@end


#endif /* DataBuffer_h */
