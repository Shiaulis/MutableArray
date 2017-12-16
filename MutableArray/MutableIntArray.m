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

+ (instancetype)array {
    return [[MutableIntArray alloc] init];
}

+ (instancetype)initWithIntegers:(int *)integersPointer
                           count:(int)count {
    
    MutableIntArray *array = [[self class] array];
    
    for (int i = 0; i < count; ++i) {
        [array addObject:*(integersPointer + i)];
    }
    return array;
}

- (MutableIntArray *)sorted {
    return [self quickSortOfArray:self];
}

// MARK: - Accessing elements at index -

- (int)objectAtIndex:(NSUInteger)index {
    if (index >= self.size) {
        NSString *exceptionReason = [NSString stringWithFormat:@"Attempt to access object with index %lu out of arrray bounds", index];
        NSException *exception =
        [NSException
         exceptionWithName:@"MutableIntArrayException"
         reason:exceptionReason
         userInfo:nil];
        
        @throw exception;
    }
    int *objectPtr = self.startPointer + index;
    return *objectPtr;
}

// MARK: - Comparing arrays -

- (BOOL)compareArrayWithArray:(MutableIntArray *)comparingArray {
    if (comparingArray.count != self.count) {
        return NO;
    }
    for (int i = 0; i < self.count; ++i) {
        int elementAtCurrentArray = [self objectAtIndex:i];
        int elementAtComparingArray = [comparingArray objectAtIndex:i];
        if (elementAtCurrentArray != elementAtComparingArray) {
            return NO;
        }
    }
    return YES;
}

// MARK: - Adding objects -

- (void)addObject:(int)anInteger {
    if (self.size >= self.capacity) {
        [self setArrayCapacityTo:self.capacity * 2];
    }
    
    *(self.startPointer + self.size) = anInteger;
    
    self.size += 1;
}

- (void)addArray:(MutableIntArray *)addedArray {
    [self insertMutableIntArray:addedArray atIndex:self.count];
}

- (void)insertObject:(int)anInteger
             atIndex:(NSUInteger)index {
    if (index > self.size) {
        NSString *exceptionReason = [NSString stringWithFormat:@"Attempt to access object with index %lu out of arrray bounds", index];
        NSException *exception =
        [NSException
         exceptionWithName:@"MutableIntArrayException"
         reason:exceptionReason
         userInfo:nil];
        
        @throw exception;
    }
    
    if (self.size >= self.capacity) {
        [self setArrayCapacityTo:self.capacity * 2];
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
        NSException *exception =
        [NSException
         exceptionWithName:@"MutableIntArrayException"
         reason:exceptionReason
         userInfo:nil];
        
        @throw exception;
    }
    
    if (otherArray.count == 0) {
        return;
    }
    NSUInteger otherArrayElementsCount = otherArray.count;
    
    NSUInteger const newSize = self.size + otherArrayElementsCount;
    if (newSize >= self.capacity) {
        [self setArrayCapacityTo:newSize];
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
    if (index >= self.size) {
        NSString *exceptionReason = [NSString stringWithFormat:@"Attempt to access object with index %lu out of arrray bounds", index];
        NSException *exception =
        [NSException
         exceptionWithName:@"MutableIntArrayException"
         reason:exceptionReason
         userInfo:nil];
        
        @throw exception;
    }
    
    [self shiftArrayInMemoryFromIndex:index + 1
                              toIndex:index];
    self.size -= 1;
    if (self.size * 2 < self.capacity) {
        [self setArrayCapacityTo:self.capacity / 2];
    }
}

// MARK: - Resizing -

- (void)setArrayCapacityTo:(NSUInteger)newCapacity {
    
    int *const newStartPointer =
    [self
     reallocateMemoryFromPointer:self.startPointer
     sourceSize:self.capacity
     destinationSize:newCapacity];
    
    if (nil == newStartPointer) {
        NSString *exceptionReason = @"Failed to increase array capacity";
        NSException *exception =
        [NSException
         exceptionWithName:@"MutableIntArrayException"
         reason:exceptionReason
         userInfo:nil];
        
        @throw exception;
    }
    
    self.startPointer = newStartPointer;
    self.capacity = newCapacity;
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

    int *sourceEndPointer = sourcePointer + (size - 1);
    int *destinationEndPointer = destinationPointer + (size - 1);

    if (destinationPointer > sourcePointer &&
             destinationPointer <= sourceEndPointer) {
        // source memory      __@##########______________
        // destination memory ___________@##########_____
        for (int i = 0; i < size; ++i) {
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
        for (int i = 0; i < size; ++i) {
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

- (MutableIntArray *)quickSortOfArray:(MutableIntArray *)array {
    if (array.count < 2) {
        return array;
    }
    int const pivot = [array objectAtIndex:0];
    MutableIntArray *lessArray = [MutableIntArray array];
    MutableIntArray *greaterArray = [MutableIntArray array];
    for (int i = 1; i < array.count; ++i) {
        int const elementAtIndex = [array objectAtIndex:i];
        if (elementAtIndex <= pivot) {
            [lessArray addObject:elementAtIndex];
        }
        else {
            [greaterArray addObject:elementAtIndex];
        }
    }

    MutableIntArray *resultArray = [self quickSortOfArray:lessArray];
    [resultArray addObject:pivot];
    [resultArray addArray:[self quickSortOfArray:greaterArray]];
    return resultArray;
}

@end

