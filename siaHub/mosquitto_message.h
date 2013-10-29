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

@property (readwrite, assign) NSString *ID;
@property (readwrite, assign) NSString *responseto;
@property (readwrite, assign) NSString *name;
@property (readwrite, assign) NSString *sender;
@property (readwrite, assign) NSDictionary *command;
@property (readwrite, assign) NSDictionary *header;
@property (readwrite, assign) NSDictionary *body;
@property (readwrite, assign) NSDictionary *ondemandlist;
@property (readwrite, assign) NSDictionary *notificationlist;











-(id)init;
@end
