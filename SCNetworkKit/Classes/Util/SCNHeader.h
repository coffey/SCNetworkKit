//
//  SCNHeader.h
//  SCNetWorkKit
//
//  Created by 许乾隆 on 2016/11/25.
//  Copyright © 2016年 sohu-inc. All rights reserved.
//

#ifndef SCNHeader_h
#define SCNHeader_h

extern NSError * SCNErrorWithOriginErr(NSError *originError,NSInteger newcode);
extern NSError * SCNError(NSInteger code,id info);

#define SCNResponseErrCannotPassValidate -9000
///按照指定的keypath找不到目标json
#define SCNResponseErrCannotFindTargetJson -9001

#define __weakSelf_scn_   typeof(self)weakself = self;
#define __strongSelf_scn_ typeof(weakself)self = weakself;

#endif /* SCNHeader_h */
