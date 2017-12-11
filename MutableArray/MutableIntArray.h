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

- (instancetype)initWithCapacity:(NSUInteger)numItems;

- (int)objectAtIndex:(NSUInteger)index;

- (void)insertObject:(int)anInteger
             atIndex:(NSUInteger)index;

- (void)addObject:(int)anObject;

- (void)insertMutableIntArray:(MutableIntArray *)anIntArray
                      atIndex:(NSUInteger)index;

- (void)removeObjectAtIndex:(NSUInteger)index;

- (NSString *)allItemsString;

@end
