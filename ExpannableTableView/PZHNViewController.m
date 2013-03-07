//
//  PZHNViewController.m
//  ExpannableTableView
//
//  Created by Zhang Studyro on 12-10-30.
//  Copyright (c) 2012年 Studyro Studio. All rights reserved.
//

#import "PZHNViewController.h"
#import "ETTestViewCell.h"
#import "ETShadowView.h"
#import <QuartzCore/QuartzCore.h>

@interface PZHNViewController ()
@property (nonatomic, retain) NSMutableArray *arr;
@end

@implementation PZHNViewController
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}
*/
- (id)init
{
    if (self = [super init]) {
        PZHNExpandableTableView *exTableView = [[PZHNExpandableTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        exTableView.myDataSource = self;
        exTableView.myDelegate = self;
        [self.view addSubview:exTableView];
        _arr = [[NSMutableArray alloc] init];
        for (int i=0; i<15; i++) {
            ETTestModel *model = [[ETTestModel alloc] init];
            model.level = 0;
            model.content = [NSString stringWithFormat:@"%d", i];
            if (i == 3) {
                model.children = [NSMutableArray array];
                for (int j = 0; j < 10; j++) {
                    ETTestModel *levelOneModel = [[ETTestModel alloc] init];
                    levelOneModel.level = 1;
                    levelOneModel.content = [NSString stringWithFormat:@"%d-%d", i, j];
                    if (j == 1) {
                        levelOneModel.children = [NSMutableArray array];
                        for (int k = 0; k < 4; k++) {
                            ETTestModel *levelTwoModel = [[ETTestModel alloc] init];
                            levelTwoModel.level = 2;
                            levelTwoModel.content = [NSString stringWithFormat:@"%d-%d-%d", i, j, k];
                            
                            if (k == 2) {
                                levelTwoModel.children = [NSMutableArray array];
                                for (int l = 0; l < 3; l++) {
                                    ETTestModel *levelThreeModel = [[ETTestModel alloc] init];
                                    levelThreeModel.level = 3;
                                    levelThreeModel.content = [NSString stringWithFormat:@"%d-%d-%d-%d", i,j,k,l];
                                    
                                    if (l == 1) {
                                        levelThreeModel.children = [NSMutableArray array];
                                        for (int m = 0; m < 5; m++) {
                                            ETTestModel *levelFourModel = [[ETTestModel alloc] init];
                                            levelFourModel.level = 4;
                                            levelFourModel.content = [NSString stringWithFormat:@"%d-%d-%d-%d-%d", i,j,k,l,m];
                                            
                                            [levelThreeModel.children addObject:levelFourModel];
                                            [levelFourModel release];
                                        }
                                    }
                                    
                                    [levelTwoModel.children addObject:levelThreeModel];
                                    [levelThreeModel release];
                                }
                            }
                            
                            [levelOneModel.children addObject:levelTwoModel];
                            [levelTwoModel release];
                        }
                    }
                    
                    [model.children addObject:levelOneModel];
                    [levelOneModel release];
                }
            }
            [self.arr addObject:model];
            [model release];
        }
        
    }
    
    return self;
}

- (ETTestModel *)_objectOfTreePath:(NSIndexPath *)treePath
{
    NSUInteger length = [treePath length];
    NSUInteger nodes[length];
    [treePath getIndexes:nodes];
    
    ETTestModel *obj = nil;
    for (int i = 0; i < length; i++) {
        if (i==0)
            obj = [self.arr objectAtIndex:nodes[i]];
        else
            obj = [obj.children objectAtIndex:nodes[i]];
    }
    
    return obj;
}

#pragma mark - delegate
static int expanded = NO;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PZHNExpandableTableView *exTableView = (PZHNExpandableTableView *)tableView;
    [exTableView expandOrCollapseAtIndexPath:indexPath animated:YES];
    
    NSIndexPath *fatherIndex = [NSIndexPath indexPathForRow:3 inSection:0];
    if (indexPath.row > 20) {
        [exTableView expandOrCollapseAtIndexPath:fatherIndex animated:YES];
    }
    //cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.1, 1.1, 1.1);
    //cell.layer.masksToBounds = NO;
    //cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
}

#pragma mark - datasource
- (CGFloat)tableView:(PZHNExpandableTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withDataTreePath:(NSIndexPath *)treePath
{
    return 44;
}

- (NSUInteger)tableView:(PZHNExpandableTableView *)tableView numberOfChildrenRowsForTreePath:(NSIndexPath *)treePath
{
    ETTestModel *model = [self _objectOfTreePath:treePath];
    return [model.children count];
}

- (NSInteger)tableView:(PZHNExpandableTableView *)tableView baseNumberOfRowsInSection:(NSInteger)section
{
    return [self.arr count];
}

- (UITableViewCell *)tableView:(PZHNExpandableTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withDataTreePath:(NSIndexPath *)treePath
{
    static NSString *cellIdentifier = @"Test Cell";
    ETTestViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[ETTestViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    ETTestModel *model = [self _objectOfTreePath:treePath];
    //cell.textLabel.text = model.content;
    cell.content = model.content;
    cell.level = model.level;
    
    return cell;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //ETShadowView *view = [[ETShadowView alloc] initWithFrame:CGRectMake(100.0, 100.0, 50.0, 50.0)];
    //[self.view addSubview:view];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
