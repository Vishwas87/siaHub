//
//  venduto_report.h
//  siaHub
//
//  Created by Vincenzo on 25/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MosquittoClient.h"
@interface venduto_report : UIViewController<UITableViewDataSource,UITableViewDelegate,MosquittoClientDelegate>



@property (nonatomic,retain) NSMutableDictionary *source;

@end
