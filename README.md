## SCNetworkKit

[![Version](https://img.shields.io/cocoapods/v/SCNetworkKit.svg?style=flat)](https://cocoapods.org/pods/SCNetworkKit)
[![License](https://img.shields.io/cocoapods/l/SCNetworkKit.svg?style=flat)](https://cocoapods.org/pods/SCNetworkKit)
[![Platform](https://img.shields.io/cocoapods/p/SCNetworkKit.svg?style=flat)](https://cocoapods.org/pods/SCNetworkKit)


SCNetworkKit 是一个为自己项目打造的网络库，支持 iOS / macOS 平台。该库将 [MKNetworkKit](https://github.com/MugunthKumar/MKNetworkKit) 、[AFNetworking](https://github.com/AFNetworking/AFNetworking) 、[Masonry](https://github.com/desandro/masonry)、[ASIHTTPRequest](https://github.com/debugly/asi-http-request) 等库的优秀架构思想融入其中，结合项目实际情况逐渐演变而来。

- 使用 Objective-C 语言编写
- 底层封装了 NSURLSession，因此最低支持 iOS 7.0 / OS X 10.9
- 采用 Service + Request 分工模式(从 MKNetworkKit 学习而来)
- 采用可配置的响应解析器模式，可以将数据异步解析为 JSON，Model，其中 Model 解析这块算是对 AFNetworking 响应解析模块学习的一个升华，按照自己的思路去完成的
- 支持链式编程 (从 Masonry 学习而来)
- 采用 Maker 方式精简对外公开的API长度，使用更方便(从 Masonry 学习而来)
- 支持了 HTTPBodyStream，轻松搞定大文件上传；可以说是弥补了 MKNetworkKit 的一个缺憾
- 自创自动取消机制，可将网络请求对象绑定到 x 对象上，当 x 销毁时将自动取消已经发起的网络请求（x 通常是 ViewController）
- 请求完成，进度回调等完全 Block 化，不支持代理（个人偏爱 Block）

## SCNetworkKit 演变过程

2016 年我转向 iOS SDK 相关开发工作，为确保提供出去的 SDK 显得很专业，容易集成，防止出现类冲突等报错问题，所以要尽量避免依赖开源项目！我需要的第一个轮子就是网络请求框架，必须能够为 SDK 提供可靠的网络服务，该库的演变过程如下:

`SVPNetworkKit` -> `SLNetworkKit` -> `SCNetworkKit`

- SVPNetworkKit : 在做 SDK 之前为上传模块写的一个独立的网络请求模块，是完全基于 MKNetworkKit 的，毫不保留的说就是在 MKNetworkKit 之上修改而成，并没有一点创新。
- SLNetworkKit : 转向 SDK 开发工作后，只有我一个，时间十分紧张，因此将 SVPNetworkKit 直接改名为 SLNetworkKit ，然后在此基础上进行修改。这个阶段主要支持了 Maker 形式的调用方式、抽取了响应解析模块、支持了Model解析、响应异步解析、自动取消等机制。
- SCNetworkKit : 随着 SDK 业务的增多，并且集成灵活，可以选取某几个组合集成！因此迫切需要将原来的 SDK 抽取出来一个更加通用的底层依赖库，所有的 SDK 均要依赖于改库，SLNetworkKit 也包含在其中，故而修改其前缀为 SC ！这个阶段主要将 POST 请求抽取出来，支持了HTTPBodyStream，方便大文件上传！于 2017 年开源。

## 目录结构

```
├── Example
│   ├── Server
│   ├── iOS
│   └── macOS
├── LICENSE
├── README.md
├── SCNetworkKit
│   └── Classes
├── SCNetworkKit.podspec
└── _config.yml
```

- Example/iOS(macOS) : 包含了 iOS、macOS 平台配套调用示例和简单的Node 服务器
- SCNetworkKit/Classes : 库源码
- Example/Server : 使用 Express 库编写的服务器，主要为 Demo 提供 POST 请求支持，客户端上传的文件都放在 `Server/upload` 文件夹下面。
    - 查看已经上传的文件: [http://localhost:3000/peek](http://localhost:3000/peek) 
    - 查看已经上传的文件（json形式）: [http://localhost:3000/peek?json=1](http://localhost:3000/peek?json=1) 
    - 使用浏览器上传的文件: [http://localhost:3000/](http://localhost:3000/) 

Server 使用方法:

```shell
cd Server
//第一次运行需要安装下依赖库，以后执行就不用了
npm install
//启动 server
npm start
```

## 安装方式

- 使用 CocoaPods 安装

    ```
    source 'https://github.com/CocoaPods/Specs.git'
    platform :ios, '7.0'
    
    target 'TargetName' do
    pod 'SCNetworkKit'
    end
    ```

- 使用源码

    下载最新 [release](https://github.com/debugly/SCNetworkKit/tags) 代码，找到 SCNetworkKit 目录，拖到工程里即可。


## 使用范例

假设服务器返回的数据格式如下：

```
{ 
  code = 0;
  content =     {
     entrance =         (
         {
	         isFlagship = 0;
	         name = "\U65f6\U5c1a\U6f6e\U65f6\U5c1a";
	         pic = "http://pic12.shangpin.com/e/s/15/03/03/20150303151320537363-10-10.jpg";
	         refContent = "http://m.shangpin.com/meet/185";
	         type = 5;
         },
         {
            //....
         }
       )
     }
 }

```

下面演示如何通过配置不同的解析器，从而达到着陆 block 回调不同结果的效果:


- 发送 GET请求，回调原始Data，不做解析

    ```objc
    SCNetworkRequest *req = [[SCNetworkRequest alloc]initWithURLString:kTestJSONApi params:nil];
    ///因为默认解析器是SCNJSONResponseParser；会解析成JSON对象；所以这里不指定解析器，让框架返回data！
    req.responseParser = nil;
    [req addCompletionHandler:^(SCNetworkRequest *request, id result, NSError *err) {
        
        if (completion) {
            completion(result,err);
        }
    }];
    
    [[SCNetworkService sharedService]startRequest:req];
    ```

- 发送 GET请求，回调 JOSN 对象

    ```objc
    SCNJSONResponseParser *responseParser = [SCNJSONResponseParser parser];
    ///框架会检查接口返回的 code 是不是 0 ，如果不是 0 ，那么返回给你一个err，并且result是 nil;
    responseParser.checkKeyPath = @"code";
    responseParser.okValue = @"0";
    
    ///support chain
    SCNetworkRequest *req = [[SCNetworkRequest alloc]init];
    
    req
    .c_URL(kTestJSONApi)
    .c_ResponseParser(responseParser)
    .c_CompletionHandler(^(SCNetworkRequest *request, id result, NSError *err) {
        
        if (completion) {
            completion(result,err);
        }
    });
    [[SCNetworkService sharedService]startRequest:req];
    ```

- 发送 GET请求，回调 Model 对象

    ```objc
    SCNetworkRequest *req = [[SCNetworkRequest alloc]initWithURLString:kTestJSONApi params:nil];
    
    SCNModelResponseParser *responseParser = [SCNModelResponseParser parser];
    ///解析前会检查下JSON是否正确；
    responseParser.checkKeyPath = @"code";
    responseParser.okValue = @"0";
    ///根据服务器返回数据的格式和想要解析结构对应的Model配置解析器
    responseParser.modelName = @"TestModel";
    responseParser.modelKeyPath = @"content/entrance";
    req.responseParser = responseParser;
    [req addCompletionHandler:^(SCNetworkRequest *request, id result, NSError *err) {
        
        if (completion) {
            completion(result,err);
        }
    }];
    [[SCNetworkService sharedService]startRequest:req];
    ```

由于上面有 JSON 转 Model 的过程，因此在使用之前需要注册一个对应的解析器，你可以到 demo 里搜下 **[SCNModelResponseParser registerModelParser:[SCNModelParser class]];** 具体看下究竟。

- 文件下载

    ```objc
    SCNetworkRequest *get = [[SCNetworkRequest alloc]initWithURLString:kTestDownloadApi2 params:nil];
    //NSString *path = [NSTemporaryDirectory()stringByAppendingPathComponent:@"node.jpg"];
    NSString *path = [NSTemporaryDirectory()stringByAppendingPathComponent:@"test.mp4"];
    NSLog(@"download path:%@",path);
    get.downloadFileTargetPath = path;
    get.responseParser = nil;
    [get addCompletionHandler:^(SCNetworkRequest *request, id result, NSError *err) {
        
        if (completion) {
            completion(path,err);
        }
    }];
    
    [get addProgressChangedHandler:^(SCNetworkRequest *request, int64_t thisTransfered, int64_t totalBytesTransfered, int64_t totalBytesExpected) {
        
        if (totalBytesExpected > 0) {
            float p = 1.0 * totalBytesTransfered / totalBytesExpected;
            NSLog(@"download progress:%0.4f",p);
            if (progress) {
                progress(p);
            }
        }
    }];
    
    [[SCNetworkService sharedService]startRequest:get];
    ```

- 文件上传

    ```objc
    NSDictionary *ps = @{@"name":@"Matt Reach",@"k1":@"v1",@"k2":@"v2",@"date":[[NSDate new]description]};
    SCNetworkPostRequest *post = [[SCNetworkPostRequest alloc]initWithURLString:kTestUploadApi params:ps];
    
    SCNetworkFormFilePart *filePart = [SCNetworkFormFilePart new];
    NSString *fileURL = [[NSBundle mainBundle]pathForResource:@"logo" ofType:@"png"];
    filePart.data = [[NSData alloc]initWithContentsOfFile:fileURL];
    filePart.fileName = @"logo.png";
    filePart.mime = @"image/jpg";
    filePart.name = @"logo";
    
    SCNetworkFormFilePart *filePart2 = [SCNetworkFormFilePart new];
    filePart2.fileURL = [[NSBundle mainBundle]pathForResource:@"node" ofType:@"txt"];
    
    post.formFileParts = @[filePart,filePart2];
    [post addCompletionHandler:^(SCNetworkRequest *request, id result, NSError *err) {
        
        if (completion) {
            completion(result,err);
        }
    }];
    
    [post addProgressChangedHandler:^(SCNetworkRequest *request, int64_t thisTransfered, int64_t totalBytesTransfered, int64_t totalBytesExpected) {
        
        if (totalBytesExpected > 0) {
            float p = 1.0 * totalBytesTransfered / totalBytesExpected;
            NSLog(@"upload progress:%0.4f",p);
            if (progress) {
                progress(p);
            }
        }
    }];

    [[SCNetworkService sharedService]startRequest:post];
    ```

- 通过表单POST数据

    ```objc
    NSDictionary *ps = @{@"name":@"Matt Reach",@"k1":@"v1",@"k2":@"v2",@"date":[[NSDate new]description]};
    SCNetworkPostRequest *post = [[SCNetworkPostRequest alloc]initWithURLString:kTestUploadApi params:ps];
    post.parameterEncoding = SCNPostDataEncodingFormData;
    [post addCompletionHandler:^(SCNetworkRequest *request, id result, NSError *err) {
        
        if (completion) {
            completion(result,err);
        }
    }];
    
    [[SCNetworkService sharedService]startRequest:post];
    ```

## 链式编程

```
SCNJSONResponseParser *responseParser = [SCNJSONResponseParser parser];
///框架会检查接口返回的 code 是不是 0 ，如果不是 0 ，那么返回给你一个err，并且result是 nil;
responseParser.checkKeyPath = @"code";
responseParser.okValue = @"0";
    
///support chain
    
SCNetworkRequest *req = [[SCNetworkRequest alloc]init];
    
req.c_URL(@"http://debugly.cn/dist/json/test.json")
   .c_ResponseParser(responseParser);
   .c_CompletionHandler(^(SCNetworkRequest *request, id result, NSError *err) {
        
            if (completion) {
                completion(result);
            }
       });
[[SCNetworkService sharedService]sendRequest:req];
```


## 架构设计

- 综合参考了 MKNetwork2.0 和 AFNetwork 2.0 的设计，吸取了他们的精华，去掉了冗余的设计，融入了自己的想法，将网络请求抽象为 Request 对象，并由 Service 管理，Service 为 Request 分配代理对象 --- 处理传输数据、请求结束，请求失败等事件，请求结束后通过改变 Rquest 的 state 属性，告知 Request 请求结束，然后根据配置的响应解析器，异步解析数据，结果可能是 data, string, json, model, image 等等；最终通过我们添加到 Request 对象上的 completionBlock 回调给调用层。

设计图:

<img src="http://debugly.cn/images/SCNetworkKit/SCNetworkKit.png">

## 采用注册的方式解耦和

功能强大的同时要顾及到扩展性，本框架支持很多扩展，以响应解析为例，你可以继续创建你想要的解析器；可以使用你喜欢的 JOSN 转 Model 框架来做解析；可以让网络库解析更多格式的图片；这些都是可以做到的，并且还很简单。

- 由于框架配备了支持 JSON 转 Model 的 SCNModelResponseParser 响应解析器，那么就不得不依赖于 JSON 转 Model 的框架，考虑到项目中很可能已经有了这样的框架，因此并没有将这块逻辑写死，而是采用注册的方式，来扩展 SCN 的能力！所以使用 Model 解析器之前必须注册 一个用于将 JOSN 转为 Model 的类，该类实现 SCNModelParserProtocol 协议！为了方便，最好是在APP启动后就注册，或者创建 Service 的时候创建，以免使用的时候还没注册，导致崩溃！

    ```objc
    @protocol SCNModelParserProtocol <NSObject>
    
    @required;
    + (id)fetchSubJSON:(id)json keyPath:(NSString *)keypath;
    + (id)JSON2Model:(id)json modelName:(NSString *)mName;
    
    @end
    
    @interface SCNModelResponseParser : SCNJSONResponseParser
    
    @property (nonatomic,copy) NSString *modelName;
    @property (nonatomic,copy) NSString *modelKeyPath;
    
    + (void)registerModelParser:(Class<SCNModelParserProtocol>)parser;
    
    @end
    
    ```

我在 demo 里面使用的是我的另外一个轮子：[SCJSONUtil](https://github.com/debugly/SCJSONUtil) ；具体实现可查看demo。


- 图片解析器默认支持 png、jpg 图片格式，当下 webp 格式由于体积更小，很多厂商开始使用，我的 SDK 里也用到了这个格式，因此我在 SDK 里注册了解析 webp 的解析类；

    ```objc
    @protocol SCNImageParserProtocol <NSObject>
    
    @required;
    + (UIImage *)imageWithData:(NSData *)data scale:(CGFloat)scale;
    
    @end
    
    ///默认支持png 和 jpg；可通过注册的方式扩展！
    @interface SCNImageResponseParser : SCNHTTPResponseParser
    
    
    /**
     注册新的图片解析器和对应的类型
    
     @param parser 解析器
     @param mime 支持的类型
     */
    + (void)registerParser:(Class<SCNImageParserProtocol>)parser forMime:(NSString *)mime;
    
    @end
    
    ```

这种注册器的方式优雅地扩充了网络库的功能，就好比插件一样，插上就能用，只需要规格上符合我协议里规定的要求即可！反之，如果你不需要解析 webp， 你不需要 json 转 model 的话，你就没必要去插对应的模块！

如果没有注册器这么一个好的实践的话，要达到同样的扩展效果可能就很难了！如果你有别的点子请联系我。

## SCNetworkService

由上图可知，SCNetworkService 主要起到了发起网络请求，处理好 Request，task，delegate 对象的一一对应关系的作用！

- 为了方便使用，还提供了可用于整个 App 的共享 SCNetworkService 对象，用来发送普通的网络请求；当然你有必要为不同的业务创建不同的 Service；一个 Service 内部则对应了一个 NSURLSession 对象！

## SCNetworkRequest

NSURLSession 管理的网络请求结束后，会在 SCNetworkRequest 里处理响应数据，根据配置的 ResponseParser 去异步解析，最终在主线程里安全着陆；

- SCNetworkRequest 从 start 开始被 Service 持有，直到着陆后 Service 不再持有，因此上层可以不持有 SCNetworkRequest 对象！如果要拥有 SCNetworkRequest 对象的指针，一般使用 weak 即可；

- SCNetworkRequest 支持添加多个回调，回调顺序跟添加的顺序一样；
- 注意添加回调的时候，不要让 SCNetworkRequest 持有你的对象，否则 SCNetworkRequest 会一直持有，直到着陆，虽然不会导致循环引用导致的内存泄漏，但是却“延长”了被持有对象的生命周期；

## SCNetworkPostRequest

继承了 SCNetworkRequest，专门用于发送 POST 请求，支持四种编码方式:

- SCNPostDataEncodingURL : application/x-www-form-urlencoded;
- SCNPostDataEncodingJSON : application/json;
- SCNPostDataEncodingPlist : application/x-plist;
- SCNPostDataEncodingFormData : multipart/form-data;

只有使用 SCNPostDataEncodingFormData 方式的请求会采用 HTTPBodyStream ！

## 版本

- 1.0.5 : 支持 stream HTTPBody，轻松搞定大文件上传
- 1.0.6 : 支持一次上传多个文件，配套 Node 上传文件服务器
- 1.0.7 : 修复直接使用二进制上传失败问题（重复计算长度，导致Content Length计算偏大）
- 1.0.8 : 支持 macOS 平台 (暂不支持图片解析)
- 1.0.9 :  整理目录，POST 请求可添加 Query 参数
- 1.0.10 : 修改默认 UA 格式
- 1.0.11 : 抽取解析过程，可完全自定义；支持 JSONUtil 的动态映射
- 1.0.12 : 解除并发数为 2 的限制，使用系统配置
- 1.0.13 : 支持自定义请求body体
- 1.0.14 : 修改默认UA
- 1.0.15 : 下载文件支持断点续传
- 1.0.16 : 将下载逻辑抽取为单独的类
- 1.0.17 : 移除自动取消支持，这一功能抽取为了单独的 [MRDeallocSubscriber](https://github.com/debugly/MRDeallocSubscriber) 模块，可通过block形式完成，使得网络库更加纯粹

## 完

由于该网络库是完全为自己业务服务的，因此不是所以的功能均支持，而是用到时再加，所以如果你使用了 SCNetworkKit ，发现功能缺失，可以提交 PR 或者联系我增加缺失的功能！