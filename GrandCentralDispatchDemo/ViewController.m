//
//  ViewController.m
//  GrandCentralDispatchDemo
//
//  Created by George Wu on 4/25/15.
//  Copyright © 2015 George Wu. All rights reserved.
//

#import "ViewController.h"
#import "GSWLengthyOperation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSLog(@"Start!");
	
	// uncomment to activate demo
	
//	[self dispatchQueueCreationDemo];
//	[self dispatchSyncSerialDemo];
//	[self dispatchSyncConcurrentDemo];
//	[self dispatchSyncMainDemo];
//	[self dispatchAsyncSerialDemo];
//	[self dispatchAsyncConcurrentDemo];
//	[self dispatchAsyncGlobalDemo];
//	[self dispatchAsyncMainDemo];
//	[self dispatchBarrierDemo];
//	[self dispatchOnceDemo];
//	[self dispatchAfterDemo];
//	[self dispatchGroupDemo];
//	[self dispatchGroupDemo2];
//	[self dispatchSemophoreDemo];
//	[self dispatchSemophoreDemo2];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	

}

- (void)dispatchQueueCreationDemo {
	
	// creation of a custom serial queue
	dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
	
	// creation of a custom concurrent queue
	dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
	
	// retrieve the main queue
	dispatch_queue_t mainQueue = dispatch_get_main_queue();
	
	// retrieve the global queue
	dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
	
	// suppress unused variable warning
	NSLog(@"%p", serialQueue);
	NSLog(@"%p", concurrentQueue);
	NSLog(@"%p", mainQueue);
	NSLog(@"%p", globalQueue);
}

- (void)dispatchSyncSerialDemo {
	
	dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
	
	for (int i = 0; i < 10; i++) {
		
		dispatch_sync(serialQueue, ^{
			
			[GSWLengthyOperation lengthyOperationWithTimeInterval:1.0];
			NSLog(@"currentThread = %@", [NSThread currentThread]);	// main thread
		});
	}
	
	NSLog(@"Done!");
}

- (void)dispatchSyncConcurrentDemo {
	
	dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
		
	for (int i = 0; i < 10; i++) {
		
		dispatch_sync(concurrentQueue, ^{
			
			[GSWLengthyOperation lengthyOperationWithTimeInterval:1.0];
			NSLog(@"currentThread = %@", [NSThread currentThread]);	// main thread
		});
	}
	
	NSLog(@"Done!");
}

- (void)dispatchSyncMainDemo {
	
	for (int i = 0; i < 10; i++) {
		
		NSLog(@"Deadlock.");
		
		/*
		 WARNING: Never do this in practise!
		 Two tasks are in the main queue when the next line of code executes, `dispatchSyncMainDemo` and the block `^{...}`, waiting for each other to finish, which causes a deadlock.
		 */
		
		// add a block to main queue and waiting for its completion
		dispatch_sync(dispatch_get_main_queue(), ^{
			
			// following task will execute when current task(s) on main queue is finished, in this case method `[self dispatchSyncMainDemo]`.
			
			[GSWLengthyOperation lengthyOperationWithTimeInterval:1.0];
			NSLog(@"currentThread = %@", [NSThread currentThread]);
		});
	}
	
	NSLog(@"Done!");	// will never execute
}

- (void)dispatchAsyncSerialDemo {
	
	dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
	
	for (int i = 0; i < 10; i++) {
		
		dispatch_async(serialQueue, ^{
			
			[GSWLengthyOperation lengthyOperationWithTimeInterval:1.0];	// execute sequentially
			NSLog(@"currentThread = %@", [NSThread currentThread]);	// same background thread
		});
	}
	
	NSLog(@"Done!");	// done immediately
}

- (void)dispatchAsyncConcurrentDemo {
	
	for (int i = 0; i < 10; i++) {
		
		dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
		
		dispatch_async(concurrentQueue, ^{
			
			[GSWLengthyOperation lengthyOperationWithTimeInterval:1.0];	// execute concurrently
			NSLog(@"currentThread = %@", [NSThread currentThread]);	// several background thread
		});
	}
	
	NSLog(@"Done!");	// done immediately
}

- (void)dispatchAsyncGlobalDemo {
	
	for (int i = 0; i < 10; i++) {
		
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			
			[GSWLengthyOperation lengthyOperationWithTimeInterval:1.0];	// execute concurrently
			NSLog(@"currentThread = %@", [NSThread currentThread]);	// several background thread
		});
	}
	
	NSLog(@"Done!");	// done immediately
}

- (void)dispatchAsyncMainDemo {
	
	for (int i = 0; i < 10; i++) {
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[GSWLengthyOperation lengthyOperationWithTimeInterval:1.0];	// execute sequentially
			NSLog(@"currentThread = %@", [NSThread currentThread]);	// main thread
		});
	}
	
	NSLog(@"Done!");	// done immediately
}

- (void)dispatchBarrierDemo {
	
	dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
	
	for (int i = 0; i < 5; i++) {
		
		dispatch_async(concurrentQueue, ^{
			
			[GSWLengthyOperation lengthyOperationWithTimeInterval:(arc4random() % 20) / 10.0];
			NSLog(@"Perparation %d, currentThread = %@", i, [NSThread currentThread]);
		});
	}
	
	// barrier tasks wait for completion of existing tasks and barred later tasks until finish.
	dispatch_barrier_async(concurrentQueue, ^{
		
		[GSWLengthyOperation lengthyOperationWithTimeInterval:2.0];
		NSLog(@"Initalize, currentThread = %@", [NSThread currentThread]);
	});
	
	for (int i = 0; i < 5; i++) {
		
		dispatch_async(concurrentQueue, ^{
			
			[GSWLengthyOperation lengthyOperationWithTimeInterval:(arc4random() % 20) / 10.0];
			NSLog(@"Tasking %d, currentThread = %@", i, [NSThread currentThread]);
		});
	}
}

- (void)dispatchOnceDemo {
	
	for (int i = 0; i < 10; i++) {
		
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			
			// will only execute once
			[GSWLengthyOperation lengthyOperationWithTimeInterval:(arc4random() % 20) / 10.0];
			NSLog(@"%d, currentThread = %@", i, [NSThread currentThread]);	// current thread, in this case main thread
		});
	}
}

- (void)dispatchAfterDemo {
	
	NSLog(@"Will finish in 2 seconds.");
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSLog(@"Done!");
	});
}

///	A simple demo of dispatch group using `notify`.
- (void)dispatchGroupDemo {
	
	dispatch_group_t group = dispatch_group_create();
	dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
	
	for (int i = 0; i < 10; i++) {
		dispatch_group_async(group, queue, ^{
			
			[GSWLengthyOperation lengthyOperationWithTimeInterval:(arc4random() % 20) / 10.0];
			NSLog(@"Tasking %d, currentThread = %@", i, [NSThread currentThread]);
		});
	}
	
	dispatch_group_notify(group, queue, ^{
		// execute when no more operations left in the group
		NSLog(@"Done!");	// log immediately after the finishing of the last lengthy operation.
	});
}

// A demo of dispatch group using enter, leave and wait mechanism.
- (void)dispatchGroupDemo2 {
	
	dispatch_group_t group = dispatch_group_create();
	dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
	
	for (int i = 0; i < 10; i++) {
		
		// manually tell the group a task has entered
		dispatch_group_enter(group);
		dispatch_group_async(group, queue, ^{
			
			[GSWLengthyOperation lengthyOperationWithTimeInterval:(arc4random() % 20) / 10.0];
			NSLog(@"Tasking %d, currentThread = %@", i, [NSThread currentThread]);
			
			// manually tell the group the task is finished
			// must be at the end of task
			dispatch_group_leave(group);
		});
	}
	
	// block current thread until all blocks in the group is completed.
	dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
	
	NSLog(@"Done!");	// log immediately after the finishing of the last lengthy task.
}

///	A semaphore demo where only a certain number of threads can execute concurrently.
- (void)dispatchSemophoreDemo {
	
	// at most 2 blocks can execute at the same time.
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);
	
	for (int i = 0; i < 10; i++) {
		
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			
			// decrement semaphore by 1, wait when semaphore is negative.
			dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
			
			NSLog(@"Task %d start.\t currentThread = %@", i, [NSThread currentThread]);
			[GSWLengthyOperation lengthyOperationWithTimeInterval:(arc4random() % 20) / 10.0 + 1];
			NSLog(@"Task %d end.\t currentThread = %@", i, [NSThread currentThread]);
			
			// increment semaphore by 1
			dispatch_semaphore_signal(semaphore);
		});
		
	}
	
	NSLog(@"Done!");
}

///	A semaphore demo which hangs a thread until tasks are finished.
- (void)dispatchSemophoreDemo2 {
	
	// a semaphore with initial value 0
	dispatch_semaphore_t sem = dispatch_semaphore_create(0);
	
	const int taskCount = 10;
	
	// this loop finishs immediately on current thread
	for (int i = 0; i < taskCount; i++) {
		
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			
			[GSWLengthyOperation lengthyOperationWithTimeInterval:1.0];
			NSLog(@"currentThread = %@", [NSThread currentThread]);
			// semaphore increases by 1 when task finish
			dispatch_semaphore_signal(sem);
		});
	}
	
	for (int i = 0; i < taskCount; i++) {
		
		// semaphore decreases by 1
		// blocks current thread until semaphore is non-negative again
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
	}
	
	NSLog(@"Done!");	// log when all tasks are finished.
}

@end
