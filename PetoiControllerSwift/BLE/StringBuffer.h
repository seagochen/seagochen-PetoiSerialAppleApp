//
//  StringBuffer.h
//  PetoiControllerSwift
//
//  Created by Orlando Chen on 2021/4/1.
//

#ifndef StringBuffer_h
#define StringBuffer_h


#import <Foundation/Foundation.h>


@interface StringBuffer: NSObject

// MARK: 构造函数
- (id)init;

// MARK: 解构函数
- (void)dealloc;

// MARK
- (void)push: (NSString*) str;

// MARK
- (NSString*) pop;

// MARK
- (NSString*) batchStr: (BOOL)clean;

// MARK
- (NSInteger) size;

// MARK
- (BOOL) isEmpty;

// MARK
- (void)clear;

@end


#endif /* StringBuffer_h */
