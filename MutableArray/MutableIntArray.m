//
//  MutableArray.m
//  MutableArray
//
//  Created by andrius on 29.11.17.
//  Copyright © 2017 andrius. All rights reserved.
//

#import "MutableIntArray.h"

@interface MutableIntArray ()

@property (nonatomic) int * startPointer;
@property (nonatomic) NSUInteger size;
@property (nonatomic, readwrite) NSUInteger capacity;

@end

@implementation MutableIntArray

// MARK: - Properties -

- (NSUInteger)count {
    return self.size;
}

// MARK: - Initialization -

- (instancetype)init {
    return [self initWithCapacity:1];
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {

    if (0 == capacity) {
        NSAssert(NO, @"No ability to create array with zero capacity. Capacity '1' will be used instead.");
        capacity = 1;
        return nil;
    }
    self = [super init];
	
    if (self) {
        _startPointer = malloc(sizeof(int) * capacity);
        if (nil == _startPointer) {
            NSAssert(NO, @"Failed to allocate memory for an array");
            return nil;
        }
        _capacity = capacity;
        _size = 0;
    }
    return self;
}

// MARK: - Accessing elements at index -

- (int)objectAtIndex:(NSUInteger)index {
    if (index >= self.size) {
        NSString *exceptionReason = [NSString stringWithFormat:@"Attempt to access object with index %lu out of arrray bounds", index];
        [[NSException exceptionWithName:@"MutableIntArrayException"
                                 reason:exceptionReason
                               userInfo:nil]
         raise];
        return 0;
    }
    int *objectPtr = self.startPointer + index;
    return *objectPtr;
}

// MARK: - Adding objects -

- (void)addObject:(int)anInteger {
    if (self.size >= self.capacity) {
        if (NO == [self doubleArrayCapacity]) {
            NSString *exceptionReason = @"Failed to increase array capacity";
            [[NSException exceptionWithName:@"MutableIntArrayException"
                                     reason:exceptionReason
                                   userInfo:nil]
             raise];
            return;
        }
    }

    *(self.startPointer + self.size) = anInteger;

    self.size += 1;
}

- (void)insertObject:(int)anInteger
             atIndex:(NSUInteger)index {
    if (index > self.size) {
        NSString *exceptionReason = [NSString stringWithFormat:@"Attempt to access object with index %lu out of arrray bounds", index];
        [[NSException exceptionWithName:@"MutableIntArrayException"
                                 reason:exceptionReason
                               userInfo:nil]
         raise];
        return;
    }

    if (self.size >= self.capacity) {
        if (NO == [self doubleArrayCapacity]) {
            NSString *exceptionReason = @"Failed to increase array capacity";
            [[NSException exceptionWithName:@"MutableIntArrayException"
                                     reason:exceptionReason
                                   userInfo:nil]
             raise];
            return;
        }
    }
	
    if (index != self.size) {
        [self shiftArrayInMemoryFromIndex:index toIndex:index + 1];
    }

    *(self.startPointer + index) = anInteger;

    self.size += 1;
}

- (void)insertMutableIntArray:(MutableIntArray *)otherArray
                      atIndex:(NSUInteger)index {
    if (index > self.size) {
        NSString *exceptionReason = [NSString stringWithFormat:@"Attempt to access object with index %lu out of arrray bounds", index];
        [[NSException exceptionWithName:@"MutableIntArrayException"
                                 reason:exceptionReason
                               userInfo:nil]
         raise];
        return;
    }

    NSUInteger otherArrayElementsCount = otherArray.count;
	// не понял. Пустой добавить нельзя. А чего?
    NSParameterAssert(otherArrayElementsCount);

    NSUInteger const newSize = self.size + otherArrayElementsCount;
    if (newSize >= self.capacity) {
        if (NO == [self setArrayCapacityTo:newSize]) {
            NSString *exceptionReason = @"Failed to increase array capacity";
            [[NSException exceptionWithName:@"MutableIntArrayException"
                                     reason:exceptionReason
                                   userInfo:nil]
             raise];
            return;
        }
    }
    if (index != self.size) {
        [self shiftArrayInMemoryFromIndex:index toIndex:index + otherArrayElementsCount];
    }

    for (int i = 0; i < otherArrayElementsCount; ++i) {
        int integerInArray = [otherArray objectAtIndex:i];
        *(self.startPointer + i + index) = integerInArray;
    }
    self.size += otherArrayElementsCount;
}

// MARK: - Removing objects

- (void)removeObjectAtIndex:(NSUInteger)index {
    if (index > self.size) {
        NSString *exceptionReason = [NSString stringWithFormat:@"Attempt to access object with index %lu out of arrray bounds", index];
        [[NSException exceptionWithName:@"MutableIntArrayException"
                                 reason:exceptionReason
                               userInfo:nil]
         raise];
        return;
    }

    [self shiftArrayInMemoryFromIndex:index + 1
                              toIndex:index];
    self.size -= 1;
    if (self.size * 2 < self.capacity) {
        [self setArrayCapacityTo:self.capacity / 2];
    }
}

// MARK: - Resizing -

- (BOOL)doubleArrayCapacity {
    return [self setArrayCapacityTo:self.capacity * 2];
}

- (BOOL)setArrayCapacityTo:(NSUInteger)newCapacity {

    int *const newStartPointer = [self reallocateMemoryFromPointer:self.startPointer
                                                              size:newCapacity];

    if (nil == newStartPointer) {
        return NO;
    }

    self.startPointer = newStartPointer;
    self.capacity = newCapacity;
    return YES;
}

- (void)shiftArrayInMemoryFromIndex:(NSUInteger)sourceIndex
                            toIndex:(NSUInteger)destinationIndex {
    int *sourcePointer = self.startPointer + sourceIndex;
    int *destinationPointer = self.startPointer + destinationIndex;
    NSUInteger size = self.size - sourceIndex;

    [self moveDataFromPointer:sourcePointer
         toDestinationPointer:destinationPointer
                         size:size];
}

// MARK: - Working with memory -

- (BOOL)moveDataFromPointer:(int *)sourcePointer
       toDestinationPointer:(int *)destinationPointer
                       size:(NSUInteger)size {
    int *buffer = malloc(sizeof(int) * size);

    if (nil == buffer) {
        NSString *exceptionReason = [NSString stringWithFormat:@"Failed to allocate memory for buffer on attempt to move data"];
        [[NSException exceptionWithName:@"MutableIntArrayException"
                                 reason:exceptionReason
                               userInfo:nil]
         raise];
        return NO;
    }

    for (int i = 0; i < size; ++i) {
        *(buffer + i) = *(sourcePointer + i);
    }
    for (int i = 0; i < size; ++i) {
        *(destinationPointer + i) = *(buffer + i);
    }
    free(buffer);
    return YES;
}

- (int *)reallocateMemoryFromPointer:(int *)sourcePointer
                                size:(NSUInteger)size {
    int *destinationPointer = malloc(sizeof(int) * size);

    if (nil == destinationPointer) {
        NSString *exceptionReason = [NSString stringWithFormat:@"Failed to allocate memory for reallocating"];
        [[NSException exceptionWithName:@"MutableIntArrayException"
                                 reason:exceptionReason
                               userInfo:nil]
         raise];
        return nil;
    }

    if (NO == [self moveDataFromPointer:sourcePointer
                   toDestinationPointer:destinationPointer
                                   size:size]) {
        return nil;
    }
    free(sourcePointer);
    return destinationPointer;
}

// MARK: - Output -

- (NSString *)allItemsString {
    NSMutableString *allItemsString = [NSMutableString string];

    [allItemsString appendString:@"["];
    for (int i = 0 ; i < self.count; ++i) {
        NSString *integerString = [NSString stringWithFormat:@"%d", [self objectAtIndex:i]];
        [allItemsString appendString:integerString];
        if (i + 1 < self.count) {
            [allItemsString appendString:@", "];
        }
    }
    [allItemsString appendString:@"]"];

    return allItemsString;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"Arrray with capacity %lu and items count %lu:\n", self.capacity, self.count];
    [description appendString:self.allItemsString];
    return [description copy];
}
@end

