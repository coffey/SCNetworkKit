//
//  SCNetworkService+Shared.h
//  SCNetWorkKit
//
//  Created by 许乾隆 on 2017/2/28.
//  Copyright © 2017年 sohu-inc. All rights reserved.
//

#import "SCNetworkService.h"

@interface SCNetworkService (Shared)

/// 获取单例
+ (instancetype)sharedService;

@end