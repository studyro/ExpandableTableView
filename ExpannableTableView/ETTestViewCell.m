//
//  ETTestViewCell.m
//  ExpannableTableView
//
//  Created by Zhang Studyro on 12-10-31.
//  Copyright (c) 2012年 Studyro Studio. All rights reserved.
//

#import "ETTestViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ETTestViewCell

@synthesize content = _content;
@synthesize level = _level;

- (void)dealloc
{
    [_content release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.layer.anchorPoint = self.center;
        UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer    alloc] initWithTarget:self action:@selector(longPressed:)];
        [self addGestureRecognizer:longRecognizer];
        [longRecognizer release];
    }
    return self;
}

- (void)longPressed:(id)sender
{
    UILongPressGestureRecognizer *recognizer = (UILongPressGestureRecognizer *)sender;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.01);
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
        {
            self.layer.transform = CATransform3DIdentity;
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            self.layer.transform = CATransform3DIdentity;
            break;
        }
            
        default:
            break;
    }
}

- (void)setContent:(NSString *)content
{
    [_content release];
    _content = [content retain];
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
    CGFloat multi = self.level / 5.0;
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:(1.0-multi) green:(1.0-multi) blue:(1.0-multi)*0.95 alpha:1.0].CGColor);
    CGContextFillRect(context, rect);
    
    CGMutablePathRef path = CGPathCreateMutable();
    //CGPathAddRect(path, NULL, CGRectMake(-8.0f, -2.0f, 330.0f, 48.0f));
    //CGPathAddRect(path, NULL, CGRectMake(-5.0f, 0.0f, 324.0f, 52.0f));
    CGPathAddRect(path, NULL, CGRectMake(0.0, -1.0, 320.0, 1.0));
    // Saving current graphics context state
    CGContextSaveGState(context);
    
    // Configuring shadow
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 2.0f), 6.0f,
                                [[UIColor whiteColor] CGColor]);
    
    // Adding our path
    CGContextAddPath(context, path);
    
    // Configure hollow rectangle fill color
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    
    // Fill rectangle and keep hollow part transparent
    CGContextEOFillPath(context);
    
    // Restore graphics context
    CGContextRestoreGState(context);
     
    
    UIColor *color = multi>=0.4?[UIColor colorWithRed:1.0 green:1.0 blue:0.92 alpha:1.0]:[UIColor blackColor];
    [color set];
    [_content drawAtPoint:CGPointMake(10.0, 10.0) withFont:[UIFont systemFontOfSize:16]];
}

@end
