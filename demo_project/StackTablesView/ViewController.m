//
//  ViewController.m
//  DoubleTablesView
//
//  Created by Zouhair on 12/06/13.
//  Copyright (c) 2013 Zedenem. All rights reserved.
//

#import "ViewController.h"
#import "StackTablesView.h"

@interface ViewController () <StackTablesViewDataSource, StackTablesViewDelegate>

@end

@implementation ViewController

#pragma mark Lifecycle
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

#pragma mark - StackTablesViewDataSource
#pragma mark Levels
- (NSInteger)numberOfLevelsInStackTablesView:(StackTablesView *)stackTablesView {
	return 3;
}

#pragma mark Levels Titles Height
- (CGFloat)heightForLevelsTitlesInStackTablesView:(StackTablesView *)stackTablesView {
	return 64.0;
}

#pragma mark Levels Titles
- (NSString *)stackTablesView:(StackTablesView *)stackTablesView titleAtLevel:(NSInteger)level {
	return [NSString stringWithFormat:@"Level %d", level];
}

#pragma mark Levels Title Views
- (UIView *)stackTablesView:(StackTablesView *)stackTablesView titleViewAtLevel:(NSInteger)level {
	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, stackTablesView.bounds.size.width, 0.0)];
	[titleView setBackgroundColor:[UIColor greenColor]];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, titleView.bounds.size.width - 10.0, 0.0)];
	[titleView addSubview:titleLabel];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	[titleLabel setText:[stackTablesView.dataSource stackTablesView:stackTablesView titleAtLevel:level]];
	
	return titleView;
}

#pragma mark Sections
- (NSInteger)stackTablesView:(StackTablesView *)stackTablesView numberOfSectionsAtLevel:(NSInteger)level {
	return level + 1;
}
#pragma mark Sections Headers & Footers
- (NSString *)stackTablesView:(StackTablesView *)stackTablesView level:(NSInteger)level titleForHeaderInSection:(NSInteger)section {
	return [NSString stringWithFormat:@"{%d, %d}", level, section];
}
#pragma mark Rows
- (NSInteger)stackTablesView:(StackTablesView *)stackTablesView level:(NSInteger)level numberOfRowsInSection:(NSInteger)section {
	return level*2 + section*2 + 10;
}
- (UITableViewCell *)stackTablesView:(StackTablesView *)stackTablesView level:(NSInteger)level cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = NSStringFromClass([UITableViewCell class]);
	
	UITableViewCell *cell = [stackTablesView tableViewAtLevel:level dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	[cell.textLabel setText:[NSString stringWithFormat:@"{%d, %d, %d}", level, indexPath.section, indexPath.row]];
	
	return cell;
}

@end
