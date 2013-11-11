//
//  selectPeriod.m
//  siaHub
//
//  Created by Vincenzo on 08/11/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "selectPeriod.h"


@interface selectPeriod ()




@property (nonatomic, readwrite) IBOutlet UILabel *from;
@property (nonatomic, readwrite) IBOutlet UILabel *to;

@property (nonatomic, readwrite) IBOutlet UIDatePicker *fromDP;
@property (nonatomic, readwrite) IBOutlet UIDatePicker *toDP;


@property (nonatomic, readwrite) IBOutlet UIButton *cancel;
@property (nonatomic, readwrite) IBOutlet UIButton *ok;


@property (nonatomic, readwrite) IBOutlet UIView  *dateSelector;
@property (nonatomic, readwrite)  UIView  *modal;

@end

@implementation selectPeriod


- (IBAction)showCalendar:(id)sender {

    
    UIView * modal = [[UIView alloc]initWithFrame:self.view.frame];
    
    [modal setBackgroundColor:[UIColor lightGrayColor]];
    [modal setAlpha:0.3];
    [self.view addSubview:modal];
    
    
    [self.view addSubview:self.dateSelector];
     self.dateSelector.frame = CGRectMake(0, 999, self.dateSelector.frame.size.width, self.dateSelector.frame.size.height);

    [UIView animateWithDuration:0.01f
                     animations:^{
                         //self.dateSelector.frame = CGRectMake(0, self.dateSelector.frame.size.height , self.dateSelector.frame.size.width, self.dateSelector.frame.size.height);
                         
                         self.dateSelector.center = self.view.center;
                     }];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       // self.pageTitle.text = NSLocalizedString(@"SELECT PERIOD", NULL);
        
    }   
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"SELECT PERIOD", NULL);
    [self.pageTitle setText:@"Ciao"];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate{
    return FALSE;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait ;
}


@end