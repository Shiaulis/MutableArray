//
//  MutableArray.h
//  MutableArray
//
//  Created by andrius on 29.11.17.
//  Copyright © 2017 andrius. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MutableIntArray : NSObject

@property (nonatomic, readonly) NSUInteger capacity;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) MutableIntArray *sorted;

- (instancetype)initWithCapacity:(NSUInteger)numItems;

- (int)objectAtIndex:(NSUInteger)index;

- (BOOL)compareArrayWithArray:(MutableIntArray *)array;

- (void)insertObject:(int)anInteger
             atIndex:(NSUInteger)index;

- (void)addObject:(int)anObject;

- (void)addArray:(MutableIntArray *)array;

- (void)insertMutableIntArray:(MutableIntArray *)anIntArray
                      atIndex:(NSUInteger)index;

- (void)removeObjectAtIndex:(NSUInteger)index;

+ (instancetype)array;

+ (instancetype)initWithIntegers:(int *)integersPointer
                           count:(int)count;

@end
