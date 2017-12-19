//
//  MutableIntArrayTests.m
//  MutableArray
//
//  Created by andrius on 11.12.17.
//  Copyright © 2017 andrius. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MutableIntArray.h"
#import "MutableIntArray+Private.h"

@interface MutableIntArrayTests : XCTestCase

@end

@implementation MutableIntArrayTests

// MARK: - Initialization Tests -

- (void)testInitWithZeroCapacity {
    MutableIntArray *array = [[MutableIntArray alloc] initWithCapacity:0];
    XCTAssertNotNil(array);
    XCTAssertEqual(array.capacity, 1);
    XCTAssertEqual(array.count, 0);
}

- (void)testInitWithRegularCapacity {
    NSUInteger const regularCapacity = 20;

    MutableIntArray *array = [[MutableIntArray alloc] initWithCapacity:regularCapacity];

    XCTAssertNotNil(array);
    XCTAssertEqual(array.capacity, regularCapacity);
    XCTAssertEqual(array.count, 0);
}

- (void)testRegularInit {

    MutableIntArray *array = [MutableIntArray array];

    XCTAssertNotNil(array);
    XCTAssertEqual(array.capacity, 1);
    XCTAssertEqual(array.count, 0);
}

// MARK: - Adding integers tests -

- (void)testAddingIntegersToArrayWithFixedCapacity {
    NSUInteger const fixedCapacity = 3;

    MutableIntArray *array = [[MutableIntArray alloc] initWithCapacity: fixedCapacity];

    for (int i = 0; i < fixedCapacity; ++i) {
        [array addObject:i];
        XCTAssertEqual(array.capacity, fixedCapacity);
        XCTAssertEqual(array.count, i + 1);
    }
}

- (void)testAddingIntegersToArrayWithDynamicCapacity {
    MutableIntArray *array = [MutableIntArray array];

    for (int i = 0; i < 1000; ++i) {
        [array addObject:i];
        XCTAssertEqual(array.count, i + 1);
    }
}

// MARK: - Getting integers tests

- (void)testGetObjectAtIndex {
    MutableIntArray *array = [MutableIntArray array];
    NSUInteger const objectsCount = 100;

    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
        XCTAssertEqual(array.count, i + 1);
    }
    
    for (int i = 0; i < objectsCount; ++i) {
        int objectAtIndex = [array objectAtIndex:i];
        XCTAssertEqual(objectAtIndex, i);
    }
}

- (void)tesGettObjectOutOfBounds {
    MutableIntArray *array = [MutableIntArray array];
    NSUInteger const objectsCount = 10;
    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
        XCTAssertEqual(array.count, i + 1);
    }

    XCTAssertThrows([array objectAtIndex:15]);
}

// MARK: - Inserting object tests -

- (void)testInsertObjects {
    MutableIntArray *array = [MutableIntArray array];
    int objectsCount = 1000;
    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
        XCTAssertEqual(array.count, i + 1);
    }
    int const targetIndex = 500;
    int const targetValue = 1000;

    [array insertObject:targetValue atIndex:targetIndex];
    ++objectsCount;

    XCTAssertEqual(array.count, objectsCount);

    for (int i = 0; i < objectsCount; ++i) {
        int objectAtIndex = [array objectAtIndex:i];
        if (i < targetIndex) {
            XCTAssertEqual(objectAtIndex, i);
        }
        else if (i == targetIndex){
            XCTAssertEqual(objectAtIndex, targetValue);
        }
        else {
            XCTAssertEqual(objectAtIndex, i - 1);
        }
    }
}

- (void)testInsertObjectAtTheBeginning {
    MutableIntArray *array = [MutableIntArray array];
    int objectsCount = 1000;
    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
        XCTAssertEqual(array.count, i + 1);
    }
    int const targetIndex = 0;
    int const targetValue = 1000;

    [array insertObject:targetValue atIndex:targetIndex];
    ++objectsCount;

    XCTAssertEqual(array.count, objectsCount);

    for (int i = 0; i < objectsCount; ++i) {
        int objectAtIndex = [array objectAtIndex:i];
        if (i == 0) {
            XCTAssertEqual(objectAtIndex, targetValue);
        }
        else {
            XCTAssertEqual(objectAtIndex, i - 1);
        }
    }
}

- (void)testInsertObjectAtTheEnd {
    MutableIntArray *array = [MutableIntArray array];
    int objectsCount = 3;
    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
        XCTAssertEqual(array.count, i + 1);
    }
    int const targetIndex = objectsCount - 1;
    int const targetValue = 666;

    [array insertObject:targetValue atIndex:targetIndex];
    ++objectsCount;

    XCTAssertEqual(array.count, objectsCount);

    for (int i = 0; i < objectsCount; ++i) {
        int objectAtIndex = [array objectAtIndex:i];
        if (i == targetIndex) {
            XCTAssertEqual(objectAtIndex, targetValue);
        }
        else if (i > targetIndex) {
            XCTAssertEqual(objectAtIndex, i - 1);
        }
        else {
            XCTAssertEqual(objectAtIndex, i);
        }
    }
}

// MARK: - Insert another array tests -

- (void)testInsertAnotherArray {
    MutableIntArray *array = [MutableIntArray array];
    int objectsCount = 10;
    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
        XCTAssertEqual(array.count, i + 1);
    }
    MutableIntArray *insertedArray = [MutableIntArray array];
    for (int i = 0; i < objectsCount; ++i) {
        [insertedArray addObject:i * 100];
        XCTAssertEqual(insertedArray.count, i + 1);
    }
    NSUInteger const targetIndex = 5;
    
    [array insertMutableIntArray:insertedArray
                         atIndex:targetIndex];

    XCTAssertEqual(array.count, objectsCount * 2);
    XCTAssertEqual(array.capacity, 20);
    
    for (int i = 0; i < objectsCount; ++i) {
        int objectAtIndex = [array objectAtIndex:i];
        if (i < targetIndex) {
            XCTAssertEqual(objectAtIndex, i);
        }
        else if (i >= targetIndex && i < targetIndex + objectsCount) {
            XCTAssertEqual(objectAtIndex, (i - targetIndex) * 100);
        }
        else {
            XCTAssertEqual(objectAtIndex, i = objectsCount);
        }
    }
}

- (void)testInsertAnotherArrayAtTheBegginning {
    MutableIntArray *array = [MutableIntArray array];
    int objectsCount = 10;
    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
        XCTAssertEqual(array.count, i + 1);
    }
    MutableIntArray *insertedArray = [MutableIntArray array];
    for (int i = 0; i < objectsCount; ++i) {
        [insertedArray addObject:i * 100];
        XCTAssertEqual(insertedArray.count, i + 1);
    }
    NSUInteger const targetIndex = 0;

    [array insertMutableIntArray:insertedArray
                         atIndex:targetIndex];

    XCTAssertEqual(array.count, objectsCount * 2);
    XCTAssertEqual(array.capacity, 20);

    for (int i = 0; i < objectsCount; ++i) {
        int objectAtIndex = [array objectAtIndex:i];
        if (i < targetIndex) {
            XCTAssertEqual(objectAtIndex, i);
        }
        else if (i >= targetIndex && i < targetIndex + objectsCount) {
            XCTAssertEqual(objectAtIndex, (i - targetIndex) * 100);
        }
        else {
            XCTAssertEqual(objectAtIndex, i - objectsCount);
        }
    }
}

- (void)testInsertAnotherArrayAtTheEnd {
    MutableIntArray *array = [MutableIntArray array];
    int objectsCount = 10;
    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
        XCTAssertEqual(array.count, i + 1);
    }
    MutableIntArray *insertedArray = [MutableIntArray array];
    for (int i = 0; i < objectsCount; ++i) {
        [insertedArray addObject:i * 100];
        XCTAssertEqual(insertedArray.count, i + 1);
    }
    NSUInteger const targetIndex = objectsCount - 1;

    [array insertMutableIntArray:insertedArray
                         atIndex:targetIndex];

    XCTAssertEqual(array.count, objectsCount * 2);
    XCTAssertEqual(array.capacity, 20);

    for (int i = 0; i < objectsCount; ++i) {
        int objectAtIndex = [array objectAtIndex:i];
        if (i < targetIndex) {
            XCTAssertEqual(objectAtIndex, i);
        }
        else if (i >= targetIndex && i < targetIndex + objectsCount) {
            XCTAssertEqual(objectAtIndex, (i - targetIndex) * 100);
        }
        else {
            XCTAssertEqual(objectAtIndex, i = objectsCount);
        }
    }
}

- (void)testInsertAnEmptyArray {
    MutableIntArray *array = [MutableIntArray array];
    int objectsCount = 10;
    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
    }
    MutableIntArray *emptyArray = [MutableIntArray array];

    NSUInteger const targetRandomIndex = arc4random_uniform(objectsCount);
    
    [array insertMutableIntArray:emptyArray
                         atIndex:targetRandomIndex];

    XCTAssertEqual(array.count, objectsCount);
    for (int i = 0; i < objectsCount; ++i) {
        int objectAtIndex = [array objectAtIndex:i];
        XCTAssertEqual(objectAtIndex, i);
    }
}

// MARK: - Removing objects -

- (void)testRemoveObjectAtIndex {
    MutableIntArray *array = [MutableIntArray array];
    int objectsCount = 100;
    
    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
        XCTAssertEqual(array.count, i + 1);
    }
    
    int const randomTargetIndex = arc4random_uniform(objectsCount);
    
    [array removeObjectAtIndex:randomTargetIndex];
    --objectsCount;

    XCTAssertEqual(array.count, objectsCount);
    for (int i = 0; i < objectsCount; ++i) {
        int objectAtIndex = [array objectAtIndex:i];
        if (i < randomTargetIndex) {
            XCTAssertEqual(objectAtIndex, i);
        }
        else {
            XCTAssertEqual(objectAtIndex, i + 1);
        }
    }
}

- (void)testArraySorting {
    
    int unsortedIntegers[5] = {1000, 2, 3, 7, 50};
    int size = sizeof(unsortedIntegers) / sizeof(int);
    MutableIntArray *unsortedArray =
    [MutableIntArray
     initWithIntegers:unsortedIntegers
     count:size];
    int sortedIntegers[5] = {2, 3, 7, 50, 1000};
    MutableIntArray *sortedArray =
    [MutableIntArray
     initWithIntegers:sortedIntegers
     count:size];
    
    XCTAssertTrue([sortedArray compareArrayWithArray:unsortedArray.sorted]);
}



// MARK: - Performance tests -

- (void)testPerformance {
    MutableIntArray *array = [MutableIntArray array];

    [self measureBlock:^{
        for (int i = 0; i < 1000; ++i) {
            [array addObject:i];
        }
    }];
}

@end
