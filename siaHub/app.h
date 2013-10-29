//
//  app.h
//  siaHub
//
//  Created by Vincenzo on 22/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface app : NSObject
{
    
}

@property (nonatomic, strong, readonly) NSURL *imageURL; //Url dell'immagine
@property (nonatomic, strong, readonly) NSString *appName; //Nome dell'app
//@property (nonatomic, strong, readonly) NSString *description; //Descrizione dell'app
@property (nonatomic, strong, readonly) NSString *query; //Query da eseguire
@property (nonatomic, strong, readonly) UIImage *icon; //icona

+ (app *)appWithIconUrl:(NSURL *)imageURL name:(NSString*)appName
             andQuery:(NSString*)query;

@end
