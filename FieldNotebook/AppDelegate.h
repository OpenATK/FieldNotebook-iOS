//
//  AppDelegate.h
//  FieldNotebook
//
//  Created by Ryan Worl on 3/19/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapViewController;
@class FNCaseFileTableViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UISplitViewController* splitViewController;
@property (nonatomic, strong) MapViewController* mapViewController;
@property (nonatomic, strong) FNCaseFileTableViewController* caseFileViewController;

@property (strong, nonatomic) UIWindow *window;

@end
