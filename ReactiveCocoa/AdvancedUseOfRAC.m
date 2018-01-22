//
//  AdvancedUseOfRAC.m
//  ReactiveCocoa
//
//  Created by 祁子栋 on 2018/1/19.
//  Copyright © 2018年 祁子栋. All rights reserved.
//

#import "AdvancedUseOfRAC.h"
#import "GlobeHeader.h"
#import "RACReturnSignal.h"

@interface AdvancedUseOfRAC ()
@property (weak, nonatomic) IBOutlet UITextField *accountFiled;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation AdvancedUseOfRAC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self bind];
}

-(void)bind{
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.绑定信号
    RACSignal *bindSignal = [subject bind:^RACSignalBindBlock _Nonnull{
        // block调用时刻:只要绑定信号被订阅就会调用
        
        
        return ^RACSignal *(id value, BOOL *stop){
            // block调用:只要源信号发送数据,就会调用block
            // block作用:处理源信号内容
            // value:源信号发送的内容
            
            NSLog(@"接收到原信号的内容:%@",value);
            
            value = [NSString stringWithFormat:@"绑定处理:%@",value];
            // 返回信号,不能传nil,返回空信号使用[RACSignal empty]
            return [RACReturnSignal return:value];
        };
    }];
    
    // 3.订阅绑定信号
    [bindSignal subscribeNext:^(id x) {
        // blcok:当处理完信号发送数据的时候,就会调用这个Block
        NSLog(@"接收到绑定信号处理完的信号%@",x);
    }];
    
    // 4.发送数据
    [subject sendNext:@"123"];
}

- (void)signalOfsignals {
    // flattenMap:用于信号中信号
    
    RACSubject *signalOfsignals = [RACSubject subject];
    
    RACSubject *signal = [RACSubject subject];
    
    // 订阅信号
    //    [signalOfsignals subscribeNext:^(RACSignal *x) {
    //
    //        [x subscribeNext:^(id x) {
    //            NSLog(@"%@",x);
    //        }];
    //
    //    }];
    
    //    RACSignal *bindSignal = [signalOfsignals flattenMap:^RACStream *(id value) {
    //        // value:源信号发送内容
    //        return value;
    //    }];
    //
    //    [bindSignal subscribeNext:^(id x) {
    //
    //        NSLog(@"%@",x);
    //    }];
    [[signalOfsignals flattenMap:^RACSignal *(id value) {
        return value;
        
    }] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
        
    }];
    
    // 发送信号
    [signalOfsignals sendNext:signal];
    [signal sendNext:@"213"];
}

- (void)map
{
    // @"123"
    // @"aaaaa:123"
    
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 绑定信号
    RACSignal *bindSignal = [subject map:^id(id value) {
        // 返回的类型,就是你需要映射的值
        return [NSString stringWithFormat:@"aaaaa:%@",value];
        
    }];
    
    // 订阅绑定信号
    [bindSignal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"123"];
    [subject sendNext:@"321"];
}

- (void)flattenMap
{
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 绑定信号
    RACSignal *bindSignal = [subject flattenMap:^RACSignal *(id value) {
        // block:只要源信号发送内容就会调用
        // value:就是源信号发送内容
        
        value = [NSString stringWithFormat:@"aaaaa:%@",value];
        
        // 返回信号用来包装成修改内容值
        return [RACReturnSignal return:value];
        
    }];
    
    // flattenMap中返回的是什么信号,订阅的就是什么信号
    
    // 订阅信号
    [bindSignal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    
    // 发送数据
    [subject sendNext:@"123"];
}

- (void)reduce {
    // 组合
    // 组合哪些信号
    // reduce:聚合
    
    // reduceBlock参数:根组合的信号有关,一一对应
    RACSignal *comineSiganl = [RACSignal combineLatest:@[_accountFiled.rac_textSignal,_pwdField.rac_textSignal] reduce:^id(NSString *account,NSString *pwd){
        // block:只要源信号发送内容就会调用,组合成新一个值
        NSLog(@"%@ %@",account,pwd);
        // 聚合的值就是组合信号的内容
        
        return @(account.length && pwd.length);
    }];
    
    // 订阅组合信号
    //    [comineSiganl subscribeNext:^(id x) {
    //        _loginBtn.enabled = [x boolValue];
    //    }];
    
    RAC(_loginBtn,enabled) = comineSiganl;
    
}

- (void)zip
{
    // zipWith:夫妻关系
    // 创建信号A
    RACSubject *signalA = [RACSubject subject];
    
    // 创建信号B
    RACSubject *signalB = [RACSubject subject];
    
    // 压缩成一个信号
    // zipWith:当一个界面多个请求的时候,要等所有请求完成才能更新UI
    // zipWith:等所有信号都发送内容的时候才会调用
    RACSignal *zipSignal = [signalA zipWith:signalB];
    
    // 订阅信号
    [zipSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 发送信号
    [signalB sendNext:@2];
    [signalA sendNext:@1];
    
}

// 任意一个信号请求完成都会订阅到
- (void)merge
{
    // 创建信号A
    RACSubject *signalA = [RACSubject subject];
    
    // 创建信号B
    RACSubject *signalB = [RACSubject subject];
    
    // 组合信号
    RACSignal *mergeSiganl = [signalA merge:signalB];
    
    // 订阅信号
    [mergeSiganl subscribeNext:^(id x) {
        // 任意一个信号发送内容都会来这个block
        NSLog(@"%@",x);
    }];
    
    // 发送数据
    [signalB sendNext:@"下部分"];
    [signalA sendNext:@"上部分"];
}

- (void)then
{
    // 创建信号A
    RACSignal *siganlA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"发送上部分请求");
        // 发送信号
        [subscriber sendNext:@"上部分数据"];
        
        // 发送完成
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    // 创建信号B
    RACSignal *siganlB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"发送下部分请求");
        // 发送信号
        [subscriber sendNext:@"下部分数据"];
        
        return nil;
    }];
    
    // 创建组合信号
    // then:忽悠掉第一个信号所有值
    RACSignal *thenSiganl = [siganlA then:^RACSignal *{
        // 返回信号就是需要组合的信号
        return siganlB;
    }];
    
    // 订阅信号
    [thenSiganl subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
}

- (void)concat
{
    // concat底层实现:
    // 1.当拼接信号被订阅，就会调用拼接信号的didSubscribe
    // 2.didSubscribe中，会先订阅第一个源信号（signalA）
    // 3.会执行第一个源信号（signalA）的didSubscribe
    // 4.第一个源信号（signalA）didSubscribe中发送值，就会调用第一个源信号（signalA）订阅者的nextBlock,通过拼接信号的订阅者把值发送出来.
    // 5.第一个源信号（signalA）didSubscribe中发送完成，就会调用第一个源信号（signalA）订阅者的completedBlock,订阅第二个源信号（signalB）这时候才激活（signalB）。
    // 6.订阅第二个源信号（signalB）,执行第二个源信号（signalB）的didSubscribe
    // 7.第二个源信号（signalA）didSubscribe中发送值,就会通过拼接信号的订阅者把值发送出来.
    // 组合
    // concat:皇上,皇太子
    // 创建信号A
    RACSignal *siganlA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"发送上部分请求");
        // 发送信号
        [subscriber sendNext:@"上部分数据"];
        
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    RACSignal *siganlB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"发送下部分请求");
        // 发送信号
        [subscriber sendNext:@"下部分数据"];
        
        return nil;
    }];
    
    // concat:按顺序去连接
    // 注意:concat,第一个信号必须要调用sendCompleted
    // 创建组合信号
    RACSignal *concatSignal = [siganlA concat:siganlB];
    
    // 订阅组合信号
    [concatSignal subscribeNext:^(id x) {
        
        // 既能拿到A信号的值,又能拿到B信号的值
        NSLog(@"%@",x);
        
    }];
    
}


- (void)skip {
    // Do any additional setup after loading the view, typically from a nib.
    
    // skip;跳跃几个值
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    [[subject skip:2] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"1"];
    [subject sendNext:@"2"];
    [subject sendNext:@"3"];
    
}

- (void)distinctUntilChanged
{
    // distinctUntilChanged:如果当前的值跟上一个值相同,就不会被订阅到
    
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    [[subject distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"%@",x);// 1 2
    }];
    
    [subject sendNext:@"1"];
    [subject sendNext:@"2"];
    [subject sendNext:@"2"];
}

- (void)take
{
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    RACSubject *signal = [RACSubject subject];
    
    // take:取前面几个值
    // takeLast:取后面多少个值.必须要发送完成
    // takeUntil:只要传入信号发送完成或者发送任意数据,就不能在接收源信号的内容
    [[subject take:1] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    [[subject takeLast:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    [[subject takeUntil:signal] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"1"];
    
    [signal sendNext:@1];
    //    [signal sendCompleted];
    [signal sendError:nil];
    
    [subject sendNext:@"2"];
    [subject sendNext:@"3"];
    [signal sendCompleted];
}

- (void)ignore
{
    
    // ignore:忽略一些值
    // ignoreValues:忽略所有的值
    
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.忽略一些
    RACSignal *ignoreSignal = [subject ignoreValues];
    RACSignal *ignoreSignals = [subject ignore:@"13"];
    
    // 3.订阅信号
    [ignoreSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [ignoreSignals subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    // 4.发送数据
    [subject sendNext:@"13"];
    [subject sendNext:@"2"];
    [subject sendNext:@"44"];
    
}
- (void)filter
{
    // 只有当我们文本框的内容长度大于5,才想要获取文本框的内容
    [[self.accountFiled.rac_textSignal filter:^BOOL(id value) {
        // value:源信号的内容
        return  [value length] > 5;
        // 返回值,就是过滤条件,只有满足这个条件,才能能获取到内容
        
    }] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
}

@end
