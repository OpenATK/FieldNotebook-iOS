//
//  FNPoint.m
//  FieldNotebook
//
//  Created by Ryan Worl on 3/22/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import "FNPoint.h"

#define kTitleKey @"title"
#define kSubtitleKey @"subtitle"
#define kLatitudeKey @"latitude"
#define kLongitudeKey @"longitude"
#define kColorKey @"color"
#define kPhotoURLKey @"photoURL"

@implementation FNPoint

- (id)init
{
    self = [super init];
    
    self.title = @"Point";
    self.color = [UIColor greenColor];
    
    return self;
}

- (NSString *)humanType
{
    return @"Point";
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    _coordinate = coordinate;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_title forKey:kTitleKey];
    [encoder encodeObject:_subtitle forKey:kSubtitleKey];
    [encoder encodeDouble:_coordinate.latitude forKey:kLatitudeKey];
    [encoder encodeDouble:_coordinate.longitude forKey:kLongitudeKey];
    [encoder encodeObject:_photoURL forKey:kPhotoURLKey];
    [encoder encodeObject:_color forKey:kColorKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSString *title = [decoder decodeObjectForKey:kTitleKey];
    NSString* subtitle = [decoder decodeObjectForKey:kSubtitleKey];
    UIColor* color = [decoder decodeObjectForKey:kColorKey];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [decoder decodeDoubleForKey:kLatitudeKey];
    coordinate.longitude = [decoder decodeDoubleForKey:kLongitudeKey];
    
    NSURL* photoURL = [decoder decodeObjectForKey:kPhotoURLKey];
    
    self = [super init];
    
    self.title = title;
    self.subtitle = subtitle;
    self.coordinate = coordinate;
    self.color = color;
    self.photoURL = photoURL;
    
    return self;
}

@end
