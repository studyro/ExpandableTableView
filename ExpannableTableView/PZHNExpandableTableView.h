//
//  PZHNExpandableTableView.h
//  ExpannableTableView
//
//  Created by Zhang Studyro on 12-10-30.
//  Copyright (c) 2012年 Studyro Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

// TODO : add section support and editing support.

@protocol PZHNExpandableTableViewDataSource;
@protocol PZHNExpandableTableViewDelegate;

@interface PZHNExpandableTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) id<PZHNExpandableTableViewDelegate> myDelegate;
@property (nonatomic, assign) id<PZHNExpandableTableViewDataSource> myDataSource;

@property (nonatomic, assign, readonly) NSInteger numberOfRows;

- (void)expandOrCollapseAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (NSIndexPath *)parentIndexPathOfItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol PZHNExpandableTableViewDataSource <NSObject>

@required
- (UITableViewCell *)tableView:(PZHNExpandableTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withDataTreePath:(NSIndexPath *)treePath;

- (NSInteger)tableView:(PZHNExpandableTableView *)tableView baseNumberOfRowsInSection:(NSInteger)section; //temporarily support section 0

- (NSUInteger)tableView:(PZHNExpandableTableView *)tableView numberOfChildrenRowsForTreePath:(NSIndexPath *)treePath;

@optional
- (CGFloat)tableView:(PZHNExpandableTableView *)tableView heightForFooterInSection:(NSInteger)section;

- (CGFloat)tableView:(PZHNExpandableTableView *)tableView heightForHeaderInSection:(NSInteger)section;

- (NSString *)tableView:(PZHNExpandableTableView *)tableView titleForFooterInSection:(NSInteger)section;

- (NSString *)tableView:(PZHNExpandableTableView *)tableView titleForHeaderInSection:(NSInteger)section;

@end

@protocol PZHNExpandableTableViewDelegate <UITableViewDelegate>

@required
- (CGFloat)tableView:(PZHNExpandableTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withDataTreePath:(NSIndexPath *)treePath;

@end