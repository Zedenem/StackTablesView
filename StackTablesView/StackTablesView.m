//
//  StackTablesView.m
//  StackTablesView
//
//  Created by Zouhair on 12/06/13.
//  Copyright (c) 2013 Zedenem. All rights reserved.
//

#import "StackTablesView.h"

#pragma mark - StackTablesView Interface (Private)
@interface StackTablesView () <UITableViewDataSource, UITableViewDelegate>

#pragma mark Properties
@property (nonatomic, retain) NSMutableArray *tableViews;
@property (nonatomic, retain) NSMutableArray *titleViews;

#pragma mark Lifecycle
- (void)setup;

#pragma mark Access UITableViews
@property (nonatomic, assign, readwrite) NSInteger currentLevel;
- (NSInteger)numberOfTableViews;
- (UITableView *)tableViewAtIndex:(NSInteger)index;

#pragma mark Access Title Views
@property (nonatomic, readonly) CGFloat titleViewHeight;
@property (nonatomic, readonly) UIView *currentTitleView;
- (NSInteger)numberOfTitleViews;
- (UIView *)titleViewAtIndex:(NSInteger)index;

#pragma mark UITableView Selection
- (void)selectTableView:(UITapGestureRecognizer *)sender;

@end

#pragma mark - StackTablesView Implementation
@implementation StackTablesView

#pragma mark Properties
@synthesize dataSource = _dataSource;
- (void)setDataSource:(id<StackTablesViewDataSource>)dataSource {
	if (![_dataSource isEqual:dataSource]) {
		_dataSource = dataSource;
		[self reloadData];
	}
}
@synthesize delegate = _delegate;
- (void)setDelegate:(id<StackTablesViewDelegate>)delegate {
	if (![_delegate isEqual:delegate]) {
		_delegate = delegate;
		[self reloadData];
	}
}
@synthesize tableViews = _tableViews;
- (NSMutableArray *)tableViews {
	if (!_tableViews) {
		_tableViews = [[NSMutableArray alloc] initWithCapacity:2];
	}
	return _tableViews;
}
@synthesize titleViews = _titleViews;
- (NSMutableArray *)titleViews {
	if (!_titleViews) {
		_titleViews = [[NSMutableArray alloc] initWithCapacity:2];
	}
	return _titleViews;
}

#pragma mark Lifecycle
- (void)setup {
	[self setClipsToBounds:YES];
	[self setCurrentLevel:0];
	[self reloadData];
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setup];
    }
    return self;
}
- (void)awakeFromNib {
	[super awakeFromNib];
	[self setup];
}
- (void)dealloc {
	[_tableViews release];
	[_titleViews release];
	[super dealloc];
}
- (void)layoutSubviews {
	[super layoutSubviews];
	[self layoutTableViews];
}
- (void)layoutTableViews {
	CGFloat tableViewHeight = self.bounds.size.height - ([self numberOfTableViews] * self.titleViewHeight);
	for (int i = 0; i < [self numberOfTableViews]; i++) {
		UITableView *tableView = [self tableViewAtIndex:i];
		CGFloat yCoordinate = self.bounds.origin.y + ((i+1) * self.titleViewHeight);
		if (i > self.currentLevel) {
			
			UITableView *previousTableView = [self tableViewAtIndex:i-1];
			NSInteger previousTableViewLastSection = [previousTableView numberOfSections] - 1;
			CGRect lastSectionRect = [previousTableView rectForSection:previousTableViewLastSection];
			CGFloat dynamicTableViewHeight = lastSectionRect.origin.y + lastSectionRect.size.height;
			if (tableViewHeight - dynamicTableViewHeight < 120.0 || dynamicTableViewHeight > tableViewHeight) {
				yCoordinate += tableViewHeight;
			}
			else {
				yCoordinate += lastSectionRect.origin.y + lastSectionRect.size.height;
			}
		}
		CGFloat specificTableViewHeight = tableViewHeight;
		if (yCoordinate < self.bounds.size.height) {
			specificTableViewHeight = self.bounds.size.height - yCoordinate - (self.titleViewHeight * ([self numberOfTableViews] - (i + 1)));
		}
		[tableView setFrame:CGRectMake(self.bounds.origin.x,
									   yCoordinate,
									   self.bounds.size.width,
									   specificTableViewHeight)];
		
		UIView *titleView = [self titleViewAtIndex:i];
		[titleView setFrame:CGRectMake(self.bounds.origin.x,
									   yCoordinate - self.titleViewHeight,
									   self.bounds.size.width,
									   self.titleViewHeight)];
	}
}

#pragma mark Reload Data
- (void)reloadData {
	NSInteger numberOfTableViews = 1;
	if ([self.dataSource respondsToSelector:@selector(numberOfLevelsInStackTablesView:)]) {
		numberOfTableViews = [self.dataSource numberOfLevelsInStackTablesView:self];
	}
	
	[self.tableViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[self.tableViews removeAllObjects];
	
	[self.titleViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[self.titleViews removeAllObjects];
	
	[self setCurrentLevel:0];
	
	for (int i = 0; i < numberOfTableViews; i++) {
		UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		[self.tableViews addObject:tableView];
		[self addSubview:tableView];
		
		[tableView setDataSource:self];
		[tableView setDelegate:self];
		[tableView release];
		
		if ([self.delegate respondsToSelector:@selector(stackTablesView:separatorStyleForLevel:)]) {
			[tableView setSeparatorStyle:[self.delegate stackTablesView:self separatorStyleForLevel:i]];
		}
		
		id titleView = nil;
		if ([self.dataSource respondsToSelector:@selector(stackTablesView:titleViewAtLevel:)]) {
			titleView = [self.dataSource stackTablesView:self titleViewAtLevel:i];
			[self.titleViews addObject:titleView];
		}
		else {
			titleView = [UIButton buttonWithType:UIButtonTypeCustom];
			[self.titleViews addObject:titleView];
			if ([self.dataSource respondsToSelector:@selector(stackTablesView:titleAtLevel:)]) {
				[titleView setTitle:[self.dataSource stackTablesView:self titleAtLevel:i] forState:UIControlStateNormal];
			}
		}
		[self addSubview:titleView];
		
		UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectTableView:)];
		[titleView addGestureRecognizer:tapGestureRecognizer];
		[tapGestureRecognizer release];
	}
	
	[self setNeedsLayout];
}

#pragma mark Access UITableViews
@synthesize currentLevel = _currentLevel;
- (void)setCurrentLevel:(NSInteger)currentLevel {
	if (_currentLevel != currentLevel) {
		if (_currentLevel < currentLevel) {
			[self.currentTableView setAlpha:0.0];
		}
		_currentLevel = currentLevel;
		[self.currentTableView setAlpha:1.0];
		[self layoutTableViews];
	}
}
- (void)setCurrentLevel:(NSInteger)currentLevel animated:(BOOL)animated {
	if (animated) {
		[UIView animateWithDuration:0.2
						 animations:^{
							 [self setCurrentLevel:currentLevel];
						 }];
	}
	else {
		[self setCurrentLevel:currentLevel];
	}
}
@dynamic currentTableView;
- (UITableView *)currentTableView {
	return [self tableViewAtIndex:self.currentLevel];
}
- (NSInteger)numberOfTableViews {
	return [self.tableViews count];
}
- (UITableView *)tableViewAtIndex:(NSInteger)index {
	return [self.tableViews objectAtIndex:index];
}
- (NSInteger)indexOfTableView:(UITableView *)tableView {
	return [self.tableViews indexOfObject:tableView];
}
- (UITableView *)tableViewAtLevel:(NSInteger)level {
	return [self tableViewAtIndex:level];
}
- (UITableViewCell *)tableViewAtLevel:(NSInteger)level dequeueReusableCellWithIdentifier:(NSString *)cellIdentifier {
	return [[self tableViewAtIndex:level] dequeueReusableCellWithIdentifier:cellIdentifier];
}
														 
#pragma mark Access Title Views
@dynamic titleViewHeight;
- (CGFloat)titleViewHeight {
	CGFloat titleViewHeight = 44.0;
	
	if ([self.dataSource respondsToSelector:@selector(heightForLevelsTitlesInStackTablesView:)]) {
		titleViewHeight = [self.dataSource heightForLevelsTitlesInStackTablesView:self];
	}
	
	return titleViewHeight;
}
@dynamic currentTitleView;
- (UIView *)currentTitleView {
	return [self titleViewAtIndex:self.currentLevel];
}
- (NSInteger)numberOfTitleViews {
	return [self.titleViews count];
}
- (UIView *)titleViewAtIndex:(NSInteger)index {
	return [self.titleViews objectAtIndex:index];
}

#pragma mark UITableView Selection
- (void)selectTableView:(UITapGestureRecognizer *)sender {
	NSInteger selectedTitleViewIndex = [self.titleViews indexOfObject:sender.view];
	if (selectedTitleViewIndex != NSNotFound) {
		if (selectedTitleViewIndex == self.currentLevel && [self numberOfTableViews] == 2) {
			selectedTitleViewIndex = (selectedTitleViewIndex == 0) ? 1 : 0;
		}
		[self setCurrentLevel:selectedTitleViewIndex animated:YES];
	}
}

#pragma mark UITableViewDataSource & UITableViewDelegate
#pragma mark Sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger numberOfSectionsInTableView = 1;
	
	NSInteger tableViewIndex = [self indexOfTableView:tableView];
	if (tableViewIndex != NSNotFound && [self.dataSource respondsToSelector:@selector(stackTablesView:numberOfSectionsAtLevel:)]) {
		numberOfSectionsInTableView = [self.dataSource stackTablesView:self numberOfSectionsAtLevel:tableViewIndex];
	}
	
	return numberOfSectionsInTableView;
}
#pragma mark Sections Headers & Footers
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *titleForHeaderInSection = nil;
    if ([self.dataSource respondsToSelector:@selector(stackTablesView:level:titleForHeaderInSection:)]) {
		titleForHeaderInSection = [self.dataSource stackTablesView:self level:self.currentLevel titleForHeaderInSection:section];
	}
	return titleForHeaderInSection;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	NSString *titleForFooterInSection = nil;
    if ([self.dataSource respondsToSelector:@selector(stackTablesView:level:titleForFooterInSection:)]) {
		titleForFooterInSection = [self.dataSource stackTablesView:self level:self.currentLevel titleForFooterInSection:section];
	}
	return titleForFooterInSection;
}
#pragma mark Rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger numberOfRows = 0;
	if ([self.dataSource respondsToSelector:@selector(stackTablesView:level:numberOfRowsInSection:)]) {
		numberOfRows = [self.dataSource stackTablesView:self level:[self indexOfTableView:tableView] numberOfRowsInSection:section];
	}
	return numberOfRows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	if ([self.dataSource respondsToSelector:@selector(stackTablesView:level:cellForRowAtIndexPath:)]) {
		cell = [self.dataSource stackTablesView:self level:[self indexOfTableView:tableView] cellForRowAtIndexPath:indexPath];
	}
	return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark Sections Headers & Footers
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	CGFloat heightForHeader = 0.0;
	if ([self.delegate respondsToSelector:@selector(stackTablesView:level:viewForHeaderInSection:)] || [self.delegate respondsToSelector:@selector(stackTablesView:level:titleForHeaderInSection:)]) {
		heightForHeader = tableView.sectionHeaderHeight;
	}
	if ([self.delegate respondsToSelector:@selector(stackTablesView:level:heightForHeaderInSection:)]) {
		heightForHeader = [self.delegate stackTablesView:self level:[self indexOfTableView:tableView] heightForHeaderInSection:section];
	}
	return heightForHeader;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	CGFloat heightForFooter = 0.0;
	if ([self.delegate respondsToSelector:@selector(stackTablesView:level:viewForFooterInSection:)] || [self.delegate respondsToSelector:@selector(stackTablesView:level:titleForFooterInSection:)]) {
		heightForFooter = tableView.sectionFooterHeight;
	}
	if ([self.delegate respondsToSelector:@selector(stackTablesView:level:heightForFooterInSection:)]) {
		heightForFooter = [self.delegate stackTablesView:self level:[self indexOfTableView:tableView] heightForFooterInSection:section];
	}
	return heightForFooter;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView * viewForHeaderInSection = nil;
    if ([self.delegate respondsToSelector:@selector(stackTablesView:level:viewForHeaderInSection:)]) {
		viewForHeaderInSection = [self.delegate stackTablesView:self level:[self indexOfTableView:tableView] viewForHeaderInSection:section];
	}
    return viewForHeaderInSection;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView * viewForFooterInSection = nil;
    if ([self.delegate respondsToSelector:@selector(stackTablesView:level:viewForFooterInSection:)]) {
		viewForFooterInSection = [self.delegate stackTablesView:self level:[self indexOfTableView:tableView] viewForFooterInSection:section];
	}
    return viewForFooterInSection;
}
#pragma mark Rows
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat rowHeight = tableView.rowHeight;
	if ([self.delegate respondsToSelector:@selector(stackTablesView:level:heightForRowAtIndexPath:)]) {
		rowHeight = [self.delegate stackTablesView:self level:[self indexOfTableView:tableView] heightForRowAtIndexPath:indexPath];
	}
	return rowHeight;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(stackTablesView:level:willDisplayCell:forRowAtIndexPath:)]) {
		[self.delegate stackTablesView:self level:[self indexOfTableView:tableView] willDisplayCell:cell forRowAtIndexPath:indexPath];
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(stackTablesView:level:willSelectRowAtIndexPath:)]) {
		return [self.delegate stackTablesView:self level:[self indexOfTableView:tableView] willSelectRowAtIndexPath:indexPath];
	}
	else {
		return indexPath;
	}
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(stackTablesView:level:didSelectRowAtIndexPath:)]) {
		[self.delegate stackTablesView:self level:[self indexOfTableView:tableView] didSelectRowAtIndexPath:indexPath];
	}
}


@end


