//
//  ViewController.m
//  DebugApp
//
//  Created by Marian PAUL on 10/04/12.
//  Copyright (c) 2012 iPuP SARL. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Pseudo.h"
#import "DownloadOperation.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize moc = _moc;
@synthesize locationManager = _locationManager;

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
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.moc = appDelegate.managedObjectContext;
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    }
    _gpsEnabled = NO;
}


- (void) methodWithCompletion:(void (^)(BOOL finished))completion
{
    // Traitement (par exemple téléchargement de données)
    // une fois fini, on éxécute le block de completion
    completion(YES);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    UIView *theViewToMove = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 10)];
    [self.view addSubview:theViewToMove];
    BOOL animated;
    
    CGFloat xTranslation = 40.0;
    UIView *viewToRemove = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 10)];
    [self.view addSubview:viewToRemove];
    
    void (^completionBlock)(BOOL) = ^(BOOL finished) {
        if (finished) {
            [viewToRemove removeFromSuperview];
            
            // Montrer une alerte
            // Faire un tas de traitements, ... Les possibilités sont infinies
            // L'avantage est que toutes les variables locales sont dans le block, et passées dans un autre contexte à travers la méthode appelée ci dessous
        }
    };
    
    [self methodWithCompletion:completionBlock];
[self performSelectorInBackground:@selector(downloadData) withObject:nil];
    [NSThread detachNewThreadSelector:@selector(downloadData) toTarget:self withObject:nil];
    dispatch_queue_t queue = dispatch_get_global_queue(
                                                       DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSURL *url = [[NSURL alloc] initWithString:@"http://www.ipup.fr/livre/getPost?parametre=get_synch"];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        NSURLResponse *reponse = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&reponse error:&error];
        // L'application ne bloquera plus, mais il faut mettre à jour le label sur le processus principal !
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateLabel:data];
        });
    });
    
    NSOperationQueue *_downloadQueue;
    
    
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        [_downloadQueue setMaxConcurrentOperationCount:2];
    }
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.ipup.fr/livre/getPost?parametre=get_synch"];
    DownloadOperation *downloadOp = [[DownloadOperation alloc] initWithURL:url andDelegate:self];
    [_downloadQueue addOperation:downloadOp];
    downloadOp.queuePriority = NSOperationQueuePriorityHigh;
    [downloadOp setCompletionBlock:^{
        
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(displayAlertSubscription) userInfo:nil repeats:NO];
    [self performSelector:@selector(displayAlertSubscription) withObject:nil afterDelay:60.0];
}

- (void) downloadData 
{
    @autoreleasepool {
        NSURL *url = [[NSURL alloc] initWithString:@"http://www.ipup.fr/livre/getPost?parametre=get_synch"];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        NSURLResponse *reponse = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&reponse error:&error];
        // Il faut toujours mettre à jour le label sur le processus principal !
        [self performSelectorOnMainThread:@selector(updateLabel:) withObject:data waitUntilDone:NO];
    }
}

- (void) downloadOperation:(DownloadOperation*)operation didFinishDownloadingData:(NSData*)data
{
    [self updateLabel:data];
}

- (void) downloadOperation:(DownloadOperation *)operation didFailWithError:(NSError*)error
{
    NSLog(@"Ouuups, erreur %@", [error localizedDescription]);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)startStopGPS:(id)sender 
{
    if (_gpsEnabled)
        [self.locationManager stopUpdatingLocation];
    else
        [self.locationManager startUpdatingLocation];
    
    _gpsEnabled = !_gpsEnabled;
}

- (IBAction)insertCoreDataObjects:(id)sender 
{
    for (int i = 0 ; i < 40 ; i ++)
    {
        Pseudo *pseudo = (Pseudo*)[NSEntityDescription insertNewObjectForEntityForName:@"Pseudo" inManagedObjectContext:self.moc];
        [pseudo setNom:@"Un nom"];
        [pseudo setAge:[NSNumber numberWithInt:arc4random()%70]];
    }
    [self.moc save:nil];
}

- (IBAction)executeFetchRequest:(id)sender 
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pseudo" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"age < 50"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Erreur");
    }
    
    [fetchRequest release];
}

- (IBAction)createManyObjects:(id)sender 
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < 1000000 ; i ++)
    {
        NSNumber *number = [[NSNumber alloc] initWithInt:i];
        [tempArray addObject:number];
        [number release];
    }
    [tempArray release];
}

- (IBAction)createZombies:(id)sender 
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSNumber *number = [[NSNumber alloc] initWithInt:10];
    [array addObject:number];
    [number release];
    [array release];
    
    number = [[NSNumber alloc] initWithInt:20];
    // L'objet array est libéré, ça va crasher
    [array addObject:number];
    [number release];
}
@end
