//
//  appslist_source.h
//  siaHub
//
//  Created by Vincenzo on 22/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "app.h"
#import <MosquittoClient.h>

@protocol appsList_protocol <NSObject>

-(void)listReady:(NSMutableArray*)arrayList;
-(void)listError:(NSError*)error;

@end

@interface appslist_source : NSObject
{
    
}

@property (nonatomic,retain) id<appsList_protocol> delegate;


+(appslist_source*)sharedInstance;

-(void) startListDownlod:(NSString*)urlList;

@end
