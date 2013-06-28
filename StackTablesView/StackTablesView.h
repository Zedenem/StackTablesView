//
//  StackTablesView.h
//  StackTablesView
//
//  Created by Zouhair on 12/06/13.
//  Copyright (c) 2013 Zedenem. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StackTablesView;

#pragma mark - StackTablesViewDataSource
@protocol StackTablesViewDataSource <NSObject>

@optional
/** @name Levels */
#pragma mark Levels
- (NSInteger)numberOfLevelsInStackTablesView:(StackTablesView *)stackTablesView;

/** @name Levels Titles Height */
#pragma mark Levels Titles Height
- (CGFloat)heightForLevelsTitlesInStackTablesView:(StackTablesView *)stackTablesView;

/** @name Levels Titles */
#pragma mark Levels Titles
- (NSString *)stackTablesView:(StackTablesView *)stackTablesView titleAtLevel:(NSInteger)level;

/** @name Levels Title Views */
#pragma mark Levels Title Views
- (UIView *)stackTablesView:(StackTablesView *)stackTablesView titleViewAtLevel:(NSInteger)level;

/** @name Sections */
#pragma mark Sections
- (NSInteger)stackTablesView:(StackTablesView *)stackTablesView numberOfSectionsAtLevel:(NSInteger)level;

/** @name Sections Headers & Footers */
#pragma mark Sections Headers & Footers
- (NSString *)stackTablesView:(StackTablesView *)stackTablesView level:(NSInteger)level titleForHeaderInSection:(NSInteger)section;
- (NSString *)stackTablesView:(StackTablesView *)stackTablesView level:(NSInteger)level titleForFooterInSection:(NSInteger)section;

@required
/** @name Rows */
#pragma mark Rows
- (NSInteger)stackTablesView:(StackTablesView *)stackTablesView level:(NSInteger)level numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)stackTablesView:(StackTablesView *)stackTablesView level:(NSInteger)level cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - StackTablesViewDelegate
@protocol StackTablesViewDelegate <NSObject>

@optional
/** @name Current Level Changed */
#pragma mark Current Level Changed
- (void)stackTablesView:(StackTablesView *)stackTablesView currentLevelDidChange:(NSInteger)currentLevel;

/** @name Sections Headers & Footers */
#pragma mark Sections Headers & Footers
- (CGFloat)stackTablesView:(StackTablesView *)stackTablesView level:(NSInteger)level heightForHeaderInSection:(NSInteger)section;
- (CGFloat)stackTablesView:(StackTablesView *)stackTablesView level:(NSInteger)level heightForFooterInSection:(NSInteger)section;
- (UIView *)stackTablesView:(StackTablesView *)stackTablesView level:(NSInteger)level viewForHeaderInSection:(NSInteger)section;
- (UIView *)stackTablesView:(StackTablesView *)stackTablesView level:(NSInteger)level viewForFooterInSection:(NSInteger)section;

/** @name Rows */
#pragma mark Rows
- (CGFloat)stackTablesView:(StackTablesView *)stackTablesView level:(NSInteger)level heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCellSeparatorStyle)stackTablesView:(StackTablesView *)stackTablesView separatorStyleForLevel:(NSInteger)level;
- (void)stackTablesView:(StackTablesView *)stackTablesView level:(NSInteger)level willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)stackTablesView:(StackTablesView *)stackTablesView level:(NSInteger)level willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)stackTablesView:(StackTablesView *)stackTablesView level:(NSInteger)level didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - StackTablesView
@interface StackTablesView : UIView

#pragma mark Properties
@property (nonatomic, assign) IBOutlet id<StackTablesViewDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id<StackTablesViewDelegate> delegate;

#pragma mark Reload Data
- (void)reloadData;

#pragma mark Access UITableViews
@property (nonatomic, assign, readonly) NSInteger currentLevel;
@property (nonatomic, readonly) UITableView *currentTableView;
- (UITableView *)tableViewAtLevel:(NSInteger)level;
- (UITableViewCell *)tableViewAtLevel:(NSInteger)level dequeueReusableCellWithIdentifier:(NSString *)cellIdentifier;

@end