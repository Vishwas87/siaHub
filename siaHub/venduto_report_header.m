//
//  venduto_report_header.m
//  siaHub
//
//  Created by Vincenzo on 04/11/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "venduto_report_header.h"

@implementation venduto_report_header

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"venduto_report_header" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        self = [topLevelObjects objectAtIndex:0];
        

    }
    return self;
}


-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
        self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"venduto_report_header" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        self = [topLevelObjects objectAtIndex:0];
        
        
    }
    
    self.headerStatus.translatesAutoresizingMaskIntoConstraints = false;
    self.headerTitle.translatesAutoresizingMaskIntoConstraints = false;
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
