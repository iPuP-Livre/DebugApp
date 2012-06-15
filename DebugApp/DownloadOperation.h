//
//  DownloadOperation.h
//  DebugApp
//
//  Created by Marian PAUL on 11/04/12.
//  Copyright (c) 2012 iPuP SARL. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloadOperationDelegate;

@interface DownloadOperation : NSOperation
{
    NSURL *_url;
}
- (id) initWithURL:(NSURL*)url andDelegate:(id<DownloadOperationDelegate>) delegate;

@property (nonatomic, assign) id <DownloadOperationDelegate> delegate;

@end

@protocol DownloadOperationDelegate <NSObject>

- (void) downloadOperation:(DownloadOperation*)operation didFinishDownloadingData:(NSData*)data;
- (void) downloadOperation:(DownloadOperation *)operation didFailWithError:(NSError*)error;

@end