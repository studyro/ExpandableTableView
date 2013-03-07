//
//  ETTestModel.m
//  ExpannableTableView
//
//  Created by Zhang Studyro on 12-11-12.
//  Copyright (c) 2012年 Studyro Studio. All rights reserved.
//

#import "ETTestModel.h"

@implementation ETTestModel
- (void)dealloc
{
    [_children release];
    [_content release];
    
    [super dealloc];
}
@end
