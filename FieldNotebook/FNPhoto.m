//
//  FNPhoto.m
//  FieldNotebook
//
//  Created by Ryan Worl on 5/2/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import "FNPhoto.h"

#define kTitleKey @"title"
#define kSubtitleKey @"subtitle"
#define kLatitudeKey @"latitude"
#define kLongitudeKey @"longitude"
#define kPhotoURLKey @"photoURL"

@implementation FNPhoto

- (id)init
{
    self = [super init];
    
    self.title = @"Photo";
    
    return self;
}

- (NSString *)humanType
{
    return @"Photo";
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
    [encoder encodeObject:self.photoURL.absoluteString forKey:kPhotoURLKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSString *title = [decoder decodeObjectForKey:kTitleKey];
    NSString* subtitle = [decoder decodeObjectForKey:kSubtitleKey];
    NSString* urlString = [decoder decodeObjectForKey:kPhotoURLKey];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [decoder decodeDoubleForKey:kLatitudeKey];
    coordinate.longitude = [decoder decodeDoubleForKey:kLongitudeKey];
    
    self = [super init];
    
    self.title = title;
    self.subtitle = subtitle;
    self.coordinate = coordinate;
    self.photoURL = [NSURL URLWithString:urlString];
    
    return self;
}

@end
