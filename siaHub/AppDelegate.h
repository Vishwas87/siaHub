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

@class MosquittoClient;

@interface AppDelegate : UIResponder <UIApplicationDelegate,login_view_protocol,MosquittoClientDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain, readonly) MosquittoClient *mosquittoClient;
@property (strong,nonatomic) UINavigationController *navigation;
@property (strong,nonatomic) NSMutableDictionary *params; //Conserva nome utente password customer code

-(NSString*)getUniqueClientId;
-(int)getIncrementalInt; //Metodo utilizzato per ottenere un autoincremental number
-(void)resetDelegateMosquitto;
@end
