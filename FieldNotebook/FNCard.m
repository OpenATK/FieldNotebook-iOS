//
//  FNCard.m
//  FieldNotebook
//
//  Created by Ryan Worl on 3/22/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import "FNCard.h"

#define kTitleKey @"title"
#define kSubtitleKey @"subtitle"
#define kEntitiesKey @"entities"
#define kVisibleKey @"visible"
#define kColorKey @"color"

@implementation FNCard

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize color = _color;
@synthesize photoURL = _photoURL;

- (id)init
{
    self = [super init];
    
    self.visible = YES;
    self.entities = @[].mutableCopy;
    
    return self;
}

- (UIColor *)color
{
    if (_color) {
        return _color;
    }
    
    return [UIColor colorWithWhite:.95 alpha:1.0];
}

- (NSString *)humanType
{
    return @"Card";
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_title forKey:kTitleKey];
    [encoder encodeObject:_subtitle forKey:kSubtitleKey];
    [encoder encodeObject:_entities forKey:kEntitiesKey];
    [encoder encodeBool:_visible forKey:kVisibleKey];
    [encoder encodeObject:_color forKey:kColorKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSString *title = [decoder decodeObjectForKey:kTitleKey];
    NSString* subtitle = [decoder decodeObjectForKey:kSubtitleKey];
    UIColor* color = [decoder decodeObjectForKey:kColorKey];
    NSMutableArray* ents = [decoder decodeObjectForKey:kEntitiesKey];
    BOOL visible = [decoder decodeBoolForKey:kVisibleKey];
    
    self = [super init];
    
    if (ents) {
        self.entities = ents;
    }
    
    self.title = title;
    self.subtitle = subtitle;
    self.color = color;
    self.visible = visible;
    
    return self;
}

@end
