//
//  client_cell.m
//  siaHub
//
//  Created by Vincenzo on 25/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "client_cell.h"

@interface client_cell()

@property (assign,readwrite) BOOL *rowSelected;


@end

@implementation client_cell
@synthesize reloaded,index,delegate,title,detail;



+(float)returnCellHeight
{
    return 85.0f;
}




- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andReload:(BOOL)reload {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"client_cell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        self = [topLevelObjects objectAtIndex:0];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        // Initialization code
      
        
        [self.checkBtn setBackgroundImage:[UIImage imageNamed:@"uncheck.png"] forState:UIControlStateNormal];

            
        self.checkBtn.userInteractionEnabled = YES;
        [self.checkBtn addTarget:self action:@selector(pressCell) forControlEvents:UIControlEventTouchUpInside];
       
    }
    return self;
}

-(void)pressCell
{
    

    if(self.delegate && [self.delegate respondsToSelector:@selector(checkBtnPressed:)]){
        
        [self.delegate checkBtnPressed:self.index];
    }

    
}

-(void)selectCell{
    [self.checkBtn setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
}
-(void)deSelectCell{
    [self.checkBtn setBackgroundImage:[UIImage imageNamed:@"uncheck.png"] forState:UIControlStateNormal];
}

@end
