//
//  apps_list.m
//  siaHub
//
//  Created by Vincenzo on 23/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import "apps_list.h"
#import "AppDelegate.h"

static NSString * const AppTitleIdentifier = @"AppTitle";


@interface apps_list ()
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic) int currentIndex;
@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;

@end

@implementation apps_list


-(void)viewDidLayoutSubviews{
    //Nasconde la barra di stato
    self.navigationController.navigationBar.opaque = FALSE;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;   // iOS 7 specific
}

-(void)listReady:(NSMutableArray*)arrayList
{
    
    //Metodo eseguito in seguito all'evento di ricezione Lista delle applicazioni
    
    [loading stopAnimating];
    [loading removeFromSuperview];
    self.dataArray = arrayList;
    [self.collectionView reloadData];
}

-(void)listError:(NSError*)error
{
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    //Specifico per la collectionview. Serve a posizionarlo correttamente
    
    [self.collectionView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"APPS", NULL)]; //Setting del nome della view
    appslist_source *source = [appslist_source sharedInstance];
    
    //Loading indicator per il caricamento della lista
    loading = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loading setHidesWhenStopped:TRUE];
    //Ingrandimento dell'activity inditicator
    loading.transform = CGAffineTransformMakeScale(2.75, 2.75);
    
    loading.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                UIViewAutoresizingFlexibleRightMargin |
                                UIViewAutoresizingFlexibleTopMargin |
                                UIViewAutoresizingFlexibleBottomMargin);
    loading.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds)/2);
    
    
    [loading setColor:[UIColor yellowColor]];
    [loading startAnimating];
    
    
    
    
    
    [source setDelegate:self];
    
    
    AppDelegate *delegate = ((AppDelegate*)[UIApplication sharedApplication].delegate);
    [source startListDownlod:[delegate.addresses objectForKey: @"getAppList"]];
    
    [self.collectionView addSubview:loading];
	[self setupCollectionView];
    
    self.thumbnailQueue = [[NSOperationQueue alloc] init];
    self.thumbnailQueue.maxConcurrentOperationCount = 2;
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UICollectionView methods

-(void)setupCollectionView {
    [self.collectionView registerClass:[app_cell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.collectionView setPagingEnabled:NO];

}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    

    app_cell *cell = (app_cell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
   
    [cell prepareForReuse];
     app *photo = self.dataArray[indexPath.item];
    [cell.text setText:[photo appName]];
    // load photo images in the background

  __weak apps_list *weakSelf = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        UIImage *image = [photo icon];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // then set them via the main queue if the cell is still visible.
            if ([weakSelf.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
                app_cell *cell =
                (app_cell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
                cell.imageView.image = image;
                if(!image)[cell.activity stopAnimating];
            }
        });
    }];
    
    operation.queuePriority = (indexPath.item == 0) ?
    NSOperationQueuePriorityHigh : NSOperationQueuePriorityNormal;
    
    [self.thumbnailQueue addOperation:operation];
    
    return cell;
    
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //TODO: MODIFICA IN MODO DA RENDERLO GENERICO 
    client_list *client = [[client_list alloc]initWithNibName:@"client_list" bundle:NULL];

    [self.navigationController pushViewController:client animated:NO];
    
}





#pragma mark -
#pragma mark Rotation handling methods

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:
(NSTimeInterval)duration {
    [UIView animateWithDuration:0.01 animations:^{
        [self.collectionView setAlpha:0];
    }];
    

    

    
    
    [self.collectionView.collectionViewLayout invalidateLayout];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    // Force realignment of cell being displayed
    [UIView animateWithDuration:0.2 animations:^{
        [self.collectionView setAlpha:1];
    }];
    
}
@end