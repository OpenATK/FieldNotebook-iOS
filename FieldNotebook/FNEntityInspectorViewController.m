//
//  FNEntityInspectorViewController.m
//  FieldNotebook
//
//  Created by Ryan Worl on 3/26/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import "FNEntityInspectorViewController.h"
#import "FNCard.h"

#define SWITCH_TAG 1001
#define TEXTFIELD_TAG 100

@interface FNEntityInspectorViewController ()

@property (nonatomic, strong) id<FNEntity> entity;

@property (nonatomic, strong) NSArray* cells;

@end

@implementation FNEntityInspectorViewController

- (id)initWithEntity:(id<FNEntity>)entity
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    self.title = @"Properties";
    self.entity = entity;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initDeleteButton];
    
    if ([self.entity respondsToSelector:@selector(photoURL)]) {
        NSURL* photoURL = [self.entity photoURL];
        if (photoURL) {
            NSLog(@"%@", photoURL);
            UIImage* image = [UIImage imageWithContentsOfFile:photoURL.path];
            UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = CGRectMake(0, 0, 320, 320);
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            self.tableView.tableHeaderView = imageView;
        }        
    }
    
    if ([self.entity isKindOfClass:[FNCard class]]) {
        FNCard* card = (FNCard *)self.entity;
        
        self.cells =
        (@[
         [self textFieldCellWithTitle:@"Name" text:[self.entity title]],
         [self textFieldCellWithTitle:@"Description" text:[self.entity subtitle]],
         [self switchCellWithTitle:@"Visible" state:card.isVisible]
         ]);
    } else {
        self.cells =
        (@[
         [self textFieldCellWithTitle:@"Name" text:[self.entity title]],
         [self textFieldCellWithTitle:@"Description" text:[self.entity subtitle]]
         ]);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
        
    NSString* title = [self textForTextFieldCell:self.cells[0]];
    NSString* subtitle = [self textForTextFieldCell:self.cells[1]];
    
    if ([self.entity isKindOfClass:[FNCard class]]) {
        BOOL visible = [self valueForSwitchCell:self.cells[2]];

        FNCard* card = (FNCard *)self.entity;
        card.visible = visible;
                
        if ([self.delegate respondsToSelector:@selector(reloadCurrentCaseFile)]) {
            [self.delegate reloadCurrentCaseFile];
        }
    }

    if ([self.entity respondsToSelector:@selector(setTitle:)]) {
        [self.entity setTitle:title];
    }
    if ([self.entity respondsToSelector:@selector(setSubtitle:)]) {
        [self.entity setSubtitle:subtitle];
    }
}

- (void)initDeleteButton
{
    UIImage* background = [[UIImage imageNamed:@"DeleteButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 6, 8, 6)];
    UIButton* delete = [UIButton buttonWithType:UIButtonTypeCustom];
    [[delete titleLabel] setFont:[UIFont boldSystemFontOfSize:20]];
    [[delete titleLabel] setShadowColor:[UIColor darkGrayColor]];
    [[delete titleLabel] setShadowOffset:CGSizeMake(0, -1)];
    [delete setTitle:@"Delete" forState:UIControlStateNormal];
    [delete setBackgroundImage:background forState:UIControlStateNormal];
    [delete setFrame:CGRectMake(10, 0, 300, 44)];
    [delete addTarget:self action:@selector(didTapDelete:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView* container = [[UIView alloc] init];
    container.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    [container addSubview:delete];
    
    self.tableView.tableFooterView = container;
}

#pragma mark - Callbacks

- (void)didTapDelete:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.inspectorDelegate && [self.inspectorDelegate respondsToSelector:@selector(entityInspector:didDeleteEntity:)]) {
        [self.inspectorDelegate entityInspector:self didDeleteEntity:self.entity];
    }
}

#pragma mark - Cell Accessors

- (NSString *)textForTextFieldCell:(UITableViewCell *)cell
{
    UITextField* textField = (UITextField *)[cell.contentView viewWithTag:TEXTFIELD_TAG];
    
    return textField.text;
}

- (BOOL)valueForSwitchCell:(UITableViewCell *)cell
{
    UISwitch* stateSwitch = (UISwitch *)[cell.contentView viewWithTag:SWITCH_TAG];
    
    return stateSwitch.on;
}

#pragma mark - Cell creation

- (UITableViewCell *)textFieldCellWithTitle:(NSString *)title text:(NSString *)text
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                   reuseIdentifier:nil];
    cell.textLabel.text = title;
    
    CGFloat offset = [title sizeWithFont:[UIFont boldSystemFontOfSize:18]].width + 12;
    CGFloat size = self.view.frame.size.width - offset - 25;
    
    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(offset, 13, size, 24)];
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.tag = TEXTFIELD_TAG;
    textField.font = [UIFont systemFontOfSize:14];
    textField.text = text;
    [cell.contentView addSubview:textField];
    
    return cell;
}

- (UITableViewCell *)switchCellWithTitle:(NSString *)title state:(BOOL)state
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                   reuseIdentifier:nil];
    cell.textLabel.text = title;
    
    UISwitch* stateSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(210, 8, 60, 30)];
    stateSwitch.tag = SWITCH_TAG;
    stateSwitch.on = state;
    [cell.contentView addSubview:stateSwitch];
    
    return cell;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cells[indexPath.row];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
