//
//  DownloadOperation.m
//  DebugApp
//
//  Created by Marian PAUL on 11/04/12.
//  Copyright (c) 2012 iPuP SARL. All rights reserved.
//

#import "DownloadOperation.h"

@implementation DownloadOperation
@synthesize delegate = _delegate;

- (id) initWithURL:(NSURL*)url andDelegate:(id<DownloadOperationDelegate>) delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        _url = url;
    }
    return self;
}


- (void) callDelegate: (SEL) selector withArg: (id) arg
{
    if([self.delegate respondsToSelector: selector])
    {
        [self.delegate performSelector:selector withObject:self withObject:arg];
    }
}


- (void) callDelegateOnMainThread:(SEL)selector withArg:(id)arg
{    
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [self callDelegate:selector withArg:self];
                   });
}

- (void) main
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_url];
    NSURLResponse *reponse = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&reponse error:&error];
    
    if (error) 
        [self callDelegateOnMainThread:@selector(downloadOperation:didFailWithError:) withArg:error];
    else 
        [self callDelegateOnMainThread:@selector(downloadOperation:didFinishDownloadingData:) withArg:data];
}

@end
