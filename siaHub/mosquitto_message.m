//
//  mosquitto_message.m
//  siaHub
//
//  Created by Vincenzo on 25/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "mosquitto_message.h"

@implementation mosquitto_message
@synthesize mid, topic, payload, payloadlen, qos, retained;
@synthesize ID, sender, body, responseto, name, command,header,ondemandlist,notificationlist;
-(id)init
{
    self.mid = 0;
    self.topic = nil;
    self.payload = nil;
    self.payloadlen = 0;
    self.qos = 0;
    self.retained = FALSE;
    return self;
}



@end
