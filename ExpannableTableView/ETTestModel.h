//
//  ETTestModel.h
//  ExpannableTableView
//
//  Created by Zhang Studyro on 12-11-12.
//  Copyright (c) 2012年 Studyro Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETTestModel : NSObject
@property (nonatomic, retain) NSMutableArray *children;
@property (nonatomic, assign) NSUInteger level;
@property (nonatomic, retain) NSString *content;
@end
