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

@end

@implementation AppDelegate
@synthesize mosquittoClient,navigation,params;


- (void) didConnect: (NSUInteger)code{
    
}
- (void) didDisconnect{
    
}
- (void) didPublish: (NSUInteger)messageId{
    
}

- (void) didReceiveMessage: (mosquitto_message*)mosq_msg{
    
}
- (void) didSubscribe: (NSUInteger)messageId grantedQos:(NSArray*)qos{
    
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
    
    
    
    self.window.rootViewController = controller;
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
    
    NSLog(@"response %@",response);
    
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
                //[errorCustomer show];
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

@end
