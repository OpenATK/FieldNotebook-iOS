//
//  FNEntityInspectorViewController.h
//  FieldNotebook
//
//  Created by Ryan Worl on 3/26/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNCaseFileTableViewController.h"
#import "FNEntity.h"

@class FNEntityInspectorViewController;

@protocol FNEntityInspectorDelegate <NSObject>

-(void)entityInspector:(FNEntityInspectorViewController *)inspector didDeleteEntity:(id<FNEntity>)entity;

@end

@interface FNEntityInspectorViewController : UITableViewController

- (id)initWithEntity:(id<FNEntity>)entity;

@property (nonatomic, assign) id<FNEntityInspectorDelegate> inspectorDelegate;
@property (nonatomic, assign) id<FNCaseFileSelectionDelegate> delegate;

@end
