//
//  venduto_report.m
//  siaHub
//
//  Created by Vincenzo on 25/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "venduto_report.h"

#import "AppDelegate.h"
#import "venduto_report_cell.h"
#import "venduto_report_header.h"
@interface venduto_report ()

@property (nonatomic,strong)IBOutlet UITableView *table;

@property (nonatomic,weak) MosquittoClient *clientMosquitto;
@property (nonatomic,retain) NSMutableDictionary *activityIndicator;

@end

@implementation venduto_report


-(void)viewDidLayoutSubviews{
    self.navigationController.navigationBar.opaque = FALSE;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;   // iOS 7 specific
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.activityIndicator = [[NSMutableDictionary alloc]init];
        // Custom initialization
      //  [self.table registerClass:[venduto_report_header class] forHeaderFooterViewReuseIdentifier:@"header"];
       // [self.table setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated{
     [self.table setContentInset:UIEdgeInsetsMake(10, 0, 0, 0)];
    

}

- (void)subscription
{
    // Do any additional setup after loading the view from its nib.
    
    

    
    
    
    AppDelegate *del = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSString *unique = [del getUniqueClientId];

    
    //code to be executed on the main queue after delay
    [[self.source allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //in body deve essere recuperata la query
        [self.clientMosquitto subscribe:[NSString stringWithFormat:@"C43/%@/OUT/%@",obj,unique]];
        NSString* messaggio =
        [self.clientMosquitto createMessageForId:[NSString stringWithFormat:@"%@_%d",unique,idx] responseTo:@"" name:@"EXECGENERICSQL" command:[[NSDictionary alloc]init] header:[[NSDictionary alloc]init] body:[NSDictionary dictionaryWithObject:@"" forKey:@"query"] andSender:unique];
        
        [self.clientMosquitto publishString:messaggio toTopic:[NSString stringWithFormat:@"C43/%@/IN",obj] withQos:0 retain:TRUE];
        
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.clientMosquitto = [delegate mosquittoClient];
    [self.clientMosquitto setDelegate:self];
    
    [self subscription];


    
}



- (void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *del = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSString *unique = [del getUniqueClientId];
    
    
    //code to be executed on the main queue after delay
    [[self.source allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //in body deve essere recuperata la query
        [self.clientMosquitto unsubscribe:[NSString stringWithFormat:@"C43/%@/OUT/%@",obj,unique]];

        
        
    }];
    
    [del resetDelegateMosquitto];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) didConnect: (NSUInteger)code{

}
- (void) didDisconnect{
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) didPublish: (NSUInteger)messageId{

}
- (void) didReceiveMessage: (mosquitto_message*)mosq_msg{
    [self.source setObject:mosq_msg.body  forKey:mosq_msg.sender];
    
    
    int index = [[self.source allKeys] indexOfObject:mosq_msg.sender];

    [self.table reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
    
}
- (void) didSubscribe: (NSUInteger)messageId grantedQos:(NSArray*)qos{
    
}
- (void) didUnsubscribe: (NSUInteger)messageId{
    
}



#pragma mark --UITable Methods


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [venduto_report_cell getRowHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSString *key = [[self.source allKeys]objectAtIndex:section];

    
    if([self.source objectForKey:key]!= NULL && [[self.source objectForKey:key] objectForKey:@"RESULT"] != NULL) return [[[self.source objectForKey:key] objectForKey:@"RESULT"] count];
    
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"TableCellID";
    venduto_report_cell *cell = (venduto_report_cell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (!cell) {
        cell = [[venduto_report_cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    
    NSString *key = [[self.source allKeys]objectAtIndex:indexPath.section];
    NSDictionary *currentValue = [[self.source objectForKey:key] objectForKey:@"RESULT"];
    
    NSString *currentKeyInDic = [[currentValue allKeys] objectAtIndex:indexPath.row];
    
    
    [cell.key setText:currentKeyInDic];
    
    NSString *value = @"";
    
    if(floorf([[currentValue objectForKey:currentKeyInDic] floatValue]) != [[currentValue objectForKey:currentKeyInDic] intValue]){
        value = [NSString stringWithFormat:@"%f",[[currentValue objectForKey:currentKeyInDic] floatValue]];
    }
    else value = [NSString stringWithFormat:@"%d",[[currentValue objectForKey:currentKeyInDic] intValue]];
    
    [cell.valore setTextAlignment:NSTextAlignmentRight];
    [cell.valore setText:value];
    
    
    if([self.source objectForKey:key]!= NULL && [[self.source objectForKey:key] objectForKey:@"RESULT"] != NULL &&  [[[self.source objectForKey:key] objectForKey:@"RESULT"] count] -1 == indexPath.row)
    {
        
        UIView *currentSection = [self.activityIndicator objectForKey:key];
        //[(UIActivityIndicatorView*)[currentSection viewWithTag:2] stopAnimating];
        currentSection = NULL;
    }

    
    
    
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self.source allKeys]count];
}
/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [[self.source allKeys]objectAtIndex:section];
}*/

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
  

    UIView *view;
    NSString* key = [[self.source allKeys] objectAtIndex:section];
    
    
    if([self.activityIndicator objectForKey:key] == NULL){
            //Non sono stati ricevuti ancora dati
            view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40.0f)];
            
            
            
            
            
            UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, tableView.frame.size.width * 0.70, 40.0f) ];
            [title setText:[[self.source allKeys]objectAtIndex:section]];
            
            [view addSubview:title];
            UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activity setTag:2]; //Il + 100 serve a distinguerla da altre view
            
            
            activity.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                         UIViewAutoresizingFlexibleRightMargin |
                                         UIViewAutoresizingFlexibleTopMargin |
                                         UIViewAutoresizingFlexibleBottomMargin);
            
            
            [activity setHidesWhenStopped:TRUE];
            
            
            float offSet = tableView.frame.size.width * 0.70;
            float width = tableView.frame.size.width * 0.30;
            
            
            
            
            activity.transform = CGAffineTransformMakeScale(1.20, 1.20);
            activity.center = CGPointMake((width / 2) + offSet  , title.frame.size.height / 2);
            
            
            
            [activity setColor:[UIColor yellowColor]];
            [activity startAnimating];
            
            [view addSubview:activity];
            
            CALayer * l = [view layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:10];
            
            [view setBackgroundColor:[UIColor lightGrayColor]];
            [self.activityIndicator setObject:view forKey:key];
        }


    else view = [self.activityIndicator objectForKey:key];

    return view;
}




@end
