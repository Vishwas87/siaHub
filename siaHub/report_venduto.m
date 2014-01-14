//
//  report_venduto.m
//  siaHub
//
//  Created by Vincenzo on 18/11/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "report_venduto.h"
#import "report_venduto_header.h"
#import "AppDelegate.h"
#import "MqttBroker.h"
#import "venduto_report_cell.h"
#import "buttonWithSource.h"
@interface report_venduto ()


@property (nonatomic,retain) NSMutableDictionary *sectionsHeaders; //Artray che contiene le view per le varie sezioni
@property (nonatomic,retain) NSMutableDictionary *exapdanded; //Array che tiene traccia delle sezioni esapnse

@property (nonatomic,retain) IBOutlet UITableView *clients;
@property (nonatomic,retain) NSString* queue;
@property (nonatomic,retain) AppDelegate *delegate;
@property (nonatomic,retain) NSOperationQueue *operations; //Coda per le operazioni


@end

@implementation report_venduto


-(void)viewWillDisappear:(BOOL)animated
{
    
    [self.operations cancelAllOperations];
    
    MqttBroker * broker =[MqttBroker instance];
    NSString *unique = [MqttBroker getUniqueClientId];
    
    [[self.source allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      

        
        [broker unsubscribeClient:self fromTopic:[NSString stringWithFormat:@"%@/%@/OUT/%@",self.queue,obj,unique]];
        

        
    }];

    
    
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.sectionsHeaders = [[NSMutableDictionary alloc]init];
        self.queue = [[self.delegate params] objectForKey:@"customer_code"];

        self.queue = @"C43";//TODO DA RIMUOVERE
        self.title = NSLocalizedString(@"REPORT VENDUTO", NULL);
        self.delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        
        self.operations = [[NSOperationQueue alloc] init];
        [self.operations setMaxConcurrentOperationCount:1]; //Una sola operazione alla volta

        
    
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.exapdanded = [[NSMutableDictionary alloc]init];

    
    
    [[self.source allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [self.exapdanded setObject:[NSNumber numberWithBool:FALSE] forKey:obj];
        
        
    }];
    

    
    [self requestSoldFromClients];
    
    
    
    
}

-(void)requestSoldFromClients
{
  MqttBroker *broker = [MqttBroker instance];
    
    int num =[broker getIncrementalInt];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    
    NSString *from = [df stringFromDate:[self.delegate from]];
    NSString *to = [df stringFromDate:[self.delegate to]];
    
    
    
    NSDictionary * header = (from!= NULL && to != NULL)?[NSDictionary dictionaryWithObjectsAndKeys:from,@"DATE_FROM",to,@"DATE_TO", nil]:[[NSDictionary alloc]init];
    
    
    NSString *unique = [MqttBroker getUniqueClientId];
    NSString* messaggio =
    [MosquittoClient createMessageForId:[NSString stringWithFormat:@"%@_%d",unique,num] responseTo:@"" name:@"CURRENTSTOREPERFORMANCEINDEX" command:[[NSDictionary alloc]init] header:header body:[[NSDictionary alloc]init] andSender:unique];
    

    [[self.source allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@/%@/OUT/%@",self.queue,obj,unique);
        [broker subscribeClient:self toTopic:[NSString stringWithFormat:@"%@/%@/OUT/%@",self.queue,obj,unique]];
        
        
        
        if(![[[broker publishMessage:messaggio onTopic:[NSString stringWithFormat:@"%@/%@/IN",self.queue,obj] withQos:1 retained:FALSE andPublisher:self] objectForKey:@"CODE"]isEqualToString:@"0"] ){
            
        }
        
        
    }];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)showDetailHeaderForSection:(NSDictionary*)sectionInfo
{

    
    report_venduto_header *head = [sectionInfo objectForKey:@"sender"];
    
    NSString *text = [NSString stringWithFormat:@" %@",[sectionInfo objectForKey:@"last_Sell_hour"]];
    [head.hour setText:[head.hour.text stringByAppendingString:text]];
    [head.date setText:[sectionInfo objectForKey:@"last_Sell_day"]];
    [head.hour setHidden:FALSE];
    [head.date setHidden:FALSE];
    
}



#pragma mark -- Broker Methods
-(void)receivedAMessage:(mosquitto_message*)aMessage withStatus:(NSDictionary*)aConfig{
    
    
    
    __weak report_venduto *weakSelf = self;
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        
        
        NSString* sender;
        @try {
            if([[aMessage.header objectForKey:@"return_code"] intValue] == 0){
                
                //Tutto OK Nessun errore
                sender = aMessage.sender;
                
                NSString *last_Sell_day;
                NSString *last_Sell_hour;
                
                @try {
                    
                    
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                    
                    NSString*data = [[aMessage.body objectForKey:@"LAST_SALEDATETIME"] substringToIndex:19];
                    
                    NSDate *myDate = [df dateFromString: data];
                    //Prendiamo il day
                    [df setDateFormat:@"dd-MMM-yy"];
                    last_Sell_day = [df stringFromDate:myDate];
                    //Prendiamo l'ora
                    [df setDateFormat:@"hh:mm:ss"];
                    last_Sell_hour = [df stringFromDate:myDate];
                    
                }
                @catch (NSException *exception) {
                    
                    last_Sell_day = NSLocalizedString(@"N.A.", NULL);
                    last_Sell_hour = NSLocalizedString(@"N.A.", NULL);
                    
                }
                @finally {
                    
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:aMessage.body];
                    [dic removeObjectForKey:@"LAST_SALEDATETIME"];
                    [dic setObject:@"MORE_BUTTON" forKey:@"NOT_USE"];
                    
                    NSDictionary* d = [NSDictionary dictionaryWithObjectsAndKeys:[weakSelf.sectionsHeaders objectForKey:sender],@"sender", last_Sell_day,@"last_Sell_day",last_Sell_hour,@"last_Sell_hour", nil];
                    
                    
                    [weakSelf performSelectorOnMainThread:@selector(showDetailHeaderForSection:) withObject:d waitUntilDone:NO];
                    
                    d =  NULL;
                    
                    NSMutableDictionary * tmp = [NSMutableDictionary dictionaryWithDictionary:[weakSelf.source objectForKey:sender]];
                    
                    
                    [tmp setObject:dic forKey:@"BODY"];
                    [weakSelf.source removeObjectForKey:sender];
                    [weakSelf.source setObject:tmp forKey:sender];
                    dic = NULL;
                    
                    
                    
                    //Aggiorna la sezione specifica
                    int index = [[weakSelf.source allKeys] indexOfObject:sender];

                    
                    
                    [weakSelf performSelectorOnMainThread:@selector(reloadTableWithSectionAndAnimation:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",index],@"index", nil] waitUntilDone:NO];
                    
                }
                
                
            }
            else{
                //Il negozio ha mandato un messaggio di errore (array di errori)
                

                switch ([[aMessage.header objectForKey:@"return_code"] intValue]) {
                    case -1:
                    {
                        NSDictionary * dic = [NSDictionary  dictionaryWithObjectsAndKeys:[aMessage.header objectForKey:@"error_messages"],@"NO DATA AVAIABLE", nil];
                        NSString* sender = aMessage.sender;
                        [weakSelf.source setObject:dic forKey:sender];
                    }
                    break;
                        
                    default:
                        break;
                }
                

                
            }

        }
        @catch (NSException *exception) {
            
            //Visualizzare una notifica ---> errore
            
        }
        @finally {
            
        }
        
      
        
    }];
    
    [self.operations addOperation:op];
    
    
 
    
}


-(void)reloadTableWithSectionAndAnimation:(NSDictionary*)dict{
    
    
    int  index = [[dict objectForKey:@"index"] integerValue];

    if(index >= 0  || index < self.clients.numberOfSections)
    {
        [self.clients reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
    }

    
}





-(void)changedStatus:(NSDictionary*)statusClient //Metodo richiamato quando c'è una variazione dello stato nella connessione
{
    
}



#pragma mark -- Table Section
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    report_venduto_header *header;
    NSString* key = [[self.source allKeys] objectAtIndex:section];
    
    
    if([self.sectionsHeaders objectForKey:key] == NULL){
        
        //Creiamo la sezione
        
        report_venduto_header * section = [[report_venduto_header alloc]initWithNibName:@"report_venduto_header" bundle:NULL];
        
        [section.store setText:key];
        [section.hour setHidden:true];
        [section.date setHidden:true];
        [section.day setHidden:true];
        header = section;
        [self.sectionsHeaders setObject:header forKey:key];
    }
    
    
    else header = [self.sectionsHeaders objectForKey:key];
    
    return header.view;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self.source allKeys]count];
}


- (NSString *)setKey:(NSIndexPath *)indexPath {

    
    
    NSString *key;
    switch (indexPath.row) {
        case 0:
        {
            key = @"VALUE_SOLD";
            
        }
            break;
        case 1:
        { //int
            key = @"TOTAL_SOLD";
            
        }
        break;
        case 2:
        { //int
            key = @"NOT_USED";
            
        }
            break;
            
        case 3:
        {
            key = @"VALUE_NET";
            
        }
            break;
            
        case 4:
        {
            key = @"VALUE_DISCOUNT";
            
        }
            break;
        case 5:
        { //int
            key = @"TOTAL_RECEIPTS";
            
        }
            break;
        case 6:
        { //int
            key = @"TOTAL_ATTENDANCE";
            
        }
            break;
        case 7:
        {
            key = @"SHARE";
            
        }
            break;
        case 8:
        {
            key = @"AVERAGE_RECEIPT";
            
        }
            break;
        case 9:
        {
            key = @"AVERAGE_VALUE";
            
        }
            break;
        case 10:
        {
            key = @"AVERAGE_RECEIPT_PIECES";
            
        }
        break;
        default:
            break;
    }
    return key;
}

- (void)setValue:(NSString **)value_p key:(NSString *)key {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *numberFromString;
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@""];
    [formatter setDecimalSeparator:@"."];

    if((![key isEqualToString:@"TOTAL_SOLD"] && ![key isEqualToString:@"TOTAL_RECEIPTS"]  && ![key isEqualToString:@"TOTAL_ATTENDANCE"]))
    {
        //Valori con virgola -->> formatter
        [formatter setMaximumFractionDigits:2];
        [formatter setMinimumFractionDigits:2];
        numberFromString = [formatter numberFromString:*value_p];
        [formatter setGroupingSeparator:@"."];
        [formatter setDecimalSeparator:@","];
        [formatter setGroupingSize:3];
        
      
        
    }
    else{
        [formatter setMaximumFractionDigits:0];
        [formatter setMinimumFractionDigits:0];
        numberFromString = [formatter numberFromString:*value_p];
        [formatter setGroupingSize:3];

    }
    
      *value_p = [formatter stringFromNumber:numberFromString];
    
    
}

-(void)showDetailSection:(id)sender
{
   
    

    
    int i = [[self.source allKeys]indexOfObject:((buttonWithSource*)sender).source];
    
    if([[self.exapdanded objectForKey:((buttonWithSource*)sender).source] boolValue]){
        
        //Visibili -> da nascondere
        [self.exapdanded setObject:[NSNumber numberWithBool:FALSE] forKey:((buttonWithSource*)sender).source];
    }
    else [self.exapdanded setObject:[NSNumber numberWithBool:TRUE] forKey:((buttonWithSource*)sender).source];
    
    
    [self.clients reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationFade];
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"TableCellID";
    NSString *store = [[self.source allKeys]objectAtIndex:indexPath.section];
    /*
        CASI:
     
            1) NESSUN DATO PER LO STORE
            2) DATI
                2.1) NOT EXPANDED
                2.2) EXPANDED
     
     */
    
    if (indexPath.row == 2) {
        //Visualizza cella particolare
        NSString *classicCellIdentif = [cellIdentifier stringByAppendingString:[NSString stringWithFormat:@"_%@",store]];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:classicCellIdentif];
        if(!cell ){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:classicCellIdentif];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
            
            buttonWithSource * btn_src = [[buttonWithSource alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
            btn_src.tag = 100;
            btn_src.source = store;
            //btn_src.titleLabel.text=@"p";
            btn = NULL;
            
            
            [btn_src addTarget:self action:@selector(showDetailSection:) forControlEvents:UIControlEventTouchUpInside];
            btn_src.center = cell.center;
            [cell addSubview:btn_src];
        }
        //cell.detailTextLabel.text = @"ciao";
        buttonWithSource * n = (buttonWithSource*)[cell viewWithTag:100];
        if([[self.exapdanded objectForKey:store] boolValue])
        {
            
            [n setImage:[UIImage imageNamed:@"collapse.png"] forState:UIControlStateNormal];
        }
        else [n setImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
        return cell;
    }
    else{
        venduto_report_cell *cell = (venduto_report_cell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        
        if (!cell) {
            cell = [[venduto_report_cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
        }

    
 
        
        @try {
            NSDictionary *dict = [[self.source objectForKey:store] objectForKey:@"BODY"];
            NSString *key;
            NSString *value;
            NSString *label;
            
            
            
            key = [self setKey:indexPath];
            label = NSLocalizedString(key, NULL);
            
            value = ([dict objectForKey:key]!= NULL)?[dict objectForKey:key]: NSLocalizedString(@"N.A.", NULL);
            value = [NSString stringWithFormat:@"%@",value];
            
            [self setValue:&value key:key];
            
            [cell.valore setTextAlignment:NSTextAlignmentRight];
            [cell.valore setText:value];
            
            [cell.key setText:label];
            [cell.valore setText:value];
        }
        @catch (NSException *exception) {
            
            [cell.key setText:NSLocalizedString(@"N.A.", NULL)];
            [cell.valore setText:NSLocalizedString(@"N.A.", NULL)];
            
        }
        @finally {
            
            return cell;
        }
        
    }
    
    
    

}







- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSString *key = [[self.source allKeys]objectAtIndex:section];
    
    
    if([self.source objectForKey:key]!= NULL &&
       [[self.source objectForKey:key] objectForKey:@"BODY"] != NULL )
    {
        
        if([[self.exapdanded objectForKey:key] boolValue]){
            //TRUE --> tabella espansa
            return [[[self.source objectForKey:key] objectForKey:@"BODY"] count] ;
        }
        return 3; //solo i primi 3 campi ;
        
        
        
        //Il +1 NON SERVE PERCHè HO AGGIUNTO UN CAMPO IN PIù (VUOTO) IN [[self.source objectForKey:key] objectForKey:@"BODY"]
    }

    return 0;
    
}





- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return [report_venduto_header getHeaderHeight];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0f;
}

@end
