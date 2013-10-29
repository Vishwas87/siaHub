//
//  apps_list.h
//  siaHub
//
//  Created by Vincenzo on 23/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "app_cell.h"
#import "appslist_source.h"
#import "client_list.h"
@interface apps_list : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,appsList_protocol>

@end
