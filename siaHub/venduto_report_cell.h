//
//  venduto_report_cell.h
//  siaHub
//
//  Created by Vincenzo on 28/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface venduto_report_cell : UITableViewCell



@property(nonatomic,retain) IBOutlet UILabel *key;
@property(nonatomic,retain) IBOutlet UILabel *valore;

+(float)getRowHeight;

@end
