//
//  venduto_report_cell.m
//  siaHub
//
//  Created by Vincenzo on 28/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "venduto_report_cell.h"

@implementation venduto_report_cell
@synthesize key,valore;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"venduto_report_cell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        self = [topLevelObjects objectAtIndex:0];
        
        
        CALayer * l = [self layer];
        [l setMasksToBounds:YES];
       // [l setCornerRadius:10];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+(float)getRowHeight{
    return 30.0f;
}




@end
