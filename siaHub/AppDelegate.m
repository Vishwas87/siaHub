//
//  AppDelegate.m
//  siaHub
//
//  Created by Vincenzo on 22/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "AppDelegate.h"
#import <AdSupport/ASIdentifierManager.h>

@interface AppDelegate()

@property (assign,readwrite) int incrementalNumber;
@property (assign,readwrite) NSMutableDictionary *topicsReuqested; //Dizionario dei topic richiesti (le key sono gli argomenti ed
//i value sono invece array di subscriber


@property (nonatomic,retain, readwrite) MosquittoClient *mosquittoClient;


@end

@implementation AppDelegate
@synthesize mosquittoClient,navigation,params;



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
    

    if([self.topicsReuqested objectForKey:topic]!= NULL
       &&
       [[self.topicsReuqested objectForKey:topic] containsObject:publisher]
       )
    {
        [self.mosquittoClient publishString:aMessage toTopic:topic withQos:Qos retain:retain];
    }
}


- (void) didConnect: (NSUInteger)code
{
    
}
- (void) didDisconnect
{
    
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
            
            
            if([obj conformsToProtocol:@protocol(AppDelegate_protocol)] && [obj respondsToSelector:@selector(receivedAMessage:withStatus:)]){
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

-(void)resetDelegateMosquitto{

    [mosquittoClient setDelegate:self];
    
}


-(int)getIncrementalInt
{
    
    //Utilizzato per l'id dei messaggi 
    return self.incrementalNumber++;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.incrementalNumber = 0;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"loginBundle" withExtension:@"bundle"]];
    login_view *controller = [[login_view alloc]initWithNibName:@"login_view" bundle:bundle andSpotsUrl:@"http://localhost:8888/" andLoginUrl:@"http://192.168.3.109/desktop.sianet.it/index.php/wrlogin"];
    [controller setDelegate:self];
    
    
    
    self.params = [[NSMutableDictionary alloc]init];
    [self.params setObject:@"C43" forKey:@"customer_code"];
    [self.params setObject:@"vincenzo" forKey:@"username"];
    [self.params setObject:@"vincenzo" forKey:@"password"];
    
    
    if(self.navigation == NULL){
        //Se ancora non è stata avviata l'app
        apps_list *cn = [[apps_list alloc]initWithNibName:@"apps_list" bundle:nil];
        self.navigation = [[UINavigationController alloc]initWithRootViewController:cn];
    }
    
    [self connectMosquittoClient];
    
    self.window.rootViewController = self.navigation;
    //self.window.rootViewController = controller;
    controller = NULL;
    
    [self.window makeKeyAndVisible];
    return YES;
}



-(NSString*)getUniqueClientId
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



-(void)connectMosquittoClient
{
    
    if(!mosquittoClient) mosquittoClient  = [[MosquittoClient alloc]initWithClientId:[self getUniqueClientId]];
    
    //[mosquittoClient setHost: @"85.39.190.50"];
    [mosquittoClient setHost: @"192.168.1.106"];
    [mosquittoClient setUsername:[self.params objectForKey:@"username"]];
    [mosquittoClient setPassword:[self.params objectForKey:@"password"]];
   // [mosquittoClient connect];
}



-(void)loginSuccess:(NSMutableDictionary*)response //Method executed after a succeful login
{
    
    
    if([[response objectForKey:@"RETURNCODE"] intValue] == 0){
        
        NSArray* retval = [response objectForKey:@"RETURNVALUES"];
        if([retval count]>0){
            
            NSMutableDictionary *parameters = [retval objectAtIndex:0];
            if([[parameters allKeys]containsObject:@"customer_code"] &&
               [[parameters allKeys]containsObject:@"username"] &&
               [[parameters allKeys]containsObject:@"password"]
               ){
                self.params = [[NSMutableDictionary alloc]init];
                [self.params setObject:[parameters objectForKey:@"customer_code"] forKey:@"customer_code"];
                [self.params setObject:[parameters objectForKey:@"username"] forKey:@"username"];
                [self.params setObject:[parameters objectForKey:@"password"] forKey:@"password"];
                parameters = NULL;
                response = NULL;
                retval = NULL;
                
                if(self.navigation == NULL){
                    //Se ancora non è stata avviata l'app
                    apps_list *cn = [[apps_list alloc]initWithNibName:@"apps_list" bundle:nil];
                    self.navigation = [[UINavigationController alloc]initWithRootViewController:cn];
                }
                
                [self connectMosquittoClient];
                [self.window.rootViewController presentViewController:self.navigation animated:NO completion:^{
                    
                }];
                
                
            }
            else{
                UIAlertView * errorCustomer = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"NO PARAMETERS", NULL) message:NSLocalizedString(@"NO PARAMETERS MESSAGE", NULL) delegate:self cancelButtonTitle:NULL otherButtonTitles:NULL, nil];
                [errorCustomer show];
            }
            
        }
           
        
        

    }
    
    

    
}
-(void)loginError:(id)errorStatus //Method executed after a failed login
{
    
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}





#pragma mark COMMON METHOD

-(NSString*)getColumnValueForConfiguration:(NSDictionary*)configuration andString:(NSString*)value{
    const int precisionDecimal = 2;
    
    if([configuration objectForKey:@"ColumnSize"] != NULL &&
       [configuration objectForKey:@"DataType"] != NULL &&
       [configuration objectForKey:@"NumericPrecision"] != NULL &&
       [value length]>0
       )
    {
        
        if([[configuration objectForKey:@"DataType"] isEqualToString:@"System.Int32"]){
            //Intero
            
            if([value intValue] == 0 && ![value isEqualToString:@"0"]) //Stringa non corretta
                    return @"Err";
            else return value;
        }
        if([[configuration objectForKey:@"DataType"] isEqualToString:@"System.Decimal"]){
            //Float
            
            if([value floatValue] == 0.0 && ![value isEqualToString:@"0.0"]) //Stringa non corretta
                return @"Err";
            else {
                //Formattazione in funzione del numero di cifre
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                [formatter setGroupingSeparator:@""];
                [formatter setDecimalSeparator:@"."];
                
                
                [formatter setMaximumFractionDigits:precisionDecimal];
                [formatter setMinimumFractionDigits:precisionDecimal];
                NSNumber *numberFromString = [formatter numberFromString:value];
                [formatter setGroupingSeparator:@"."];
                [formatter setDecimalSeparator:@","];
                [formatter setGroupingSize:3];
                
                return [formatter stringFromNumber:numberFromString];
            }
        }
        return value;
        
    }
    
    
    
    return @"Err";
}


@end
