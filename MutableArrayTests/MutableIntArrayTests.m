//
//  MutableIntArrayTests.m
//  MutableArray
//
//  Created by andrius on 11.12.17.
//  Copyright © 2017 andrius. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MutableIntArray.h"

@interface MutableIntArrayTests : XCTestCase

@end

@implementation MutableIntArrayTests

// MARK: - Initialization Tests -

- (void)testInitWithZeroCapacity {
    MutableIntArray *array = [[MutableIntArray alloc] initWithCapacity:0];
    XCTAssertNotNil(array);
    XCTAssertTrue(array.capacity == 1);
    XCTAssertTrue(array.count == 0);
}

- (void)testInitWithRegularCapacity {
    NSUInteger const regularCapacity = 20;

    MutableIntArray *array = [[MutableIntArray alloc] initWithCapacity:regularCapacity];

    XCTAssertNotNil(array);
    XCTAssertTrue(array.capacity == regularCapacity);
    XCTAssertTrue(array.count == 0);
}

// I think this test is incorrect for now.
// We should somehow check an an input parameters
// before an attempt to create an array

//- (void)testInitWithHugeCapacity {
//    NSUInteger const hugeCapacity = NSUIntegerMax / 2;
//
//    MutableIntArray *array = [[MutableIntArray alloc] initWithCapacity:hugeCapacity];
//
//    XCTAssertNil(array);
//}

- (void)testRegularInit {

    MutableIntArray *array = [[MutableIntArray alloc] init];

    XCTAssertNotNil(array);
    XCTAssertTrue(array.capacity == 1);
    XCTAssertTrue(array.count == 0);
}

// MARK: - Adding integers tests -

- (void)testAddingIntegersToArrayWithFixedCapacity {
    NSUInteger const fixedCapacity = 3;

    MutableIntArray *array = [[MutableIntArray alloc] initWithCapacity: fixedCapacity];

    for (int i = 0; i < fixedCapacity; ++i) {
        [array addObject:i];
        XCTAssertTrue(array.capacity == fixedCapacity);
        XCTAssertTrue(array.count == i + 1);
    }
}

- (void)testAddingIntegersToArrayWithDynamicCapacity {
    MutableIntArray *array = [[MutableIntArray alloc] init];

    for (int i = 0; i < 1000; ++i) {
        [array addObject:i];
        XCTAssertTrue(array.count == i + 1);
    }
}

// MARK: - Getting integers tests

- (void)testObjectAtIndex {
    MutableIntArray *array = [[MutableIntArray alloc] init];
    NSUInteger const objectsCount = 100;

    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
        XCTAssertTrue(array.count == i + 1);
    }
    
    for (int i = 0; i < objectsCount; ++i) {
        int objectAtIndex = [array objectAtIndex:i];
        XCTAssertTrue(objectAtIndex == i);
    }
}

- (void)testObjectOutOfBounds {
    MutableIntArray *array = [[MutableIntArray alloc] init];
    NSUInteger const objectsCount = 10;
    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
        XCTAssertTrue(array.count == i + 1);
    }
    
    @try {
       [array objectAtIndex:15];
    }
    @catch(NSException *exception) {
        XCTAssertTrue(exception);
    }
}

- (void)testInsertObjects {
    MutableIntArray *array = [[MutableIntArray alloc] init];
    int objectsCount = 10;
    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
        XCTAssertTrue(array.count == i + 1);
    }
    int const randomTargetIndex = arc4random_uniform(objectsCount);
    int const targetValue = 1000;
    int const expectedCapacity = 16;
    
    [array insertObject:targetValue atIndex:randomTargetIndex];
    ++objectsCount;
    
    XCTAssertTrue(array.count == objectsCount);
    XCTAssertTrue(array.capacity == expectedCapacity);
    for (int i = 0; i < objectsCount; ++i) {
        int objectAtIndex = [array objectAtIndex:i];
        if (i < randomTargetIndex) {
            XCTAssertTrue(objectAtIndex == i);
        }
        else if (i == randomTargetIndex){
            XCTAssertTrue(objectAtIndex == targetValue);
        }
        else {
            XCTAssertTrue(objectAtIndex == i - 1);
        }
    }
}

- (void)testInsertAnotherArray {
    MutableIntArray *array = [[MutableIntArray alloc] init];
    int objectsCount = 10;
    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
        XCTAssertTrue(array.count == i + 1);
    }
    MutableIntArray *insertedArray = [[MutableIntArray alloc] init];
    for (int i = 0; i < objectsCount; ++i) {
        [insertedArray addObject:i * 100];
        XCTAssertTrue(insertedArray.count == i + 1);
    }
    NSUInteger const targetIndex = 5;
    
    [array insertMutableIntArray:insertedArray
                         atIndex:targetIndex];
    
    XCTAssertTrue(array.count == objectsCount * 2);
    XCTAssertTrue(array.capacity == 20);
    
    for (int i = 0; i < objectsCount; ++i) {
        int objectAtIndex = [array objectAtIndex:i];
        if (i < targetIndex) {
            XCTAssertTrue(objectAtIndex == i);
        }
        else if (i >= targetIndex && i < targetIndex + objectsCount) {
            XCTAssertTrue(objectAtIndex == (i - targetIndex) * 100);
        }
        else {
            XCTAssertTrue(objectAtIndex == i - objectsCount);
        }
    }
}

- (void)testInsertAnEmptyArray {
    MutableIntArray *array = [[MutableIntArray alloc] init];
    int objectsCount = 10;
    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
    }
    MutableIntArray *emptyArray = [[MutableIntArray alloc] init];

    NSUInteger const targetRandomIndex = arc4random_uniform(objectsCount);
    
    [array insertMutableIntArray:emptyArray
                         atIndex:targetRandomIndex];
    
    XCTAssertTrue(array.count == objectsCount);
    for (int i = 0; i < objectsCount; ++i) {
        int objectAtIndex = [array objectAtIndex:i];
        XCTAssertTrue(objectAtIndex == i);
    }
}

// MARK: - Removing objects -

- (void)testRemoveObjectAtIndex {
    MutableIntArray *array = [[MutableIntArray alloc] init];
    int objectsCount = 100;
    
    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
        XCTAssertTrue(array.count == i + 1);
    }
    
    int const randomTargetIndex = arc4random_uniform(objectsCount);
    
    [array removeObjectAtIndex:randomTargetIndex];
    --objectsCount;
    
    XCTAssertTrue(array.count == objectsCount);
    for (int i = 0; i < objectsCount; ++i) {
        int objectAtIndex = [array objectAtIndex:i];
        if (i < randomTargetIndex) {
            XCTAssertTrue(objectAtIndex == i);
        }
        else {
            XCTAssertTrue(objectAtIndex == i + 1);
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
    MutableIntArray *array = [[MutableIntArray alloc] init];

    [self measureBlock:^{
        for (int i = 0; i < 1000; ++i) {
            [array addObject:i];
        }
    }];
}


// MARK: - Setup and Teardown -

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

@end
