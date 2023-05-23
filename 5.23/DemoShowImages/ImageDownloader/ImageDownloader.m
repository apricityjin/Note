//
//  ImageDownloader.m
//  test
//
//  Created by apricity on 2023/5/23.
//

#import "ImageDownloader.h"

@implementation ImageDownloader

//+ (instancetype)sharedImageDownloader {
//    static ImageDownloader * instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[self alloc] init];
//    });
//    return instance;
//}

- (void)dealloc
{
    NSLog(@"");
}

- (void)downloadImageFromURL:(NSURL *)url {
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask * dataTask = [session dataTaskWithRequest:request];
    
    [dataTask resume];
}

- (void)downloadImageFromURL:(NSURL *)url completionBlock:(void (^)(UIImage * image))completion {
    if (completion) {
        [self setCompletionBlock:completion];
    }
    [self downloadImageFromURL:url];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    UIImage * image = [UIImage imageWithData:data];
    
    if (self.completionBlock) {
        self.completionBlock(image);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"%@", error);
    }
}

@end
