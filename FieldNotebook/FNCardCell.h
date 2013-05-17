//
//  FNCardCell.h
//  FieldNotebook
//
//  Created by Ryan Worl on 4/10/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FNCard;
@class FNCardCell;
@protocol FNEntity;

@protocol FNCardCellDelegate <NSObject>

- (void)cardCellDidToggleVisiblity:(FNCardCell *)cell;
- (void)cardCellDidTapDetailsButton:(FNCardCell *)cell;
- (void)cardCell:(FNCardCell *)cell didTapEntity:(id<FNEntity>)entity;
- (void)cardCellDidTapEntitiesButton:(FNCardCell *)cell;
- (void)cardCellDidTapColorButton:(FNCardCell *)cell;

@end


@interface FNCardCell : UITableViewCell

@property (nonatomic, assign) id<FNCardCellDelegate> delegate;

- (void)updateCellWithCard:(FNCard *)card;

@end
