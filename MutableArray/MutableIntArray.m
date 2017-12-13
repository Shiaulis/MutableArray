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
        capacity = 1;
    }
    self = [super init];
    
    if (self) {
        _startPointer = malloc(sizeof(int) * capacity);
        if (nil == _startPointer) {
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
        // I would use @throw and remove redundand return 0;
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
            // 1. again, I would just throw and remove return
            // throw automatically exits this function and rolls back until it is processed in a catch,
            // or the default handler is reached (crash)
            //
            // 2. I would place the throw in doubleArrayCapacity and don't duplicate the code
            //
            // 3. I would prefer not to mention current increase size strategy (double)
            //    in method name. When you decide to use 1.4 instead of 2, would you rename the method?
            //
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
    // still don't understand
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
    // must be >= here
    // copy/paste programing
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
                                                        sourceSize:self.capacity
                                                   destinationSize:newCapacity];
    
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

- (void)moveDataFromPointer:(int *)sourcePointer
       toDestinationPointer:(int *)destinationPointer
                       size:(NSUInteger)size {
    if (sourcePointer == destinationPointer) {
        return;
    }

    int *sourceEndPointer = sourcePointer + sizeof(int) * (size - 1);
    int *destinationEndPointer = destinationPointer + sizeof(int) * (size - 1);

    if (destinationPointer > sourcePointer &&
             destinationPointer <= sourceEndPointer) {
        // source memory      __@##########______________
        // destination memory ___________@##########_____
        for (int i = 0; i < size * sizeof(int); ++i) {
            *(destinationEndPointer - i) = *(sourceEndPointer - i);
        }
    }
    else {
        // source memory      __@##########______________
        // destination memory ________________@##########
        // or
        // source memory      ________________@##########
        // destination memory __@##########______________
        // or
        // source memory      ___________@##########_____
        // destination memory __@##########______________
        for (int i = 0; i < size * sizeof(int); ++i) {
            *(destinationPointer + i) = *(sourcePointer + i);
        }
    }
    return;
}

- (int *)reallocateMemoryFromPointer:(int *)sourcePointer
                          sourceSize:(NSUInteger)sourceSize
                     destinationSize:(NSUInteger)destinationSize {
    int *destinationPointer = malloc(sizeof(int) * destinationSize);
    
    if (nil == destinationPointer) {
        NSString *exceptionReason = [NSString stringWithFormat:@"Failed to allocate memory for reallocating"];
        [[NSException exceptionWithName:@"MutableIntArrayException"
                                 reason:exceptionReason
                               userInfo:nil]
         raise];
        return nil;
    }
    [self moveDataFromPointer:sourcePointer
         toDestinationPointer:destinationPointer
                         size:sourceSize];
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

