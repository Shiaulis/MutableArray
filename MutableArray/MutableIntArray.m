//
//  MutableArray.m
//  MutableArray
//
//  Created by andrius on 29.11.17.
//  Copyright © 2017 andrius. All rights reserved.
//

#import "MutableIntArray.h"
#import "MutableIntArray+Private.h"

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

- (MutableIntArray *)sortedByQuickSort {
    return [self quickSortOfArray:self];
}

- (MutableIntArray *)sortedBySelectionSort {
    return [self selectionSortOfArray:self];
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
    NSCAssert(self.size <= self.capacity, @"Case when size bigger than capacity should be eliminated");
    if (self.size == self.capacity) {
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

    NSCAssert(self.size <= self.capacity, @"Case when size bigger than capacity should be eliminated");
    if (self.size == self.capacity) {
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
    const NSUInteger otherArrayElementsCount = otherArray.count;
    
    const NSUInteger newSize = self.size + otherArrayElementsCount;
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
    
    int *newStartPointer =
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

    const int *sourceEndPointer = sourcePointer + (size - 1);
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

// MARK: - Sorting -

- (MutableIntArray *)quickSortOfArray:(MutableIntArray *)array {
    if (array.count < 2) {
        return array;
    }
    const int randomIndex = arc4random_uniform((int)array.count);
    const int pivot = [array objectAtIndex:randomIndex];
    MutableIntArray *lessArray = [MutableIntArray array];
    MutableIntArray *greaterArray = [MutableIntArray array];
    for (int i = 0; i < array.count; ++i) {
        if (i == randomIndex) {
            continue;
        }
        int const elementAtIndex = [array objectAtIndex:i];
        if (elementAtIndex < pivot) {
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

- (int)findIndexOfSmallestElementInArray:(MutableIntArray *)array {
    if (array.count == 0) {
        return 0;
    }

    if (array.count == 1) {
        return 0;
    }
    int indexOfSmallestElement = 0;
    int smallestElement = [array objectAtIndex:indexOfSmallestElement];

    for (int i = 1; i < array.count; ++i) {
        const int integerAtIndex = [array objectAtIndex:i];
        if (integerAtIndex < smallestElement) {
            smallestElement = integerAtIndex;
            indexOfSmallestElement = i;
        }
    }
    return indexOfSmallestElement;
}

- (MutableIntArray *)selectionSortOfArray:(MutableIntArray *)array {

    if (array.count < 2) {
        return array;
    }
    MutableIntArray *sortedArray = [MutableIntArray array];
    const NSUInteger startedElementsCount = array.count;
    for (int i = 0; i < startedElementsCount; ++i) {
        const int indexOfSmallestElement = [self findIndexOfSmallestElementInArray:array];
        const int integerAtIndex = [array objectAtIndex:indexOfSmallestElement];
        [sortedArray addObject:integerAtIndex];
        [array removeObjectAtIndex:indexOfSmallestElement];
    }
    return sortedArray;
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

