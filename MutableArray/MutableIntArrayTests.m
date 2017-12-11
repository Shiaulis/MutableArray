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

// MARK: - Tests -

- (void)testExample {
    MutableIntArray *array = [[MutableIntArray alloc] init];
    array = nil;
}

// MARK: - Performance tests -

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
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
