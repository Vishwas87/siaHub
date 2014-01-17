//
//  MqttBroker.m
//  siaHub
//
//  Created by Vincenzo on 08/11/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "MqttBroker.h"
#import "Reachability.h"

@interface MqttBroker()


@property (nonatomic,retain,readwrite) NSMutableDictionary *topicsReuqested; //Dizionario dei topic richiesti (le key sono gli argomenti ed
//i value sono invece array di subscriber

@property (nonatomic,retain,readwrite) NSMutableArray *clients; //Array dei client


@property (nonatomic,retain, readwrite) MosquittoClient *mosquittoClient;

@property (assign,readwrite) int incrementalNumber;


@property (nonatomic,retain) NSString* status; //Indica la stato del client
@property (nonatomic,retain) NSOperationQueue *operation; //Coda per l'operazione di riconnessione
@property (nonatomic,retain) NSTimer *timerReconnect; //Timer di riconnessione



-(void) tryConnection;
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
        self.status = @"DISCONNECTED";
        self.incrementalNumber = 0;
        
        self.operation = [[NSOperationQueue alloc]init];
        
        
        
        
        NSString *unique = [MqttBroker getUniqueClientId];
        self.topicsReuqested = [[NSMutableDictionary alloc]init];
        self.clients = [[NSMutableArray alloc]init];
        if(!self.mosquittoClient) self.mosquittoClient  = [[MosquittoClient alloc]initWithClientId:unique];
        
       // [self.mosquittoClient setHost: @"85.39.190.50"];
        [self.mosquittoClient setHost: @"192.168.1.109"];
        
        [self.mosquittoClient setDelegate:self];
        
        [self.mosquittoClient setUsername:@"fabio2"];
        [self.mosquittoClient setPassword:@"fabio"];
        self.status = @"CONNECTING";
        

        self.timerReconnect = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tryConnection) userInfo:NULL repeats:YES];

        //[self tryConnection];
        
    }
    
    return self;
}
-(NSDictionary*)getStatus{
    
    
    
    return [NSDictionary dictionaryWithObjectsAndKeys:self.status,@"STATUS", nil];
}

-(void) tryConnection
{
    //Esegue la connessione al client in maniera asincrona (consentendo di non bloccare i client)
    __weak MqttBroker *weakSelf = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // then set them via the main queue if the cell is still visible.
            weakSelf.status = @"CONNECTING";
            
            [weakSelf.clients enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                if([obj respondsToSelector:@selector(changedStatus:)]){
                    [obj changedStatus:[NSDictionary dictionaryWithObjectsAndKeys:weakSelf.status,@"STATUS", nil]];
                }
                
                
            }];
            [weakSelf.mosquittoClient setHost: @"192.168.1.109"];
            
            [weakSelf.mosquittoClient setDelegate:self];
            
            [weakSelf.mosquittoClient setUsername:@"fabio2"];
            [weakSelf.mosquittoClient setPassword:@"fabio"];
            [weakSelf.mosquittoClient connect];
        });
    }];
    
    operation.queuePriority = NSOperationQueuePriorityHigh ;
    
    [self.operation addOperation:operation];


}


#pragma mark --- Mqtt client Methods
-(void)unsubscribeClient:(id)aClient fromTopic:(NSString*)aTopic {
    
    
    
    [self.clients removeObject:aClient];
    
    if([self.topicsReuqested objectForKey:aTopic] != NULL &&
       [[self.topicsReuqested objectForKey:aTopic] containsObject:aClient]
       ){
        
        [[self.topicsReuqested objectForKey:aTopic] removeObject:aClient];
        
        
        if([[self.topicsReuqested objectForKey:aTopic] count] == 0)
        {
            [self.topicsReuqested removeObjectForKey:aTopic]; //Se non ci sono più subscriber-> elimina la voce del registro
        }
        
    }
    
    //TODO AGGIUNGERE EVENTUALI CONTROLLI
    [self.mosquittoClient unsubscribe:aTopic];
    
}


-(NSDictionary*)subscribeClient:(id)aClient toTopic:(NSString*)aTopic{
    
    
    if(![self.clients containsObject:aClient]){
        [self.clients addObject:aClient];
    }
    
    if([self.topicsReuqested objectForKey:aTopic]== NULL){
        //Se nessuno si è mai sottoscritto a questo topic-> crea key ed array di subscribers
        [self.topicsReuqested setObject:[[NSMutableArray alloc]init] forKey:aTopic];
    }
    
    [[self.topicsReuqested objectForKey:aTopic] addObject:aClient]; //Aggiungi il subscriber
    
    
    int ris = [self.mosquittoClient subscribe:aTopic];
    NSMutableDictionary *result;
    result = [self generateStatusRequest:ris];
    
    
    return result;
}

- (NSMutableDictionary *)generateStatusRequest:(int)ris
{
    NSMutableDictionary * result = [[NSMutableDictionary alloc]init];
    /*   MOSQ_ERR_SUCCESS = 0,
     MOSQ_ERR_NOMEM = 1,
     MOSQ_ERR_PROTOCOL = 2,
     MOSQ_ERR_INVAL = 3,
     MOSQ_ERR_NO_CONN = 4,
     MOSQ_ERR_CONN_REFUSED = 5,
     MOSQ_ERR_NOT_FOUND = 6,
     MOSQ_ERR_CONN_LOST = 7,
     MOSQ_ERR_TLS = 8,
     MOSQ_ERR_PAYLOAD_SIZE = 9,
     MOSQ_ERR_NOT_SUPPORTED = 10,
     MOSQ_ERR_AUTH = 11,
     MOSQ_ERR_ACL_DENIED = 12,
     MOSQ_ERR_UNKNOWN = 13,
     MOSQ_ERR_ERRNO = 14*/
    
    switch (ris) {
        case 0:
        {
            //Success
            
            [result setObject:@"SUCCESS" forKey:@"STATUS"];
            
        }
            break;
        case 4:
        {
            //NO CONNECTION
            
            [result setObject:@"NO CONNECTION" forKey:@"STATUS"];
            
        }
            break;
        default:
        {
            //NO CONNECTION
            
            [result setObject:@"GENERIC ERROR" forKey:@"STATUS"];
            
        }
            break;
            
    }
    [result setObject:[NSString stringWithFormat:@"%d",ris] forKey:@"CODE"];
    return result;
}

-(NSDictionary*)publishMessage:(NSString*)aMessage
              onTopic:(NSString*)topic
              withQos:(int)Qos
             retained:(BOOL)retain
         andPublisher:(id)publisher
{
 
    int ris = [self.mosquittoClient publishString:aMessage toTopic:topic withQos:Qos retain:retain];
    NSMutableDictionary *result;
    result = [self generateStatusRequest:ris];
    return result;
    
}


- (void) didConnect: (NSUInteger)code
{
    if([self.timerReconnect isValid])
        [self.timerReconnect invalidate];
    
    self.status = @"CONNECTED";
    
    
    [self.clients enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if([obj respondsToSelector:@selector(changedStatus:)]){
            [obj changedStatus:[NSDictionary dictionaryWithObjectsAndKeys:self.status,@"STATUS", nil]];
        }
        
    }];
    
    
    
    //In fase di collegamento -> se c'è qualche argomento --> sottoscriviti (UTILE IN CASO DI DISCONNESSIONE->RICONNESSIONE)
    [[self.topicsReuqested allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self subscribeClient:self toTopic:obj];
    }];
    
    
    
}
- (void) didDisconnect
{
    //Il broker si è disconnesso -> avviso tutti client che sono ancora attivi
    self.status = @"DISCONNECTED";
    
    [self.clients enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if(obj != NULL && [obj respondsToSelector:@selector(changedStatus:)]){
            //Avviso che lo stato è DISCONNESSO
            [obj changedStatus:[NSDictionary dictionaryWithObjectsAndKeys:self.status,@"STATUS", nil]];
        }
        
    }];
    self.timerReconnect = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tryConnection) userInfo:NULL repeats:YES];
    //Provo a ricollegarmi
       // [uniqueInstance performSelector:@selector(tryConnection) withObject:NULL afterDelay:1];
    
/*    NSInvocationOperation *op = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(tryConnection) object:NULL];
    [self.operation addOperation:op];*/
    
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
