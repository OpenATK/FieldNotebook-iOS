//
//  FNCaseFileTableViewController.m
//  FieldNotebook
//
//  Created by Ryan Worl on 3/22/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import "FNCaseFileTableViewController.h"
#import "FNCardTableViewController.h"
#import "FNEntityInspectorViewController.h"

#import "FNDataManager.h"

#import "FNPoint.h"
#import "FNCard.h"
#import "FNCaseFile.h"

@interface FNCaseFileTableViewController () <FNEntityInspectorDelegate>

@property (nonatomic, strong) NSMutableArray* caseFiles;

@end

@implementation FNCaseFileTableViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = @"FieldNotebook";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:.4267 green:.3373 blue:.2627 alpha:1.0];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapAdd:)];
    
    /*
    FNPoint* p = [[FNPoint alloc] init];
    p.coordinate = CLLocationCoordinate2DMake(37.786996, -122.419281);
    p.title = @"Point 1";
    p.color = [UIColor redColor];
    
    FNCard* c = [[FNCard alloc] init];
    c.entities = (@[p]).mutableCopy;
    c.title = @"Points";
    c.subtitle = @"All the test points";
    
    FNCaseFile* cf = [[FNCaseFile alloc] init];
    cf.cards = @[c].mutableCopy;
    cf.title = @"Case File 1";
    
    self.caseFiles = @[cf].mutableCopy;
    
    [[FNDataManager sharedManager] saveCaseFiles:self.caseFiles];
     */
    
    [[FNDataManager sharedManager] loadCaseFilesWithBlock:^(NSArray *objects, NSError *error) {
        self.caseFiles = (NSMutableArray *)objects;
        [self.tableView reloadData];
    }];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"FieldNotebook";
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.title = @"Back";
}

#pragma mark - FNEntityInspectorDelegate

- (void)entityInspector:(FNEntityInspectorViewController *)inspector didDeleteEntity:(id<FNEntity>)entity
{
    [self.caseFiles removeObject:entity];
    [self.tableView reloadData];
}

#pragma mark - NSNotificationCenter callbacks

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [[FNDataManager sharedManager] saveCaseFiles:self.caseFiles];
}

#pragma mark - BarButtonItem callbacks

- (void)didTapAdd:(UIBarButtonItem *)button
{
    FNCaseFile* caseFile = [[FNCaseFile alloc] init];
    
    [self.caseFiles addObject:caseFile];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.caseFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    FNCaseFile* file = self.caseFiles[indexPath.row];
    
    cell.textLabel.text = file.title;
    
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    id<FNEntity> ent = self.caseFiles[indexPath.row];
    
    FNEntityInspectorViewController* vc = [[FNEntityInspectorViewController alloc] initWithEntity:ent];
    vc.inspectorDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FNCaseFile* f = self.caseFiles[indexPath.row];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(addCaseFileToMap:)]) {
        [self.delegate addCaseFileToMap:f];
    }
    
    FNCardTableViewController* vc = [[FNCardTableViewController alloc] initWithCards:f.cards];
    vc.delegate = self.delegate;
    vc.title = f.title;
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
