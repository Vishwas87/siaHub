//
//  AppDelegate.m
//  siaHub
//
//  Created by Vincenzo on 22/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
@class  MqttBroker;
@interface AppDelegate()

@property (assign,readwrite) int incrementalNumber;
@property (nonatomic,readwrite) NSMutableDictionary *topicsReuqested; //Dizionario dei topic richiesti (le key sono gli argomenti ed
//i value sono invece array di subscriber


@property (nonatomic,retain, readwrite) MosquittoClient *mosquittoClient;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) MqttBroker *broker;

@end

@implementation AppDelegate
@synthesize mosquittoClient,navigation,params,addresses;
@synthesize from,to;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.incrementalNumber = 0;

    
    
    @try {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Address" ofType:@"plist"];
        self.addresses = [[NSMutableDictionary alloc]initWithContentsOfFile:path];
        NSString *loginAddress = [self.addresses  objectForKey:@"login"];
        NSString *spotAddress =[self.addresses  objectForKey:@"spot"];
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
 
        self.window.backgroundColor = [UIColor whiteColor];
        
        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"loginBundle" withExtension:@"bundle"]];
        login_view *controller = [[login_view alloc]initWithNibName:@"login_view" bundle:bundle andSpotsUrl:spotAddress andLoginUrl:loginAddress];
        [controller setDelegate:self];
        
        
        self.window.rootViewController = controller;
        
        [self.window makeKeyAndVisible];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Errore");
        //TODO Gestire generico errore
    }
    @finally {
        
    }
    
    
    
    return YES;
}



- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    
    
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    switch (netStatus) {
        case NotReachable:
        {
            [self.broker didDisconnect];
        }
            break;
        case ReachableViaWWAN:
        case 	ReachableViaWiFi:
        {
            [self.broker performSelector:@selector(tryConnection) withObject:NULL afterDelay:1];
            
        }
        default:
            break;
    }
    
}



-(void)loginSuccess:(NSMutableDictionary*)response
//Method executed after a succeful login
{
    
    @try {
        if([[response objectForKey:@"RETURNCODE"] intValue] == 0){
            NSArray* retval = [response objectForKey:@"RETURNVALUES"];
            if([retval count]>0){
                
                NSMutableDictionary *parameters = [retval objectAtIndex:0];
                if([[parameters allKeys]containsObject:@"azienda"] &&
                   [[parameters allKeys]containsObject:@"username"] &&
                   [[parameters allKeys]containsObject:@"password"]  &&
                   [[parameters allKeys] containsObject:@"authParams"] && //Ci sono i parametri di autenticazione al sistema
                   [[[parameters  objectForKey:@"authParams"] allKeys] containsObject:@"token"] //Esiste il token
                   
                   ){
                        //Salviamo i parametri ricevuti in una variabile che sarà accessibile da tutti i controller
                    
                        self.params = [[NSMutableDictionary alloc]init];
                    
                        [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        
                            //salviamo tutti i parametri ricevuti dal login
                            [self.params setObject:obj forKey:key];
                        
                        }];
                        if(self.navigation == NULL){
                                //Se ancora non è stata avviata l'app
                                apps_list *cn = [[apps_list alloc]initWithNibName:@"apps_list" bundle:nil];
                                self.navigation = [[UINavigationController alloc]initWithRootViewController:cn];
                            
                                self.broker = [MqttBroker instance];
                                self.internetReachability = [Reachability reachabilityForInternetConnection];
                                [self.internetReachability startNotifier];
                                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

                            
                            }
                        [self.window.rootViewController presentViewController:self.navigation animated:NO completion:^{}];
                    }
                else{
                    
                    //Non tutti i parametri sono stati passati
                    //Bisogna riavviare l'applicazione
                    UIAlertView * errorCustomer = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"NO PARAMETERS", NULL) message:NSLocalizedString(@"NO PARAMETERS MESSAGE", NULL) delegate:self cancelButtonTitle:NULL otherButtonTitles:NULL, nil];
                    [errorCustomer show];
                    
                }
            }
            else{
                
                
                //TODO GESTIRE MEGLIO L'errore ricevuto dal server CASE????
                //Bisogna riavviare l'applicazione
                UIAlertView * errorCustomer = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"NO SERVER RESONSE", NULL) message:NSLocalizedString(@"NO SERVER RESONSE MESSAGE", NULL) delegate:self cancelButtonTitle:NULL otherButtonTitles:NULL, nil];
                [errorCustomer show];
            
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Errore");
        //Gestire visualizzazione generico errore
        
    }
    @finally {
        
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
