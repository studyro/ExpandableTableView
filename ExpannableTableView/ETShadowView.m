//
//  ETShadowView.m
//  ExpannableTableView
//
//  Created by Zhang Studyro on 12-11-14.
//  Copyright (c) 2012年 Studyro Studio. All rights reserved.
//

#import "ETShadowView.h"

@implementation ETShadowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor greenColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Drawing code
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0.0f, 48.0f, 50.0f, 2.0f));
    //CGPathAddRect(path, NULL, CGRectMake(0.0f, 10.0f, 50.0f, 30.0f));
    //CGPathMoveToPoint(path, NULL, 0.0, 40.0);
    //CGPathAddLineToPoint(path, NULL, 50.0, 40.0);
    
    // Saving current graphics context state
    CGContextSaveGState(context);
    
    // Configuring shadow
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, -5.0f), 6.0f,
                                [[UIColor redColor] CGColor]);
    
    // Adding our path
    CGContextAddPath(context, path);
    
    // Configure hollow rectangle fill color
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    
    // Fill rectangle and keep hollow part transparent
    CGContextEOFillPath(context);
    
    // Restore graphics context
    CGContextRestoreGState(context);
}


@end
