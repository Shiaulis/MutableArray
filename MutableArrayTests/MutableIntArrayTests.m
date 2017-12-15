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
    NSUInteger objectsCount = 10;
    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
        XCTAssertTrue(array.count == i + 1);
    }
    int const targetIndex = 5;
    int const targetValue = 1000;
    int const expectedCapacity = 16;
    
    [array insertObject:targetValue atIndex:targetIndex];
    ++objectsCount;
    
    XCTAssertTrue(array.count == objectsCount);
    XCTAssertTrue(array.capacity == expectedCapacity);
    for (int i = 0; i < objectsCount; ++i) {
        int objectAtIndex = [array objectAtIndex:i];
        if (i < targetIndex) {
            XCTAssertTrue(objectAtIndex == i);
        }
        else if (i == targetIndex){
            XCTAssertTrue(objectAtIndex == targetValue);
        }
        else {
            XCTAssertTrue(objectAtIndex == i - 1);
        }
    }
}

- (void)testInsertAnotherArray {
    MutableIntArray *array = [[MutableIntArray alloc] init];
    NSUInteger objectsCount = 10;
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


// MARK: - Performance tests -

- (void)testPerformanceExample {
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
