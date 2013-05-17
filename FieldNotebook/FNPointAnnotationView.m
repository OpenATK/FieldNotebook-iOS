//
//  FNPointAnnotationView.m
//  FieldNotebook
//
//  Created by Ryan Worl on 4/1/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import "FNPointAnnotationView.h"

#import <QuartzCore/QuartzCore.h>

@implementation FNPointAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    self.frame = CGRectMake(0, 0, 15, 15);
    self.canShowCallout = YES;
    self.draggable = YES;
    self.backgroundColor = [UIColor blueColor];
    self.layer.cornerRadius = 7.5f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 2.0f;
    
    return self;
}

@end
