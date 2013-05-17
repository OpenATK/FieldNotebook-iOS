//
//  FNEntityTableViewController.m
//  FieldNotebook
//
//  Created by Ryan Worl on 3/22/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import "FNEntityTableViewController.h"
#import "FNEntityInspectorViewController.h"
#import "MapViewController.h"
#import "FNEntity.h"

@interface FNEntityTableViewController () <FNEntityInspectorDelegate>

@property (nonatomic, strong) NSMutableArray* entities;

@end

@implementation FNEntityTableViewController

- (id)initWithEntities:(NSMutableArray *)entities
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.entities = entities;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapDidCreateNewEntity:) name:FNMapViewControllerDidCreateNewEntity object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([self.delegate respondsToSelector:@selector(enableCreationButtons)]) {
        [self.delegate enableCreationButtons];
    }
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if([self.delegate respondsToSelector:@selector(disableCreationButtons)]) {
        [self.delegate disableCreationButtons];
    }
}

- (void)mapDidCreateNewEntity:(NSNotification *)note
{
    NSLog(@"%@", note.object);
    if ([note.object conformsToProtocol:@protocol(FNEntity)]) {
        NSLog(@"adding entity");
        [self.entities addObject:note.object];
        [self.tableView reloadData];
    }
}

#pragma mark - FNEntityInspectorDelegate

- (void)entityInspector:(FNEntityInspectorViewController *)inspector didDeleteEntity:(id<FNEntity>)entity
{
    [self.entities removeObject:entity];
    [self.tableView reloadData];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadCurrentCaseFile)]) {
        [self.delegate reloadCurrentCaseFile];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.entities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellID];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    id<FNEntity> ent = self.entities[indexPath.row];
    
    NSString* subtitle = [ent humanType];
    if ([ent.subtitle length]) {
        subtitle = [NSString stringWithFormat:@"%@ - %@", ent.subtitle,[ent humanType]];
    }
    
    cell.textLabel.text = ent.title;
    cell.detailTextLabel.text = subtitle;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    id<FNEntity> ent = self.entities[indexPath.row];
    
    FNEntityInspectorViewController* vc = [[FNEntityInspectorViewController alloc] initWithEntity:ent];
    vc.delegate = self.delegate;
    vc.inspectorDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    id<FNEntity> ent = self.entities[indexPath.row];
    NSLog(@"entity: %@", ent);
    if ([self.delegate respondsToSelector:@selector(didSelectEntity:)]) {
        NSLog(@"entity sel: %@", ent);

        [self.delegate didSelectEntity:ent];
    }
}

@end
