//
//  FNEntity.h
//  FieldNotebook
//
//  Created by Ryan Worl on 3/22/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FNEntity <NSObject>

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;
@property (nonatomic, strong) NSURL* photoURL;
@property (nonatomic, strong) UIColor* color;

@required

- (NSString *)humanType;

@end
