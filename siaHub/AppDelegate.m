//
//  AppDelegate.m
//  siaHub
//
//  Created by Vincenzo on 22/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate()

@property (assign,readwrite) int incrementalNumber;
@property (nonatomic,readwrite) NSMutableDictionary *topicsReuqested; //Dizionario dei topic richiesti (le key sono gli argomenti ed
//i value sono invece array di subscriber


@property (nonatomic,retain, readwrite) MosquittoClient *mosquittoClient;


@end

@implementation AppDelegate
@synthesize mosquittoClient,navigation,params;
@synthesize from,to;





-(void)resetDelegateMosquitto{

  //  [mosquittoClient setDelegate:self];
    
}





- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.incrementalNumber = 0;
    
    
    
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"loginBundle" withExtension:@"bundle"]];
    login_view *controller = [[login_view alloc]initWithNibName:@"login_view" bundle:bundle andSpotsUrl:@"http://localhost:8888/" andLoginUrl:@"https://192.168.3.109/index.php/login"];
    [controller setDelegate:self];
    
    
    self.window.rootViewController = controller;
    
    /*
    
    
    self.params = [[NSMutableDictionary alloc]init];
    [self.params setObject:@"C43" forKey:@"customer_code"];
    [self.params setObject:@"vincenzo" forKey:@"username"];
    [self.params setObject:@"vincenzo" forKey:@"password"];
    
    
    if(self.navigation == NULL){
        //Se ancora non è stata avviata l'app
        apps_list *cn = [[apps_list alloc]initWithNibName:@"apps_list" bundle:nil];
        self.navigation = [[UINavigationController alloc]initWithRootViewController:cn];
    }

    
    self.window.rootViewController = self.navigation;
    controller = NULL;
    */
    [self.window makeKeyAndVisible];
    
    
    
    return YES;
}









-(void)loginSuccess:(NSMutableDictionary*)response //Method executed after a succeful login
{
    
    
    if([[response objectForKey:@"RETURNCODE"] intValue] == 0){
        
        NSArray* retval = [response objectForKey:@"RETURNVALUES"];
        if([retval count]>0){
            
            NSMutableDictionary *parameters = [retval objectAtIndex:0];
            if([[parameters allKeys]containsObject:@"azienda"] &&
               [[parameters allKeys]containsObject:@"username"] &&
               [[parameters allKeys]containsObject:@"password"]
               ){
                
                
                
                
                
                
                self.params = [[NSMutableDictionary alloc]init];
                
                [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    
                    [self.params setObject:obj forKey:key];
                    
                }];
                
                
 /*               [self.params setObject:[parameters objectForKey:@"azienda"] forKey:@"azienda"];
                [self.params setObject:[parameters objectForKey:@"username"] forKey:@"username"];
                [self.params setObject:[parameters objectForKey:@"password"] forKey:@"password"];*/
                parameters = NULL;
                response = NULL;
                retval = NULL;
                
                if(self.navigation == NULL){
                    //Se ancora non è stata avviata l'app
                    apps_list *cn = [[apps_list alloc]initWithNibName:@"apps_list" bundle:nil];
                    self.navigation = [[UINavigationController alloc]initWithRootViewController:cn];
                }
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
