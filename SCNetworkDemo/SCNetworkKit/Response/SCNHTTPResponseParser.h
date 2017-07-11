//
//  SCNHTTPResponseParser.h
//  SCNetWorkKit
//
//  Created by 许乾隆 on 2016/11/25.
//  Copyright © 2016年 sohu-inc. All rights reserved.
//
//目前对于响应数据的解析,不够优雅，于是单独抽取一个类来做这件事

#import <Foundation/Foundation.h>
#import "SCNResponseParser.h"

extern NSInteger SCNResponseErrCannotPassValidate;

NS_ASSUME_NONNULL_BEGIN

@interface SCNHTTPResponseParser : NSObject<SCNResponseParser>

@property (nonatomic, copy, nullable) NSIndexSet *acceptableStatusCodes;
@property (nonatomic, copy, nullable) NSSet <NSString *> *acceptableContentTypes;

+ (instancetype)parser;

@end

NS_ASSUME_NONNULL_END
