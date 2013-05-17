//
//  FNCaseFileTableViewController.h
//  FieldNotebook
//
//  Created by Ryan Worl on 3/22/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FNEntity.h"

@class FNCaseFile;

@protocol FNCaseFileSelectionDelegate <NSObject>

- (void)addCaseFileToMap:(FNCaseFile *)caseFile;
- (void)removeCaseFileFromMap:(FNCaseFile *)caseFile;
- (void)didSelectEntity:(id<FNEntity>)entity;
- (void)enableCreationButtons;
- (void)disableCreationButtons;
- (void)reloadCurrentCaseFile;

@end

@interface FNCaseFileTableViewController : UITableViewController

@property (nonatomic, assign) id<FNCaseFileSelectionDelegate> delegate;

@end
