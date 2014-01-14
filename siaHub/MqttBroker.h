//
//  MqttBroker.h
//  siaHub
//
//  Created by Vincenzo on 08/11/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MosquittoClient.h>
#import <AdSupport/ASIdentifierManager.h>
#import "mosquitto_message.h"



@protocol broker_protocol <NSObject>

-(void)receivedAMessage:(mosquitto_message*)aMessage withStatus:(NSDictionary*)aConfig;
-(void)changedStatus:(NSDictionary*)statusClient; //Metodo richiamato quando c'è una variazione dello stato nella connessione


@end

@interface MqttBroker : NSObject <MosquittoClientDelegate>



-(void)unsubscribeClient:(id)aClient fromTopic:(NSString*)aTopic;
-(NSDictionary*)subscribeClient:(id)aClient toTopic:(NSString*)aTopic;
-(NSDictionary*)publishMessage:(NSString*)aMessage onTopic:(NSString*)topic withQos:(int)Qos retained:(BOOL)retain andPublisher:(id)publisher;
-(int)getIncrementalInt; //Metodo utilizzato per ottenere un autoincremental number
-(NSDictionary*)getStatus;


+(MqttBroker*)instance;
+(NSString*)getUniqueClientId;

@end
