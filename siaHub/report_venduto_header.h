//
//  report_venduto_header.h
//  siaHub
//
//  Created by Vincenzo on 18/11/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface report_venduto_header : UIViewController


@property (nonatomic,retain)IBOutlet UILabel *store;
@property (nonatomic,retain)IBOutlet UILabel *hour;
@property (nonatomic,retain)IBOutlet UILabel *date;
@property (nonatomic,retain)IBOutlet UILabel *day;
@property (nonatomic,retain)IBOutlet UIActivityIndicatorView *loading;

+(float)getHeaderHeight; //Ritorna l'altezza dell'header
@end
