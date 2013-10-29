//
//  client_list.m
//  siaHub
//
//  Created by Vincenzo on 24/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "client_list.h"
#import "AppDelegate.h"
@interface client_list ()

@property (nonatomic, weak) IBOutlet UITableView *clientList;
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet UIButton *refresh;
@property (nonatomic, weak) IBOutlet UIButton *show;

@property (nonatomic,retain) NSMutableDictionary *clients;
@property (nonatomic,retain) NSMutableDictionary *selectedClient;
@property (assign, readwrite) BOOL reload; //Variabile per indicare che la tabella è stata aggiornata

@end

@implementation client_list

- (void)setMosquittoClient
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    msq_tto = [delegate mosquittoClient];
    [msq_tto setDelegate:self];
    [msq_tto connect];
    delegate = NULL;
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
    }
    return self;
}



-(IBAction)refresh:(id)sender
{
    
    [self.clients removeAllObjects];
    [self.selectedClient removeAllObjects];
    [self.clientList reloadData];
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSString *unique = [delegate getUniqueClientId];
    
   
    
    
    NSString* messaggio =
    [msq_tto createMessageForId:[NSString stringWithFormat:@"%@_%d",unique,[delegate getIncrementalInt]] responseTo:@"" name:@"DISCOVERINGCONNECTEDCLIENT" command:[[NSDictionary alloc]init] header:[[NSDictionary alloc]init] body:[[NSDictionary alloc]init] andSender:unique];
    
    [msq_tto publishString:messaggio toTopic:[NSString stringWithFormat:@"C43/BROADCAST"] withQos:1 retain:FALSE];
    
    
    
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



- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)connectionSetUp {
    //Proviamo a ricollegarci
    [self setMosquittoClient];
    [self.clients removeAllObjects];
    [self.selectedClient removeAllObjects];
    [self.clientList reloadData];
    
    [msq_tto subscribe:@"C43/BROADCAST"];
    [self refresh:NULL];
}

-(void)viewWillAppear:(BOOL)animated{
     [self.clientList setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    
    [self connectionSetUp];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    //In modo che non vengano più gestite le eventuali comunicazioni  da questa view
    [msq_tto unsubscribe:@"C43/BROADCAST"];
    [self.clients removeAllObjects];

}

#pragma mark MosquittoClientDelegateMethod

- (void) didConnect: (NSUInteger)code{
    


    
    
}
- (void) didDisconnect
{
    [self connectionSetUp];
}
- (void) didPublish: (NSUInteger)messageId{
   
}

- (void) didReceiveMessage: (mosquitto_message*)mosq_msg{
    if([mosq_msg.name isEqualToString:@"CONNECTEDCLIENT"]){
        
        NSLog(@"Body Message %@",mosq_msg.body);
        
        //Si deve riaggiornare la lista
        self.reload = TRUE;
        [self.clients setObject:mosq_msg.body forKey:mosq_msg.sender];
    }
    
    
    
    
    [self.clientList reloadData];
}
- (void) didSubscribe: (NSUInteger)messageId grantedQos:(NSArray*)qos{
    
    NSLog(@"didSubscribe");
}
- (void) didUnsubscribe: (NSUInteger)messageId{
    
    NSLog(@"didUnsubscribe");
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark UITableDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return 85.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   // return [[self.clients allKeys]count];
    return [self.clients count];
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
}







- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self checkBtnPressed:indexPath];
    
}


-(IBAction)toggleAllRow:(id)sender{


    if([[self.selectedClient allKeys] count] != [[self.clients allKeys]count]){
        //Non sono selezionati tutti gli elementi
        [[self.clients allKeys]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            [self.selectedClient setObject:[self.clients objectForKey:obj] forKey:obj];
        }];

    }
    else{
        //Sono selezionati alcuni elementi -> Deselezioniamo tutto
        [self.selectedClient removeAllObjects];
    }
    
    [self.clientList reloadData];
}



@end
