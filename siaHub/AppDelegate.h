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

@protocol AppDelegate_protocol <NSObject>

-(void)receivedAMessage:(mosquitto_message*)aMessage withStatus:(NSDictionary*)aConfig;


@end


@interface AppDelegate : UIResponder <UIApplicationDelegate,login_view_protocol,MosquittoClientDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) UINavigationController *navigation;
@property (strong,nonatomic) NSMutableDictionary *params; //Conserva nome utente password customer code

-(NSString*)getUniqueClientId;
-(int)getIncrementalInt; //Metodo utilizzato per ottenere un autoincremental number
-(void)resetDelegateMosquitto;


-(NSString*)getColumnValueForConfiguration:(NSDictionary*)configuration andString:(NSString*)value;


-(int)unsubscribeClient:(id)aClient fromTopic:(NSString*)aTopic;
-(int)subscribeClient:(id)aClient toTopic:(NSString*)aTopic;
-(void)publishMessage:(NSString*)aMessage onTopic:(NSString*)topic withQos:(int)Qos retained:(BOOL)retain andPublisher:(id)publisher;



@end
