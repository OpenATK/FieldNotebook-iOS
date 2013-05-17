//
//  FNLine.h
//  FieldNotebook
//
//  Created by Ryan Worl on 3/23/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "FNEntity.h"

@interface FNLine : NSObject <FNEntity>

- (id)initWithPoints:(NSArray *)points;
- (void)makeOverlay;

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) MKPolyline* overlay;
@property (nonatomic, strong) NSMutableArray* points;

@end
