//
//  main.m
//  MutableArray
//
//  Created by andrius on 29.11.17.
//  Copyright © 2017 andrius. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MutableIntArray.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        MutableIntArray *array = [[MutableIntArray alloc] init];

        for (int i = 0; i < 10; i += 1) {
            [array addObject:i * 100];
            NSLog(@"%@", array.description);
        }
        [array insertObject:666 atIndex:2];

        NSLog(@"%@", array.description);

        MutableIntArray *newArray = [[MutableIntArray alloc] init];

        for (int i = 0; i < 10; i += 1) {
            [newArray addObject:i * 1000];
        }
        NSLog(@"%@", newArray.description);

        [array insertMutableIntArray:newArray atIndex:4];

        NSLog(@"%@", array.description);

        for (int i = 0; i < 11; i += 1) {
            [array removeObjectAtIndex:1];
            NSLog(@"%@", array.description);
        }

    }
    return 0;
}
