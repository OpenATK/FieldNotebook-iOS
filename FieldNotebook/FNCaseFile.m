//
//  FNCaseFile.m
//  FieldNotebook
//
//  Created by Ryan Worl on 3/22/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import "FNCaseFile.h"

#define kTitleKey @"title"
#define kCardsKey @"cards"

@implementation FNCaseFile

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize color = _color;
@synthesize photoURL = _photoURL;

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_title forKey:kTitleKey];
    [encoder encodeObject:_cards forKey:kCardsKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSString *title = [decoder decodeObjectForKey:kTitleKey];
    NSMutableArray* cards = [[decoder decodeObjectForKey:kCardsKey] mutableCopy];
        
    self = [self init];
    
    self.title = title;
    self.cards = cards;
    
    return self;
}

- (id)init
{
    self = [super init];
    
    self.title = @"Casefile";
    self.cards = @[].mutableCopy;
    
    return self;
}

- (NSString *)humanType
{
    return @"Card";
}

@end
