//
//  TKCustomURLProtocol.m
//  CustomProtocolDemo
//
//  Created by usee on 2018/7/6.
//  Copyright © 2018年 tax. All rights reserved.
//

#import "TKCustomURLProtocol.h"

static  NSString *const identifier = @"TKCustomURLProtocolIdentifier";
@interface TKCustomURLProtocol() <NSURLSessionDataDelegate>
@end
@implementation TKCustomURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    NSLog(@"%@",[self propertyForKey:identifier inRequest:request]);
    NSLog(@"%s", __func__);
    if ([self propertyForKey:identifier inRequest:request]) {
        return NO;
    }
    
    NSString *scheme = [[request URL] scheme];
    if ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
        [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame) {
        return YES;
    }
    
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{
    NSLog(@"%s", __func__);
    
    return request;
}

- (void)startLoading{
    NSLog(@"%s", __func__);
    NSMutableURLRequest *mRequest = [self.request mutableCopy];
    [self.class setProperty:@(YES) forKey:identifier inRequest:mRequest];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:mRequest];
    [dataTask resume];
    
}

- (void)stopLoading{
    NSLog(@"%s", __func__);
}


#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    }else{
        [self.client URLProtocolDidFinishLoading:self];
    }
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    completionHandler(NSURLSessionResponseAllow);
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [self.client URLProtocol:self didLoadData:data];
}



@end
