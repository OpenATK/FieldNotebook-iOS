//
//  FNPoint.h
//  FieldNotebook
//
//  Created by Ryan Worl on 3/22/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import "FNEntity.h"

#include <MapKit/MapKit.h>
#include <CoreLocation/CoreLocation.h>

@interface FNPoint : NSObject <MKAnnotation, FNEntity, NSCoding>

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;
@property (nonatomic, strong) NSURL* photoURL;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) id parent;


@end
