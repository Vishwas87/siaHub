//
//  appslist_source.m
//  siaHub
//
//
//  Created by Vincenzo on 22/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//
/*
 
    Ogetto SINGLETON che rappresenta la sorgente della lista di app
 
 */
#import "appslist_source.h"

@interface appslist_source()

@property (nonatomic,retain) NSMutableArray *appsList;

@end

@implementation appslist_source
@synthesize delegate;
static appslist_source *sharedInstance = nil;

+(appslist_source*)sharedInstance
{
    
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
        sharedInstance.appsList = [[NSMutableArray alloc]init];
    }
    
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    
    if (self) {
        // Work your initialising magic here as you normally would
    }
    
    return self;
}







-(void) startListDownlod:(NSString*)urlList
{
    
    
   //FARE UNA RICHIESTA HTTP
    
    
        //Questo metodo avvierà la richiesta per la lista di funzionalità
    NSURL *url = [NSURL URLWithString:@"https://cdn1.iconfinder.com/data/icons/pretty_office_3/128/sales-report.png"];
    app *Venduto = [app appWithIconUrl:url name:@"Venduto"  andQuery:@"SELECT * FROM VENDUTO"];
    
    [sharedInstance.appsList addObject:Venduto];    
    Venduto = NULL;
    if(sharedInstance.delegate != Nil && [sharedInstance.delegate respondsToSelector:@selector(listReady:)]){
        [sharedInstance.delegate listReady:sharedInstance.appsList];
    }
    
        
    
}

@end
