//
//  client_list.h
//  siaHub
//
//  Created by Vincenzo on 24/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "client_cell.h"
#import "venduto_report.h"
#import "MqttBroker.h"



@interface client_list : UIViewController<broker_protocol ,UITableViewDataSource,UITableViewDelegate,client_cell_protocol>
{
    MosquittoClient *msq_tto;
    NSTimer *timerRespond;
}

@end
