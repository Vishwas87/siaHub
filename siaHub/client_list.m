//
//  client_list.m
//  siaHub
//
//  Created by Vincenzo on 24/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "client_list.h"
#import "selectPeriod.h"
@interface client_list ()

@property (nonatomic, strong) IBOutlet UITableView *clientList;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UIButton *refresh;
@property (nonatomic, strong) IBOutlet UIButton *show;
@property (nonatomic, strong) IBOutlet UIButton *selectAll;
@property (nonatomic,retain)NSString *queue;





@property (nonatomic, strong) IBOutlet UIView *header;
@property (nonatomic, strong) IBOutlet UIButton *headerButton;

@property (nonatomic, strong) IBOutlet UILabel *headerTitle;


@property (nonatomic,retain) NSOperationQueue *operations;
@property (nonatomic,retain) NSMutableDictionary *clients;
@property (nonatomic,retain) NSMutableDictionary *selectedClient;
@property (assign, readwrite) BOOL reload; //Variabile per indicare che la tabella è stata aggiornata




@end

@implementation client_list





- (void)discoverClients:(MqttBroker *)broker
{
    int num =[broker getIncrementalInt];
    NSString *unique = [MqttBroker getUniqueClientId];
    NSString* messaggio =
    [MosquittoClient createMessageForId:[NSString stringWithFormat:@"%@_%d",unique,num] responseTo:@"" name:@"DISCOVERINGCONNECTEDCLIENT" command:[[NSDictionary alloc]init] header:[[NSDictionary alloc]init] body:[[NSDictionary alloc]init] andSender:unique];
    
    
    
    [broker publishMessage:messaggio onTopic:@"C43/BROADCAST" withQos:1 retained:FALSE andPublisher:self];
}
- (IBAction)selectPeriod:(id)sender {
    
    selectPeriod *period = [[selectPeriod alloc]initWithNibName:@"selectPeriod" bundle:NULL];
    
    
    [self presentViewController:period animated:NO completion:^{
        
    }];
    
    
}

- (void)setMosquittoClient
{
 
   

    MqttBroker *broker = [MqttBroker instance];
    [broker subscribeClient:self toTopic:@"C43/BROADCAST"];

    [self discoverClients:broker];
    
    
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
        // Custom initialization
        self.clients = [[NSMutableDictionary alloc] init];
        self.reload = FALSE;
        [self setMosquittoClient];
        self.selectedClient = [[NSMutableDictionary alloc]init];
        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        self.queue = [[app params] objectForKey:@"customer_code"];
        self.title = NSLocalizedString(@"CLIENT LIST", NULL);
        self.operations = [[NSOperationQueue alloc] init];
        [self.operations setMaxConcurrentOperationCount:1]; //Una sola operazione alla volta
    }
    return self;
}



-(IBAction)refresh:(id)sender
{
  
    MqttBroker *broker = [MqttBroker instance];
    
    [self.clients removeAllObjects];
    [self.selectedClient removeAllObjects];
    
    
  /*  if([[self.clients allKeys]count]>0){
        [self.headerButton setEnabled:TRUE];
        if(([[self.selectedClient allKeys]count] == [[self.clients allKeys]count]) ){
            //Sono stati selezionati tutti gli elementi -> il pulsante deve essere DEseleziona
            [self.headerTitle setText:NSLocalizedString(@"DESELECT ALL", NULL)];
            [self.selectAll setImage:[UIImage imageNamed:@"deSelectAll.png"] forState:UIControlStateNormal];
        }
        else{
            [self.headerTitle setText:NSLocalizedString(@"SELECT ALL", NULL)];
            [self.selectAll setImage:[UIImage imageNamed:@"selectAll.png"] forState:UIControlStateNormal];
        }
    }
    else{*/
        [self.headerTitle setText:NSLocalizedString(@"NO CONNECTED CLIENT", NULL)];
        [self.headerButton setEnabled:FALSE];
    //}
    
    
    [self discoverClients:broker];
    
}
-(IBAction)show:(id)sender
{
    
    if([[self.selectedClient allKeys]count]== 0){
        
        UIAlertView *err = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"ATTENTION", NULL) message:NSLocalizedString(@"LEAST ONE CLIENT", NULL) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NULL, nil];
        [err show];
    }
    else
    {
       
        venduto_report *vend = [[venduto_report alloc]initWithNibName:@"venduto_report" bundle:NULL];
        [vend setSource:self.selectedClient];
        [self.navigationController pushViewController:vend animated:YES];

        
        
    }
    
}



-(void)receivedAMessage:(mosquitto_message*)aMessage withStatus:(NSDictionary*)aConfig
{
    
    
    
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        

        
        //Si è connesso un client
        if([aMessage.name isEqualToString:@"CONNECTEDCLIENT"]){
            //Si deve riaggiornare la lista
            self.reload = TRUE;
            [self.clients setObject:aMessage.body forKey:aMessage.sender];
        }
        //Si è disconnesso un client
        if([aMessage.name isEqualToString:@"DISCONNECTEDCLIENT"]){
            //Si deve riaggiornare la lista
            self.reload = TRUE;
            [self.clients removeObjectForKey:aMessage.sender];
        }
        
        
        [self.clientList performSelectorOnMainThread:@selector(reloadData) withObject:NULL waitUntilDone:NO];
        
   }];
    
    [self.operations addOperation:op];
    
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}






-(void)viewWillAppear:(BOOL)animated{
     [self.clientList setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
    

    
  //  [self refresh:NULL];
    
}


-(void)viewWillDisappear:(BOOL)animated{
    
    //In modo che non vengano più gestite le eventuali comunicazioni  da questa view
  //  [msq_tto unsubscribe:[NSString stringWithFormat:@"%@/BROADCAST",self.queue]];

}

#pragma mark MosquittoClientDelegateMethod

- (void) didConnect: (NSUInteger)code{
    


    
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark UITableDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    [self.header setFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40.0f)];
    
    CALayer *layer = [self.headerButton layer];
    
    [layer setMasksToBounds:YES];
    [layer setBorderWidth:1.0];
    [layer setBorderColor:[UIColor blackColor].CGColor];

    
    if([[self.clients allKeys]count]>0){
        [self.headerButton setEnabled:TRUE];
        if([[self.clients allKeys]count]>0 && [[self.selectedClient allKeys]count] == [[self.clients allKeys]count]){
            [self.headerTitle setText:NSLocalizedString(@"DESELECT ALL", NULL)];
            [self.headerButton setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        }
        else {
            [self.headerTitle setText:NSLocalizedString(@"SELECT ALL", NULL)];
            [self.headerButton setImage:NULL forState:UIControlStateNormal];
        }
    }
    else{
         [self.headerTitle setText:NSLocalizedString(@"NO CONNECTED CLIENT", NULL)];
        [self.headerButton setEnabled:FALSE];
    }
    
    

    
    
    return self.header;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return [client_cell returnCellHeight];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    return [[self.clients allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"TableCellID";
    client_cell *cell = (client_cell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (!cell) {
        cell = [[client_cell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier andReload: self.reload];
        
    }
    
    
    [cell setDelegate:self];
    
    [cell setIndex:indexPath];
    
    NSString *currentClientKey = [[self.clients allKeys]objectAtIndex:indexPath.row];
    NSDictionary *currentClient = [self.clients objectForKey:currentClientKey];
    
    cell.title.text = [NSString stringWithFormat:@"ID: %@",[currentClient objectForKey:@"CLIENTID"]];
    cell.detail.text = [currentClient objectForKey:@"DESCRIPTION"];
    
    
    if(!self.reload){
        
        //Non devo riaggiornare
        if([[self.selectedClient allKeys]containsObject:currentClientKey]){
            //Deve essere selezionata
            [cell selectCell];
        }
        else [cell deSelectCell];
    }
    else{
        [cell deSelectCell];
        if(indexPath.row == [[self.clients allKeys]count]-1){
            self.reload = false;
        }
            

    }
    
    
    return cell;
}


-(void)checkBtnPressed:(NSIndexPath*)selfIndex{
    
     client_cell * temp = (client_cell*)[self.clientList cellForRowAtIndexPath:selfIndex];
    
    NSString* el = [[self.clients allKeys]objectAtIndex:selfIndex.row];
    if([[self.selectedClient allKeys]containsObject:el]){
        //Era selezionato -> DESELEZIONARE
        [self.selectedClient removeObjectForKey:[[self.clients allKeys]objectAtIndex:selfIndex.row]];
        [temp performSelectorOnMainThread:@selector(deSelectCell) withObject:NULL waitUntilDone:NO];
    }
    else       {
            [self.selectedClient setObject:[[NSMutableDictionary alloc]init] forKey:[[self.clients allKeys]objectAtIndex:selfIndex.row]];
            [temp selectCell];
    }
    
    
    if([[self.selectedClient allKeys]count] == [[self.clients allKeys]count]){
        //Sono stati selezionati tutti gli elementi -> il pulsante deve essere DEseleziona
        [self.headerButton setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        [self.headerTitle setText:NSLocalizedString(@"DESELECT ALL", NULL)];

    }
    else{
        [self.headerButton setImage:NULL forState:UIControlStateNormal];
        [self.headerTitle setText:NSLocalizedString(@"SELECT ALL", NULL)];
 
    }
   // [self.header setNeedsDisplay];
    
}












- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self checkBtnPressed:indexPath];
    
}


-(IBAction)toggleAllRow:(id)sender
{


    if([[self.selectedClient allKeys] count] != [[self.clients allKeys]count]){
        //Non sono selezionati tutti gli elementi
        [(UIButton*)sender setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        [self.headerTitle setText:NSLocalizedString(@"DESELECT ALL", NULL)];
        [[self.clients allKeys]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            [self.selectedClient setObject:[self.clients objectForKey:obj] forKey:obj];
        }];

    }
    else{
        //Sono selezionati alcuni elementi -> Deselezioniamo tutto
        [self.selectedClient removeAllObjects];
        [(UIButton*)sender setImage:NULL forState:UIControlStateNormal];
        [self.headerTitle setText:NSLocalizedString(@"SELECT ALL", NULL)];
        
    }
   // [self.header setNeedsDisplay];
    [self.clientList reloadData];
}



@end
