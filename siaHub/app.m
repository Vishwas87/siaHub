//
//  app.m
//  siaHub
//
//  Created by Vincenzo on 22/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "app.h"


@interface app ()

@property (nonatomic, strong, readwrite) NSURL *imageURL; //Url dell'immagine
@property (nonatomic, strong, readwrite) NSString *appName; //Nome dell'app
@property (nonatomic, strong, readwrite) NSString *query; //Query da eseguire
@property (nonatomic, strong, readwrite) UIImage *icon; //icona


@end

@implementation app



- (UIImage*) icon
{
        //Getter per icon
    
    if(! _icon && self.imageURL){
        NSData *imageData = [NSData dataWithContentsOfURL:self.imageURL];
        UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
        _icon = image;
        image = NULL;
    }
    return _icon;
}

+ (app *)appWithIconUrl:(NSURL *)imageURL name:(NSString*)appName
             andQuery:(NSString*)query
{
    return [[self alloc] initWith:imageURL appName:appName  andQuery:query];
}

- (id)initWith:(NSURL *)imageURL appName:(NSString*)appName
   andQuery:(NSString*)query
{
    self = [super init];
    if (self) {
        self.imageURL = imageURL;
       
        self.query = query;
        self.appName = appName;
    }
    return self;
}



@end
