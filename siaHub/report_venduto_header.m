//
//  report_venduto_header.m
//  siaHub
//
//  Created by Vincenzo on 18/11/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "report_venduto_header.h"

@interface report_venduto_header ()

@end

@implementation report_venduto_header
@synthesize store,hour,date,day;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
        CALayer *l = [self.view layer];
        
        [l setMasksToBounds:YES];
        [l setBorderWidth:1.0];
        [l setCornerRadius:10.0f];
        [l setBorderColor:[UIColor grayColor].CGColor];
        
        
        [self.hour setText:NSLocalizedString(@"HOUR LAST SELL", NULL)];
        [self.store setText:NSLocalizedString(@"STORE", NULL)];
        [self.date setText:NSLocalizedString(@"DATE", NULL)];
        [self.day setText:NSLocalizedString(@"DAY", NULL)];
        
        
    }
    return self;
}


+(float)getHeaderHeight{
    
    return 50.0f;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
