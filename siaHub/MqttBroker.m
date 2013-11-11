//
//  MqttBroker.m
//  siaHub
//
//  Created by Vincenzo on 08/11/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "MqttBroker.h"


@interface MqttBroker()


@property (nonatomic,retain,readwrite) NSMutableDictionary *topicsReuqested; //Dizionario dei topic richiesti (le key sono gli argomenti ed
//i value sono invece array di subscriber


@property (nonatomic,retain, readwrite) MosquittoClient *mosquittoClient;

@property (assign,readwrite) int incrementalNumber;


@end

@implementation MqttBroker
static MqttBroker *uniqueInstance = NULL;



+(NSString*)getUniqueClientId
{
    // Do any additional setup after loading the view from its nib.
    if (NSClassFromString(@"ASIdentifierManager")) {
        return   [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    else
    {
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
}


+(MqttBroker*)instance
{
    
    
    if(!uniqueInstance){
       uniqueInstance = [[super allocWithZone:NULL] init];
    }
    
    return uniqueInstance;
}




-(int)getIncrementalInt
{
    
    //Utilizzato per l'id dei messaggi
    return self.incrementalNumber++;
}


-(id)init{
    
    self = [super init];
    
    
    if(self){
        self.incrementalNumber = 0;
        NSString *unique = [MqttBroker getUniqueClientId];
        self.topicsReuqested = [[NSMutableDictionary alloc]init];
        if(!self.mosquittoClient) self.mosquittoClient  = [[MosquittoClient alloc]initWithClientId:unique];
        
        //[mosquittoClient setHost: @"85.39.190.50"];
        [self.mosquittoClient setHost: @"192.168.1.95"];
        
        [self.mosquittoClient setDelegate:self];
        
        [self.mosquittoClient setUsername:@"vincenzo"];
        [self.mosquittoClient setPassword:@"vincenzo"];
        [self.mosquittoClient connect];
        
        
    }
    
    return self;
}


#pragma mark --- Mqtt client Methods
-(int)unsubscribeClient:(id)aClient fromTopic:(NSString*)aTopic {
    
    
    
    if([self.topicsReuqested objectForKey:aTopic] != NULL &&
       [[self.topicsReuqested objectForKey:aTopic] containsObject:aClient]
       ){
        
        [[self.topicsReuqested objectForKey:aTopic] removeObject:aClient];
        
        
        if([[self.topicsReuqested objectForKey:aTopic] count] == 0)
        {
            [self.topicsReuqested removeObjectForKey:aTopic]; //Se non ci sono più subscriber-> elimina la voce del registro
        }
        
    }
    return 0;
}


-(int)subscribeClient:(id)aClient toTopic:(NSString*)aTopic{
    
    
    if([self.topicsReuqested objectForKey:aTopic]== NULL){
        //Se nessuno si è mai sottoscritto a questo topic-> crea key ed array di subscribers
        [self.topicsReuqested setObject:[[NSMutableArray alloc]init] forKey:aTopic];
    }
    
    [[self.topicsReuqested objectForKey:aTopic] addObject:aClient]; //Aggiungi il subscriber

    [self.mosquittoClient subscribe:aTopic];
    
    
    return 0;
}

-(void)publishMessage:(NSString*)aMessage
              onTopic:(NSString*)topic
              withQos:(int)Qos
             retained:(BOOL)retain
         andPublisher:(id)publisher
{
    

    
    [self.mosquittoClient publishString:aMessage toTopic:topic withQos:Qos retain:retain];
    
    
    if([self.topicsReuqested objectForKey:topic]!= NULL
       &&
       [[self.topicsReuqested objectForKey:topic] containsObject:publisher]
       )
    {
        
    }
}


- (void) didConnect: (NSUInteger)code
{
    
}
- (void) didDisconnect
{
    [self.mosquittoClient connect];
}
- (void) didPublish: (NSUInteger)messageId
{
    
}

- (void) didReceiveMessage: (mosquitto_message*)mosq_msg
{
    
    if([self.topicsReuqested objectForKey:mosq_msg.topic] != NULL
       //Se non ci sono subscriber il value per il topic è null
       ){
        
        [[self.topicsReuqested objectForKey:mosq_msg.topic] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            
            if([obj respondsToSelector:@selector(receivedAMessage:withStatus:)]){
                [obj receivedAMessage:mosq_msg withStatus:NULL];
            }
            
        }];
        
    }
    
}
- (void) didSubscribe: (NSUInteger)messageId grantedQos:(NSArray*)qos
{
    
}
- (void) didUnsubscribe: (NSUInteger)messageId{
    
}




@end
