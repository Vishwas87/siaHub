//
//  AppDelegate.h
//  siaHub
//
//  Created by Vincenzo on 22/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "login_view.h"
#import "apps_list.h"
#import "MqttBroker.h"
@class MosquittoClient;



@interface AppDelegate : UIResponder <UIApplicationDelegate,login_view_protocol>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) UINavigationController *navigation;
@property (strong,nonatomic) NSMutableDictionary *params; //Conserva nome utente password customer code
@property (nonatomic,retain) NSDate *from;
@property (nonatomic,retain) NSDate *to;

-(void)resetDelegateMosquitto;


-(NSString*)getColumnValueForConfiguration:(NSDictionary*)configuration andString:(NSString*)value;




@end
