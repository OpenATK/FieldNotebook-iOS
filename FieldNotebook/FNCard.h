//
//  FNCard.h
//  FieldNotebook
//
//  Created by Ryan Worl on 3/22/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FNEntity.h"

@interface FNCard : NSObject <FNEntity, NSCoding>

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, assign, getter = isVisible) BOOL visible;
@property (nonatomic, strong) NSMutableArray* entities;

@end
