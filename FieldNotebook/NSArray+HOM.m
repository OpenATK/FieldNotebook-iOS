// Source Code based on the book CocoaDesignPatterns


@interface NSObject(_MNTrampoline)

- (NSMethodSignature *)mn_findMethodSignatureForSelector:(SEL)aSelector;

@end


@interface _MNTrampoline : NSProxy
{
	id target;
	SEL	selector;
}

+ (id)trampolineForTarget:(id)aTarget andSelector:(SEL)aSelector;
- (id)initForTarget:(id)aTarget andSelector:(SEL)aSelector;

@end

@implementation _MNTrampoline

+ (id)trampolineForTarget:(id)aTarget andSelector:(SEL)aSelector
{
	id newTrampoline = [[[self class] alloc] initForTarget:aTarget andSelector:aSelector];
	[newTrampoline autorelease];
	return newTrampoline;
}

- (id)initForTarget:(id)aTarget andSelector:(SEL)aSelector
{
	target = aTarget;
	[target retain];
	selector = aSelector;
	return self;
}

- (void)dealloc
{
	[target release];
	[super dealloc];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [target mn_findMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	[target performSelector:selector withObject:anInvocation];
}

@end




#import "NSArray+HOM.h"

@implementation NSArray(HOM)

- (NSMethodSignature *)mn_findMethodSignatureForSelector:(SEL)aSelector
{
	for (id object in self) {
		if ([object respondsToSelector:aSelector]) {
			return [object methodSignatureForSelector:aSelector];
		}
	}
	return [self methodSignatureForSelector:aSelector];
}

- (id)mn_makeObjectsPerform
{
	return [_MNTrampoline trampolineForTarget:self andSelector:@selector(mn_makeObjectsPerformInvocation:)];
}

- (void)mn_makeObjectsPerformInvocation:(NSInvocation *)invocation
{
	id object = nil;
	for (object in self) {
		[invocation invokeWithTarget:object];
	}
}

@end


@implementation NSObject(MYTrampoline)

- (NSMethodSignature *)mn_findMethodSignatureForSelector:(SEL)aSelector
{
	return [self methodSignatureForSelector:aSelector];
}

@end



