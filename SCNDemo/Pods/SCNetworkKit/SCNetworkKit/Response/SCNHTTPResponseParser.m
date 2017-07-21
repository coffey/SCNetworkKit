//
//  SCNHTTPResponseParser.m
//  SCNetWorkKit
//
//  Created by 许乾隆 on 2016/11/25.
//  Copyright © 2016年 sohu-inc. All rights reserved.
//

#import "SCNHTTPResponseParser.h"
#import "SCNHeader.h"

NSInteger SCNResponseErrCannotPassValidate = -9000;

@implementation SCNHTTPResponseParser

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    }
    return self;
}

- (BOOL)validateResponse:(NSHTTPURLResponse *)response
                    data:(NSData *)data
                   error:(NSError * __autoreleasing *)error
{
    BOOL responseIsValid = YES;
    NSError *validationError = nil;
    
    if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        
        if (self.acceptableContentTypes && ![self.acceptableContentTypes containsObject:[response MIMEType]]) {
            
            NSDictionary *userInfo = @{
                                       @"content-type": [NSString stringWithFormat:@"Request failed: unacceptable content-type: %@", [response MIMEType]],
                                       @"url":[response URL]
                                       };
            
            validationError = SCNError(NSURLErrorCannotDecodeContentData, userInfo);
            
            responseIsValid = NO;
        }
        
        if (self.acceptableStatusCodes && ![self.acceptableStatusCodes containsIndex:(NSUInteger)response.statusCode] && [response URL]) {
            NSDictionary *userInfo = @{
                                       @"statusCode": [NSString stringWithFormat:@"Request failed: (%ld)", (long)response.statusCode],
                                       @"url":[response URL],
                                       };
            
            validationError = SCNError(response.statusCode, userInfo);
            
            responseIsValid = NO;
        }
    }
    
    if (error && !responseIsValid) {
        *error = validationError;
    }
    
    return responseIsValid;
}

- (id)parseredObjectForResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
    if ([self validateResponse:response data:data error:error]) {
        return data;
    }else{
        return nil;
    }
}

+ (instancetype)parser
{
    return [[self alloc]init];
}

@end