//
//  AppDelegate.m
//  SCNMacDemo
//
//  Created by Matt Reach on 2018/11/26.
//  Copyright © 2018 互动创新事业部. All rights reserved.
//

#import "AppDelegate.h"
#import "SCNModelParser.h"
#import "SCNModelResponseParser.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    
    //如果你不需要网络请求框架，帮你搞定 JSON 转 Model 的，那么你就需要下面的注册！
    {
        ///通过注册的方式，让 SCJSONUtil 和 网络库解耦合;如果你的工程里有其他解析框架，只需修改 SCNModelParser 里的几个方法即可！
        
        ///使用网络请求之前注册好！
        [SCNModelResponseParser registerModelParser:[SCNModelParser class]];
    }
    
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
