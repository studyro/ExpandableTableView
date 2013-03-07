//
//  PZHNExpandableTableView.m
//  ExpannableTableView
//
//  Created by Zhang Studyro on 12-10-30.
//  Copyright (c) 2012年 Studyro Studio. All rights reserved.
//

#import "PZHNExpandableTableView.h"


@interface PZHNExpandableTableView ()
{
    /*
     All of the expanded tree logic is described by this array.
     Each object of the array is a dictionary contains "numberOfSiblings","level" and "parentObjectReference"
     So you can conform if a cell at indexPath is expanded by checking indexPath+1's -objectForKey:@"parentObjectReference" equals to this cell.
     */
    NSMutableArray *_expandedItemsIndexes;//use MutableArray replace this
    
    // Use to record and tell self how the rowsNumber is changed
    NSMutableDictionary *_rowsChangeRecorder;
}
@end

@implementation PZHNExpandableTableView

@synthesize numberOfRows = _numberOfRows;
@synthesize myDelegate = _myDelegate;
@synthesize myDataSource = _myDataSource;

- (void)dealloc
{
    [_expandedItemsIndexes release];
    [_rowsChangeRecorder release];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [super setDataSource:self];
        [super setDelegate:self];
        _expandedItemsIndexes = [[NSMutableArray alloc] init];
        _rowsChangeRecorder = [[NSMutableDictionary alloc] initWithCapacity:1];
        _numberOfRows = 0;
    }
    return self;
}

#pragma mark - Public Methods

- (void)expandOrCollapseAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    NSIndexPath *treePath = [self _getParentTreePathForItemAtIndex:indexPath.row];
    NSUInteger childrenCount = [self.myDataSource tableView:self numberOfChildrenRowsForTreePath:treePath];
    if (childrenCount) {
        // make a BOOL value to determine whether we are inserting or removing rows
        BOOL subTreeExpanded = [self _subTreeIsExpandedAtIndex:indexPath.row];
        
        NSInteger level = [[[_expandedItemsIndexes objectAtIndex:indexPath.row] objectForKey:@"level"] integerValue];
        
        NSMutableArray *additionIndexPathArray = [[NSMutableArray alloc] init];
        
        if (!subTreeExpanded) {
            [self _insertChildreOfItemAtIndex:indexPath.row inSection:indexPath.section underLevel:level forChildrenCount:childrenCount indicesToFillArray:additionIndexPathArray];
        }
        else {
            [self _removeChildrenOfItemAtIndex:indexPath.row inSection:indexPath.section underLevel:level indicesToFillArray:additionIndexPathArray];
        }
        
        [_rowsChangeRecorder setObject:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:subTreeExpanded?-[additionIndexPathArray count]:[additionIndexPathArray count]], @"changeNum", [NSNumber numberWithInteger:indexPath.section], @"section", nil]
                                forKey:@"changer"];
        [self _rowsNumberWillChange];
        
        [self beginUpdates];
        
        if (subTreeExpanded)
            [self deleteRowsAtIndexPaths:additionIndexPathArray withRowAnimation:UITableViewRowAnimationFade];
        else
            [self insertRowsAtIndexPaths:additionIndexPathArray withRowAnimation:UITableViewRowAnimationMiddle];
        //dataSource methods are going to be automatically involked here
        [self endUpdates];
        
        if (subTreeExpanded && ![self _cellIsVisibleAtIndexPath:indexPath])
            [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        [additionIndexPathArray release];
    }
}

- (NSIndexPath *)parentIndexPathOfItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *infoDicOfItem = [_expandedItemsIndexes objectAtIndex:indexPath.row];
    NSDictionary *parentInfo = [infoDicOfItem objectForKey:@"parentInfo"];
    if (parentInfo) {
        NSIndexPath *parentIndexPath = [NSIndexPath indexPathForRow:[_expandedItemsIndexes indexOfObject:parentInfo] inSection:0];
        return parentIndexPath;
    }
    return nil;
}

#pragma mark - Private Methods

- (BOOL)_subTreeIsExpandedAtIndex:(NSUInteger)index
{
    id selectedInfoRef = [_expandedItemsIndexes objectAtIndex:index];
    id nextRef = [_expandedItemsIndexes objectAtIndex:index+1];
    
    if ([nextRef objectForKey:@"parentInfo"] == selectedInfoRef)
        return YES;
    else
        return NO;
}

- (void)_insertChildreOfItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section underLevel:(NSUInteger)level forChildrenCount:(NSUInteger)childrenCount indicesToFillArray:(NSMutableArray *)additionArray
{
    for (int i = 0; i < childrenCount; i++) {
        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:index+i+1 inSection:section];
        [additionArray addObject:tempIndexPath];
        
        [self _insertItemInfoForParentIndex:index numberInSiblings:i inLevel:level+1];
    }
}

- (void)_removeChildrenOfItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section underLevel:(NSUInteger)selectedLevel indicesToFillArray:(NSMutableArray *)additionArray
{
    // will also remove grand children
    NSUInteger indexItr = index+1;
    if (indexItr >= [_expandedItemsIndexes count]) return;
    NSUInteger itemLevel = [[[_expandedItemsIndexes objectAtIndex:indexItr] objectForKey:@"level"] integerValue];
    while (itemLevel > selectedLevel) {
        // fill the array which tell caller what set of cell to remove
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:indexItr inSection:section];
        [additionArray addObject:indexPath];
        // remove info whose cell was removed (always be index+1)
        [self _removeFirstItemInfoForParentIndex:index];
        
        // boundry detection
        if (index + 1 >= [_expandedItemsIndexes count])
            break;
        indexItr ++;
        itemLevel = [[[_expandedItemsIndexes objectAtIndex:index+1] objectForKey:@"level"] integerValue];
    }
}

- (void)_rowsNumberWillChange
{
    NSDictionary *changeInfo = [_rowsChangeRecorder objectForKey:@"changer"];
    if (changeInfo) {
        NSInteger changeNum = [[changeInfo objectForKey:@"changeNum"] integerValue];
        _numberOfRows += changeNum;
        
        [_rowsChangeRecorder removeAllObjects];
    }
}

- (void)_insertItemInfoForParentIndex:(NSUInteger)parentIndex numberInSiblings:(NSInteger)nbr inLevel:(NSInteger)lvl
{
    NSDictionary *parentDictionary = parentIndex == -1?nil:[_expandedItemsIndexes objectAtIndex:parentIndex];
    NSNumber *nbrNumber = [NSNumber numberWithInteger:nbr];
    NSNumber *lvlNumber = [NSNumber numberWithInteger:lvl];
    
    // LEARNED : in this method, if first Value is nil, whole dic is empty
    NSMutableDictionary *infoDicOfIndexRow = [NSMutableDictionary dictionaryWithObjectsAndKeys:nbrNumber, @"number", lvlNumber, @"level", parentDictionary, @"parentInfo", nil];
    
    [_expandedItemsIndexes insertObject:infoDicOfIndexRow atIndex:parentIndex + nbr + 1];
}

- (void)_removeFirstItemInfoForParentIndex:(NSUInteger)index
{
    [_expandedItemsIndexes removeObjectAtIndex:index+1];
}

/*
 _getParentTreePathForItemAtIndex return the treePath of a specified node.
 
 TODO : it is called everytime the dataSource methods is invoked,
        find a way to maintain the treePath info(need to be changable)
        or quickly caculate other treePaths after the first one was done.
 */
- (NSIndexPath *)_getParentTreePathForItemAtIndex:(NSUInteger)index
{
    if (![_expandedItemsIndexes objectAtIndex:index]) return nil;
    
    NSUInteger indexIdx = index;
    NSIndexPath *treePathInfo = nil;
    NSMutableArray *treePathInfoArray = [[NSMutableArray alloc] init];
    
    // Add the info this node holds and it's parents hold.
    [treePathInfoArray addObject:[_expandedItemsIndexes objectAtIndex:index]];
    
    while ([[_expandedItemsIndexes objectAtIndex:indexIdx] objectForKey:@"parentInfo"]) {
        NSDictionary *parentInfo = [[_expandedItemsIndexes objectAtIndex:indexIdx] objectForKey:@"parentInfo"];
        [treePathInfoArray addObject:parentInfo];
        
        indexIdx = [_expandedItemsIndexes indexOfObject:parentInfo];
    }
    
    NSUInteger treeLength = [treePathInfoArray count];
    NSUInteger indexes[treeLength];
    for (int i = 0; i < treeLength; i++) {
        NSDictionary *nodeInfo = [treePathInfoArray lastObject];
        NSUInteger numberOfSiblings = [[nodeInfo objectForKey:@"number"] integerValue];
        indexes[i] = numberOfSiblings;
        
        [treePathInfoArray removeLastObject];
    }
    treePathInfo = [NSIndexPath indexPathWithIndexes:indexes length:treeLength];
    
    [treePathInfoArray release];
    return treePathInfo;
}

- (BOOL)_cellIsVisibleAtIndexPath:(NSIndexPath *)indexPath
{
    __block BOOL isVisible = NO;
    [[self indexPathsForVisibleRows] enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
        NSIndexPath *tempIndexPath = (NSIndexPath *)obj;
        if (indexPath.row == tempIndexPath.row && indexPath.section == tempIndexPath.section) {
            isVisible = YES;
            *stop = YES;
        }
    }];
    
    return isVisible;
}

#pragma mark - UITableView Delegate Methods
//_expandedItemsIndexes' first pile of data is come from here.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_expandedItemsIndexes count] < indexPath.row + 1) //check if it is a grandgrandgrand... parent
        [self _insertItemInfoForParentIndex:-1 numberInSiblings:indexPath.row inLevel:0];
    
    NSIndexPath *treePath = [self _getParentTreePathForItemAtIndex:indexPath.row];
    if ([self.myDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:withDataTreePath:)]) {
        return [self.myDelegate tableView:self heightForRowAtIndexPath:indexPath withDataTreePath:treePath];
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.myDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.myDelegate tableView:self didSelectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.myDelegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
        [self.myDelegate tableView:self didDeselectRowAtIndexPath:indexPath];
    }
}

#pragma mark - UITableView DataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger baseRowsCount = -1;
    //NSDictionary *rowsChangeInfo = [_rowsChangeRecorder objectForKey:@"changer"];
    
    if (_numberOfRows == 0 && [self.myDataSource respondsToSelector:@selector(tableView:baseNumberOfRowsInSection:)]) {
        //make sure it's going to return the grandgrandgrand.. parents' number.
        baseRowsCount = [self.myDataSource tableView:self baseNumberOfRowsInSection:section];
        _numberOfRows = baseRowsCount;
    }
    
    return _numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *treePath = [self _getParentTreePathForItemAtIndex:indexPath.row];
    
    if (treePath && [self.myDataSource respondsToSelector:@selector(tableView:cellForRowAtIndexPath:withDataTreePath:)])
        return [self.myDataSource tableView:self cellForRowAtIndexPath:indexPath withDataTreePath:treePath];
    else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.myDataSource respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [self.myDataSource tableView:self heightForHeaderInSection:section];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([self.myDataSource respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [self.myDataSource tableView:self heightForFooterInSection:section];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ([self.myDataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
        return [self.myDataSource tableView:self titleForFooterInSection:section];
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.myDataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        return [self.myDataSource tableView:self titleForHeaderInSection:section];
    }
    return nil;
}

@end
