//
//  selectPeriod.m
//  siaHub
//
//  Created by Vincenzo on 11/11/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "selectPeriod.h"
#import "AppDelegate.h"


@interface selectPeriod ()

@property (nonatomic,retain) IBOutlet UIView *selectDate;
@property (nonatomic,retain) IBOutlet UIView *modal;
@property (nonatomic,retain) IBOutlet UIButton *cancelPeriod;
@property (nonatomic,retain) IBOutlet UIButton *savePeriod;
@property (nonatomic,retain) IBOutlet UIDatePicker *data;

@property (assign,readwrite) int textfield;
@property (nonatomic,readwrite) NSDate *da;
@property (nonatomic,readwrite) NSDate *a;


@end

@implementation selectPeriod
- (IBAction)operationSelectDate:(id)sender {



    if([sender tag] == 5){
        
        if(self.da == NULL || self.a == NULL){
            UIAlertView * error = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SELECT DATE", NULL) message:NSLocalizedString(@"SELECT DATE MESSAGE", NULL) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NULL, nil];
            
            [error show];
        }
        else{
            //save modifiche
            if([self.da compare:self.a] == NSOrderedDescending)
            {
                
                
                UIAlertView * error = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WRONG PERIOD", NULL) message:NSLocalizedString(@"WRONG PERIOD MESSAGE", NULL) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NULL, nil];
                
                [error show];
                
            }
            else{
                
                AppDelegate * del = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                //Memorizzazione delle date
                
                [del setFrom:self.da];
                [del setTo:self.a];
                [self dismissViewControllerAnimated:NO completion:^{
                }];

                
            }
           
        }
        
        

    }
    else{
        [self dismissViewControllerAnimated:NO completion:^{
        }];

    }
    
    



}

- (IBAction)dateButtonPress:(id)sender {

        [UIView animateWithDuration:0.5 animations:^{
            
            [self.modal setFrame:self.view.frame];
            
        [self.selectDate setAlpha:0.0];
        [self.modal setAlpha:0.0];
      
        } completion:^(BOOL finished) {
            
            //Imposta il valore scelto
            if([sender tag] == 1){
                
                
                if(self.textfield == 100){
                    
                    //Data da
                    self.da = self.data.date;
                    
                }
                else{
                    self.a = self.data.date;
                }
            
                NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
                // [outputFormatter setLocale:self.data.locale];
                
                [outputFormatter setDateFormat:@"dd-MMM-yyyy"];
                [((UITextField*)[self.view viewWithTag:self.textfield]) setText:[outputFormatter stringFromDate:self.data.date]];
            }
            
        }];
}

- (IBAction)selectDate:(id)sender {
    self.textfield = [sender tag] -1 ;
    [UIView animateWithDuration:0.5 animations:^{
         [self.modal setUserInteractionEnabled:FALSE];
        if([self.selectDate superview] == NULL){
            [self.view addSubview:self.modal];
            
            [self.view addSubview:self.selectDate];
            
        }
        [self.modal setAlpha:0.5];
        
        AppDelegate * del = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        
        if(self.textfield == 100){
            
            
            if(del.from != NULL){
                
               self.da = del.from;
                [self.data setDate:self.da];
            }
            
            
            
            
        }
        else{
            if(del.to != NULL){
                
                self.a = del.to;
                [self.data setDate:self.a];
            }
        }
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        // [outputFormatter setLocale:self.data.locale];
        
        [outputFormatter setDateFormat:@"dd-MMM-yyyy"];
        if(self.data.date != NULL) [((UITextField*)[self.view viewWithTag:self.textfield]) setText:[outputFormatter stringFromDate:self.data.date]];

        
        
        
        
    } completion:^(BOOL finished) {
        
        
        
        
        [self.selectDate setAlpha:1.0];
    }];
    

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
   // [self.data setDate:[NSDate new]];
    
    AppDelegate * del = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    // [outputFormatter setLocale:self.data.locale];
    
    [outputFormatter setDateFormat:@"dd-MMM-yyyy"];
    
    if(del.from != NULL){
        
        self.da = del.from;

        [((UITextField*)[self.view viewWithTag:100]) setText:[outputFormatter stringFromDate:self.da]];
    }
    if(del.to != NULL){
        
        self.a = del.to;
        
        [((UITextField*)[self.view viewWithTag:200]) setText:[outputFormatter stringFromDate:self.a]];
    }

    
    
    [self.selectDate setAlpha:0];
    self.selectDate.center = self.view.center;
    
    CALayer * layer = [self.selectDate layer];
    
    [layer setMasksToBounds:YES];
    [layer setBorderWidth:1];
    [layer setCornerRadius:10.0f];    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
