//
//  client_list.h
//  siaHub
//
//  Created by Vincenzo on 24/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MosquittoClient.h"
#import "client_cell.h"
#import "venduto_report.h"

@interface client_list : UIViewController<UITableViewDataSource,UITableViewDelegate,MosquittoClientDelegate,client_cell_protocol>
{
    MosquittoClient *msq_tto;
     NSTimer *timerRespond;
}

@end
