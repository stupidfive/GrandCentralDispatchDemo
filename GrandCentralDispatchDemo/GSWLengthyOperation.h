//
//  GSWLengthyOperation.h
//  LengthOperationSimulator
//
//  Created by George Wu on 10/11/14.
//  Copyright (c) 2014 George Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSWLengthyOperation : NSObject

+ (void)lengthyOperationWithTimeInterval:(NSTimeInterval)duration;
+ (void)lengthyOperationWithTimeInterval:(NSTimeInterval)duration completion: (void (^)(BOOL finished))completion;

+ (void)lengthyOperationWithTimeInterval:(NSTimeInterval)duration taskName:(NSString *)taskName;

@end
