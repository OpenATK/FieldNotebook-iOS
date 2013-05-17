//
//  FNCardTableViewController.m
//  FieldNotebook
//
//  Created by Ryan Worl on 3/22/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import "FNCardTableViewController.h"
#import "FNEntityTableViewController.h"
#import "FNEntityInspectorViewController.h"

#import "InfColorPickerController.h"

#import "FNCardCell.h"

#import "FNCard.h"

@interface FNCardTableViewController () <FNCardCellDelegate, FNEntityInspectorDelegate, InfColorPickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray* cards;
@property (nonatomic, strong) FNCard* currentCard;

@end

@implementation FNCardTableViewController

- (id)initWithCards:(NSMutableArray *)cards
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.cards = cards;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapAdd:)];
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem, addButton];
    
    self.tableView.rowHeight = 280.0f;
    [self.tableView registerClass:[FNCardCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {
        [self.delegate removeCaseFileFromMap:nil];
    }
}

#pragma mark - FNEntityInspectorDelegate


- (void)entityInspector:(FNEntityInspectorViewController *)inspector didDeleteEntity:(id<FNEntity>)entity
{
    [self.cards removeObject:entity];
    [self.tableView reloadData];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadCurrentCaseFile)]) {
        [self.delegate reloadCurrentCaseFile];
    }
}

#pragma mark - MNColorSelectionViewControllerDelegate

- (void)colorPickerControllerDidFinish:(InfColorPickerController *)controller
{
    self.currentCard.color = controller.resultColor;
    
    for (id<FNEntity> ent in self.currentCard.entities) {
        [ent setColor:controller.resultColor];
    }
    
    [self.tableView reloadData];
}

- (void)colorPickerControllerDidChangeColor:(InfColorPickerController *)controller
{
    self.currentCard.color = controller.resultColor;

    for (id<FNEntity> ent in self.currentCard.entities) {
        [ent setColor:controller.resultColor];
    }
    
    [self.tableView reloadData];
}

#pragma mark - FNCardCellDelegate

- (void)cardCell:(FNCardCell *)cell didTapEntity:(id<FNEntity>)entity
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectEntity:)]) {
        [self.delegate didSelectEntity:entity];
    }
}

- (void)cardCellDidToggleVisiblity:(FNCardCell *)cell
{
    FNCard* card = self.cards[[self.tableView indexPathForCell:cell].row];
    card.visible = !card.visible;
    
    [self.delegate reloadCurrentCaseFile];
}

- (void)cardCellDidTapDetailsButton:(FNCardCell *)cell
{
    id<FNEntity> ent = self.cards[[self.tableView indexPathForCell:cell].row];
    
    FNEntityInspectorViewController* vc = [[FNEntityInspectorViewController alloc] initWithEntity:ent];
    vc.delegate = self.delegate;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cardCellDidTapEntitiesButton:(FNCardCell *)cell
{
    FNCard* card = self.cards[[self.tableView indexPathForCell:cell].row];
    
    FNEntityTableViewController* vc = [[FNEntityTableViewController alloc] initWithEntities:card.entities];
    vc.delegate = self.delegate;
    vc.title = card.title;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cardCellDidTapColorButton:(FNCardCell *)cell
{
    FNCard* card = self.cards[[self.tableView indexPathForCell:cell].row];
    self.currentCard = card;

    InfColorPickerController* vc = [InfColorPickerController colorPickerViewController];
    vc.delegate = self;
    vc.sourceColor = self.currentCard.color;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - BarButtonItem callbacks

- (void)didTapAdd:(UIBarButtonItem *)button
{
    FNCard* c = [[FNCard alloc] init];
    c.title = @"Card";
    c.subtitle = @"";
    [self.cards addObject:c];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"Cell";
    FNCardCell *cell = (FNCardCell *)[tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];
    cell.delegate = self;
    
    FNCard* card = self.cards[indexPath.row];
    [cell updateCellWithCard:card];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id object = self.cards[sourceIndexPath.row];
    [self.cards removeObjectAtIndex:sourceIndexPath.row];
    [self.cards insertObject:object atIndex:destinationIndexPath.row];
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    id<FNEntity> ent = self.cards[indexPath.row];
    
    FNEntityInspectorViewController* vc = [[FNEntityInspectorViewController alloc] initWithEntity:ent];
    vc.delegate = self.delegate;
    vc.inspectorDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentCard = self.cards[indexPath.row];
}

@end
