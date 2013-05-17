//
//  MapViewController.h
//  FieldNotebook
//
//  Created by Ryan Worl on 3/19/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FNCaseFileTableViewController.h"
#import "FNCaseFile.h"
#import "FNCard.h"
#import "FNEntity.h"

#define FNMapViewControllerDidCreateNewEntity @"FNMapViewDidCreateNewEntity"

@interface MapViewController : UIViewController <FNCaseFileSelectionDelegate, UISplitViewControllerDelegate>

@end
