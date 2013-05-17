//
//  FNCardCell.m
//  FieldNotebook
//
//  Created by Ryan Worl on 4/10/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "FNCardCell.h"
#import "FNCard.h"
#import "FNPoint.h"
#import "FNLine.h"
#import "FNShape.h"

#import "KGNotePad.h"

@interface FNCardCell () <UITextViewDelegate>

@property (nonatomic, strong) FNCard* card;

@property (nonatomic, strong) KGNotePad* notePadView;
@property (nonatomic, strong) UIButton* accessoryButton;
@property (nonatomic, strong) UIButton* visibleButton;
@property (nonatomic, strong) UIButton* entitiesButton;
@property (nonatomic, strong) UIButton* colorButton;
@property (nonatomic, strong) UIScrollView* entitiesScrollView;

@end

@implementation FNCardCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1.0];
        
        self.notePadView = [[KGNotePad alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        self.notePadView.textView.font = [UIFont systemFontOfSize:18];
        self.notePadView.textView.delegate = self;
        self.notePadView.paperBackgroundColor = [UIColor whiteColor];
        self.notePadView.lineOffset = 9;
        [self.contentView addSubview:self.notePadView];
        
        self.visibleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.visibleButton.frame = CGRectMake(0, 0, 40, 40);
        [self.visibleButton setImage:[UIImage imageNamed:@"eye"] forState:UIControlStateNormal];
        [self.visibleButton addTarget:self action:@selector(didTapVisibleButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.visibleButton];

        self.entitiesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.entitiesButton.frame = CGRectMake(0, 0, 40, 40);
        [self.entitiesButton setImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
        [self.entitiesButton addTarget:self action:@selector(didTapEntitiesButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.entitiesButton];
        
        self.colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.colorButton.frame = CGRectMake(0, 0, 40, 40);
        [self.colorButton setImage:[UIImage imageNamed:@"color"] forState:UIControlStateNormal];
        [self.colorButton addTarget:self action:@selector(didTapColorButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.colorButton];
        
        self.accessoryButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [self.accessoryButton addTarget:self action:@selector(didTapAccessoryButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.accessoryButton];
        
        self.entitiesScrollView = [[UIScrollView alloc] init];
        self.entitiesScrollView.backgroundColor = self.contentView.backgroundColor;
        //self.entitiesScrollView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.entitiesScrollView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.notePadView.frame = CGRectMake(0, 0, self.frame.size.width - 50, self.frame.size.height - 40);
    self.accessoryButton.center = CGPointMake(self.frame.size.width - 25, self.frame.size.height - 20);
    self.visibleButton.center = CGPointMake(self.frame.size.width - 25, 30);
    self.entitiesButton.center = CGPointMake(self.visibleButton.center.x, self.visibleButton.center.y + 40);
    self.colorButton.center = CGPointMake(self.entitiesButton.center.x, self.entitiesButton.center.y + 40);

    CGFloat width = MAX((self.card.entities.count * 40) + 10, self.frame.size.width - 40);
    
    self.entitiesScrollView.frame = CGRectMake(0, self.frame.size.height - 40, self.frame.size.width - 50, 40);
    self.entitiesScrollView.contentSize = CGSizeMake(width, 40);
    
    [self.notePadView layoutSubviews];
}

- (void)updateCellWithCard:(FNCard *)card
{
    self.card = card;
    
    self.contentView.backgroundColor = card.color;
    
    [self.entitiesScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i = 0; i < self.card.entities.count; i++) {
        id<FNEntity> entity = self.card.entities[i];
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.layer.cornerRadius = 5.0f;
        button.tag = i;
        button.backgroundColor = entity.color;
        button.frame = CGRectMake((i * 40) + 5, 2.5, 35, 35);
        if ([entity isKindOfClass:[FNPoint class]]) {
            [button setImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
        }
        if ([entity isKindOfClass:[FNLine class]]) {
            [button setImage:[UIImage imageNamed:@"line"] forState:UIControlStateNormal];
        }
        if ([entity isKindOfClass:[FNShape class]]) {
            [button setImage:[UIImage imageNamed:@"shape"] forState:UIControlStateNormal];
        }
        
        [button addTarget:self action:@selector(didTapEntityButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.entitiesScrollView addSubview:button];
    }
    
    self.notePadView.textView.text = [NSString stringWithFormat:@"%@\n%@", card.title, card.subtitle];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSString* text = textView.text;
    NSMutableArray* parts = [text componentsSeparatedByString:@"\n"].mutableCopy;
        
    if (parts.count > 0) {
        self.card.title = parts[0];
    }
    if (parts.count > 1) {
        [parts removeObjectAtIndex:0];
        self.card.subtitle = [parts componentsJoinedByString:@"\n"];
    }
}

#pragma mark - Callbacks

- (void)didTapEntityButton:(UIButton *)button
{
    id<FNEntity> entity = self.card.entities[button.tag];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardCell:didTapEntity:)]) {
        [self.delegate cardCell:self didTapEntity:entity];
    }
}

- (void)didTapAccessoryButton:(id)button
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cardCellDidTapDetailsButton:)]) {
        [self.delegate cardCellDidTapDetailsButton:self];
    }
}

- (void)didTapEntitiesButton:(id)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardCellDidTapEntitiesButton:)]) {
        [self.delegate cardCellDidTapEntitiesButton:self];
    }
}

- (void)didTapColorButton:(id)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardCellDidTapColorButton:)]) {
        [self.delegate cardCellDidTapColorButton:self];
    }
}

- (void)didTapVisibleButton:(id)button
{
    if (self.card.visible) {
        [self.visibleButton setImage:[UIImage imageNamed:@"eye_selected"] forState:UIControlStateNormal];
    } else {
        [self.visibleButton setImage:[UIImage imageNamed:@"eye"] forState:UIControlStateNormal];
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(cardCellDidToggleVisiblity:)]) {
        [self.delegate cardCellDidToggleVisiblity:self];
    }
}

@end
