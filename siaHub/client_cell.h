//
//  client_cell.h
//  siaHub
//
//  Created by Vincenzo on 25/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol client_cell_protocol <NSObject>

-(void)checkBtnPressed:(NSIndexPath*)selfIndex;

@end

@interface client_cell : UITableViewCell




@property (assign,readonly) BOOL *rowSelected;
@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *detail;
@property (nonatomic, retain) IBOutlet UIButton *checkBtn;
@property (nonatomic, retain) NSIndexPath *index;
@property (nonatomic, retain) id<client_cell_protocol> delegate;




@property (assign,readwrite) BOOL *reloaded;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andReload:(BOOL)reload;
-(void)pressCell;


-(void)selectCell;
-(void)deSelectCell;

+(float)returnCellHeight;

@end
