//
//  GSWLengthyOperation.m
//  LengthOperationSimulator
//
//  Created by George Wu on 10/11/14.
//  Copyright (c) 2014 George Wu. All rights reserved.
//

#import "GSWLengthyOperation.h"

@implementation GSWLengthyOperation

+ (void)lengthyOperationWithTimeInterval:(NSTimeInterval)duration {
	
	NSDate *finishDate = [NSDate dateWithTimeIntervalSinceNow:duration];
	while ([[NSDate date] compare:finishDate] == NSOrderedAscending);
}

+ (void)lengthyOperationWithTimeInterval:(NSTimeInterval)duration completion: (void (^)(BOOL finished))completion {
	
	[self lengthyOperationWithTimeInterval:duration];
	completion(YES);
}

+ (void)lengthyOperationWithTimeInterval:(NSTimeInterval)duration taskName:(NSString *)taskName {
	
	NSLog(@"%@ begin. %@", taskName, [NSThread currentThread]);
	[self lengthyOperationWithTimeInterval:duration];
	NSLog(@"%@ end. %@", taskName, [NSThread currentThread]);
}


@end
