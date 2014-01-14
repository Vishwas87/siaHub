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




- (void)requestSold:(MqttBroker *)broker
{
    
    int num =[broker getIncrementalInt];
    NSString *unique = [MqttBroker getUniqueClientId];
    
    AppDelegate*del = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSDate *from = del.from;
    NSDate *to = del.to;
    
    NSMutableDictionary *header = [[NSMutableDictionary alloc]init];
    
    if(from!= NULL) [header setObject:from forKey:@"DATE_FROM"];
    if(to!= NULL) [header setObject:from forKey:@"DATE_TO"];
    
    
    
    NSString* messaggio =
    [MosquittoClient createMessageForId:[NSString stringWithFormat:@"%@_%d",unique,num] responseTo:@"" name:@"CURRENTSTOREPERFORMANCEINDEX" command:[[NSDictionary alloc]init] header:[[NSDictionary alloc]init] body:[[NSDictionary alloc]init] andSender:unique];
    

    [[self.source allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        if(![[[broker publishMessage:messaggio onTopic:[NSString stringWithFormat:@"C43/%@/IN",obj] withQos:1 retained:FALSE andPublisher:self] objectForKey:@"CODE"]isEqualToString:@"0"] ){
            
        }
        
        
    }];
    
    
    
    

    
    
}




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
        self.title = NSLocalizedString(@"REPORT VENDUTO", NULL);
     }
    return self;
}


-(void)viewWillAppear:(BOOL)animated{
   //  [self.table setContentInset:UIEdgeInsetsMake(10, 0, 0, 0)];
    

}

- (void)subscription
{
    // Do any additional setup after loading the view from its nib.
    
    

  /*
    
    
    NSString *unique = [MqttBroker getUniqueClientId];

    
    //code to be executed on the main queue after delay
    [[self.source allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        
        NSString *query = @"select sum(-TIPM07 * QTAM07) as total_qty, sum(-TIPM07 * (EPREV07 - ESCON07)) as total_value from movart1p where MAGZ07={STORE_ID} and DATM07 <= {TODAY_INT} and DATM07 >= {TODAY_INT} and CAUM07 in ('VENDT','RESOC')";
        
        //in body deve essere recuperata la query
        [self.clientMosquitto subscribe:[NSString stringWithFormat:@"C43/%@/OUT/%@",obj,unique]];
        NSString* messaggio =
        [MosquittoClient createMessageForId:[NSString stringWithFormat:@"%@_%d",unique,idx] responseTo:@"" name:@"EXECGENERICSQL" command:[[NSDictionary alloc]init] header:[[NSDictionary alloc]init] body:[NSDictionary dictionaryWithObject:query forKey:@"QUERY"] andSender:unique];
        
        [self.clientMosquitto publishString:messaggio toTopic:[NSString stringWithFormat:@"C43/%@/IN",obj] withQos:1 retain:FALSE];
        
        
    }];*/
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
   

    
}



- (void)viewWillDisappear:(BOOL)animated
{
    
    //Unregister from all topic
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) didReceiveMessage: (mosquitto_message*)mosq_msg{
    

    
    
    
    
    NSMutableArray *rowDef = [[mosq_msg.body objectForKey:@"RESULT"] objectForKey:@"row_def"];
    NSLog(@"Body %@",rowDef);
    NSMutableArray *rows = [[mosq_msg.body objectForKey:@"RESULT"] objectForKey:@"rows"];
    
    NSMutableDictionary * object = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:rowDef,rows, nil] forKeys:[NSArray arrayWithObjects:@"row_def",@"rows", nil] ];
    
    [self.source setObject:object  forKey:mosq_msg.sender];
    
    
    
    rowDef = NULL;
    rows = NULL;
    object = NULL;
    
    int index = [[self.source allKeys] indexOfObject:mosq_msg.sender];

    [self.table reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
    
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

    
    if([self.source objectForKey:key]!= NULL && [[self.source objectForKey:key] objectForKey:@"row_def"] != NULL )
    {
        
        return [[[self.source objectForKey:key] objectForKey:@"row_def"] count];
    }
    
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"TableCellID";
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    venduto_report_cell *cell = (venduto_report_cell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (!cell) {
        cell = [[venduto_report_cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    
    NSString *key = [[self.source allKeys]objectAtIndex:indexPath.section];
    NSDictionary * row_def =[[[self.source objectForKey:key] objectForKey:@"row_def"] objectAtIndex:indexPath.row];
    NSString *currentColumnName = [row_def objectForKey:@"ColumnName"];
    
   // NSLog(@"rows for key %@",[[self.source objectForKey:key] objectForKey:@"rows"]);
    NSString * currentValue = ([[[self.source objectForKey:key] objectForKey:@"rows"] count]>0)?[[[[self.source objectForKey:key] objectForKey:@"rows"] objectAtIndex:0]objectAtIndex:indexPath.row]:NSLocalizedString(@"NOT AVAIABLE", NULL);
    
   	
    [cell.key setText:currentColumnName];
    
    
    currentValue = [NSString stringWithFormat:@"%@",currentValue];
    currentValue = [appDelegate getColumnValueForConfiguration:row_def andString:currentValue];
    
    [cell.valore setTextAlignment:NSTextAlignmentRight];
    [cell.valore setText:currentValue];
    
    
    if([self.source objectForKey:key]!= NULL && indexPath.row == [[[[self.source objectForKey:key] objectForKey:@"rows"] objectAtIndex:0] count]-1)
    {
        
        UIView *currentSection = [self.activityIndicator objectForKey:key];
        [(UIActivityIndicatorView*)[currentSection viewWithTag:2] stopAnimating];
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
