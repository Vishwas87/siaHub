//
//  mosquitto_message.h
//  siaHub
//
//  Created by Vincenzo on 25/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface mosquitto_message : NSObject
{
    unsigned short mid;
    NSString *topic;
    NSString *payload;
    unsigned short payloadlen;
    unsigned short qos;
    BOOL retained;
}

//Informazioni per il client
@property (readwrite, assign) unsigned short mid;
@property (readwrite, retain) NSString *topic;
@property (readwrite, retain) NSString *payload;
@property (readwrite, assign) unsigned short payloadlen;
@property (readwrite, assign) unsigned short qos;
@property (readwrite, assign) BOOL retained;


//Struttura del messaggio

@property (nonatomic,retain, readwrite) NSString *ID;
@property (nonatomic,retain, readwrite) NSString *responseto;
@property (nonatomic,retain, readwrite) NSString *name;
@property (nonatomic,retain, readwrite) NSString *sender;
@property (nonatomic,retain, readwrite) NSDictionary *command;
@property (nonatomic,retain, readwrite) NSDictionary *header;
@property (nonatomic,retain, readwrite) NSDictionary *body;
@property (nonatomic,retain, readwrite) NSDictionary *ondemandlist;
@property (nonatomic,retain, readwrite) NSDictionary *notificationlist;











-(id)init;
@end
