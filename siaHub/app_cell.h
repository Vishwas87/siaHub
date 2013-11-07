//
//  app_cell.h
//  siaHub
//
//  Created by Vincenzo on 23/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface app_cell : UICollectionViewCell

@property (nonatomic, strong,readonly) UIImageView *imageView;
@property (nonatomic, strong,readonly) UIActivityIndicatorView *activity;
@property (nonatomic, strong,readonly) UILabel *text;
@end
