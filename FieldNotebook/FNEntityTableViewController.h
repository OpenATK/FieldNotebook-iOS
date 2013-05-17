//
//  FNEntityTableViewController.h
//  FieldNotebook
//
//  Created by Ryan Worl on 3/22/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNCaseFileTableViewController.h"

@interface FNEntityTableViewController : UITableViewController

@property (nonatomic, assign) id<FNCaseFileSelectionDelegate> delegate;

- (id)initWithEntities:(NSMutableArray *)entities;

@end
