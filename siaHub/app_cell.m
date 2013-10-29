//
//  app_cell.m
//  siaHub
//
//  Created by Vincenzo on 23/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "app_cell.h"


@interface app_cell()

@property (nonatomic, strong,readwrite) UIImageView *imageView;

@end
@implementation app_cell

- (id)initWithFrame:(CGRect)frame
{
    
    
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.5f;
        
        
        CALayer * l = [self layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:10];
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.5f;
        // make sure we rasterize nicely for retina
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        
        
        CGRect imageFrame = CGRectMake(self.bounds.size.width * 0.10, self.bounds.size.height * 0.10, self.bounds.size.width * 0.80, self.bounds.size.height * 0.70);
        
        self.imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.clipsToBounds = YES;
        
        
        
        
        CGRect titleFrame = CGRectMake(self.bounds.origin.x, imageFrame.size.height *1.10 , self.bounds.size.width, self.bounds.size.height * 0.20);
        
        
        UILabel *text = [[UILabel alloc]initWithFrame:titleFrame];
        [text setText:@"Application"];
        
        [text setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:text];

    }
    
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
}

@end
