//
//  FNCardTableViewController.h
//  FieldNotebook
//
//  Created by Ryan Worl on 3/22/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FNCaseFileTableViewController.h"

@interface FNCardTableViewController : UITableViewController

@property (nonatomic, retain) FNCaseFile* caseFile;
@property (nonatomic, assign) id<FNCaseFileSelectionDelegate> delegate;

- (id)initWithCards:(NSMutableArray *)cards;

@end
