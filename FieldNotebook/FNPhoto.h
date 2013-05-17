//
//  FNPhoto.h
//  FieldNotebook
//
//  Created by Ryan Worl on 5/2/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "FNEntity.h"

@interface FNPhoto : NSObject <FNEntity, NSCoding, MKAnnotation>

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;
@property (nonatomic, strong) NSURL* photoURL;

@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;

- (NSString *)humanType;

@end
