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
    NSUInteger objectsCount = 10;

    for (int i = 0; i < objectsCount; ++i) {
        [array addObject:i];
        XCTAssertTrue(array.count == i + 1);
    }
    
    for (int i = 0; i < objectsCount; ++i) {
        int objectAtIndex = [array objectAtIndex:i];
        XCTAssertTrue(objectAtIndex == i);
    }
}



// MARK: - Performance tests -

//- (void)testPerformanceExample {
//    MutableIntArray *array = [[MutableIntArray alloc] init];
//
//    [self measureBlock:^{
//        for (int i = 0; i < 1000; ++i) {
//            [array addObject:i];
//        }
//    }];
//}


// MARK: - Setup and Teardown -

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

@end
