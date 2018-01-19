//
//  SecViewController.m
//  ReactiveCocoa
//
//  Created by 祁子栋 on 2018/1/19.
//  Copyright © 2018年 祁子栋. All rights reserved.
//

#import "SecViewController.h"
#import "GlobeHeader.h"

@interface SecViewController ()

@end

@implementation SecViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 每次订阅不要都请求一次,只想请求一次,每次订阅只要拿到数据
    
    // 不管订阅多少次信号,就会请求一次
    // RACMulticastConnection:必须要有信号
    
    // 1.创建信号
    // 2.把信号转换成连接类
    // 3.订阅连接类的信号
    // 4.连接
    
    
    [self command1];
    
}
- (void)subject
{
    RACSubject *subject = [RACSubject subject];
    
    [subject subscribeNext:^(id x) {
        
        NSLog(@"1:%@",x);
        
    }];
    [subject subscribeNext:^(id x) {
        
        NSLog(@"2:%@",x);
        
    }];
    
    [subject sendNext:@1];
}

- (void)connect1
{
    
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // didSubscribe什么时候来:连接类连接的时候
        NSLog(@"发送热门模块的请求");
        [subscriber sendNext:@"热门模块的数据"];
        
        return nil;
    }];
    // 2.把信号转换成连接类
    // 确定源信号的订阅者RACSubject
    RACMulticastConnection *connection = [signal publish];
    RACMulticastConnection *connection1 = [signal multicast:[RACReplaySubject subject]];
    
    // 3.订阅连接类信号
    [connection.signal subscribeNext:^(id x) {
        
        // nextBlock:发送数据就会来
        NSLog(@"订阅者1:%@",x);
        
    }];
    
    [connection.signal subscribeNext:^(id x) {
        
        // nextBlock:发送数据就会来
        NSLog(@"订阅者2:%@",x);
        
    }];
    
    // 4.连接
    [connection connect];
    
}

- (void)requestBug
{
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"发送热门模块的请求");
        
        // 3.发送数据
        [subscriber sendNext:@1];
        
        return nil;
    }];
    
    // 2.订阅信号
    [signal subscribeNext:^(id x) {
        NSLog(@"订阅者一%@",x);
    }];
    
    [signal subscribeNext:^(id x) {
        
        NSLog(@"订阅者二%@",x);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)command1 {
    // Do any additional setup after loading the view, typically from a nib.
    
    // 当前命令内部发送数据完成,一定要主动发送完成
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        // input:执行命令传入参数
        // Block调用:执行命令的时候就会调用
        NSLog(@"%@",input);
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            // 发送数据
            [subscriber sendNext:@"执行命令产生的数据"];
            
            // 发送完成
            [subscriber sendCompleted];
            
            return nil;
        }];
    }];
    
    // 监听事件有没有完成
    [command.executing subscribeNext:^(id x) {
        if ([x boolValue] == YES) { // 当前正在执行
            NSLog(@"当前正在执行");
        }else{
            // 执行完成/没有执行
            NSLog(@"执行完成/没有执行");
        }
    }];
    
    
    // 2.执行命令
    [command execute:@1];
    

}


- (void)switchToLatest
{
    
    // 创建信号中信号
    RACSubject *signalOfSignals = [RACSubject subject];
    RACSubject *signalA = [RACSubject subject];
    RACSubject *signalB = [RACSubject subject];
    
    // 订阅信号
    //    [signalOfSignals subscribeNext:^(RACSignal *x) {
    //        [x subscribeNext:^(id x) {
    //            NSLog(@"%@",x);
    //        }];
    //    }];
    // switchToLatest:获取信号中信号发送的最新信号
    [signalOfSignals.switchToLatest subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    // 发送信号
    [signalOfSignals sendNext:signalA];
    
    [signalA sendNext:@1];
    [signalB sendNext:@"BB"];
    [signalA sendNext:@"11"];
}

- (void)executionSignals
{
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        // input:执行命令传入参数
        // Block调用:执行命令的时候就会调用
        NSLog(@"%@",input);
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            // 发送数据
            [subscriber sendNext:@"执行命令产生的数据"];
            
            return nil;
        }];
    }];
    
    // 订阅信号
    // 注意:必须要在执行命令前,订阅
    // executionSignals:信号源,信号中信号,signalOfSignals:信号:发送数据就是信号
    //    [command.executionSignals subscribeNext:^(RACSignal *x) {
    //
    //        [x subscribeNext:^(id x) {
    //            NSLog(@"%@",x);
    //        }];
    //
    //    }];
    
    // switchToLatest获取最新发送的信号,只能用于信号中信号
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 2.执行命令
    [command execute:@1];
}
- (void)command
{
    // RACCommand:处理事件
    // RACCommand:不能返回一个空的信号
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        // input:执行命令传入参数
        // Block调用:执行命令的时候就会调用
        NSLog(@"%@",input);
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            // 发送数据
            [subscriber sendNext:@"执行命令产生的数据"];
            
            return nil;
        }];
    }];
    
    // 如何拿到执行命令中产生的数据
    // 订阅命令内部的信号
    // 1.方式一:直接订阅执行命令返回的信号
    // 2.方式二:
    
    // 2.执行命令
    RACSignal *signal = [command execute:@1];
    
    // 3.订阅信号
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
}

@end
