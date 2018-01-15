//
//  ViewController.m
//  ReactiveCocoa
//
//  Created by 祁子栋 on 2018/1/9.
//  Copyright © 2018年 祁子栋. All rights reserved.
//

#import "ViewController.h"
#import "GlobeHeader.h"
#import "RedView.h"
#import "Flag.h"
#import "NSObject+RACKVOWrapper.h"

@interface ViewController ()

@property (nonatomic, strong) UITextField *textF;
@property (nonatomic, strong) UIButton *btn;
@property (weak, nonatomic) IBOutlet RedView *redView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 订阅信号
    [_redView.btnClickSignal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
//    [self dicToModal];
    
    // 2.代替KVO
//        [_redView rac_observeKeyPath:@"frame" options:NSKeyValueObservingOptionNew observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
//            //
//
//        }];
    //注意这个方法默认是没有导入综合的头文件中，需要另外导入#import "NSObject+RACKVOWrapper.h"
//    [_redView rac_observeKeyPath:@"frame" options:NSKeyValueObservingOptionNew observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
//        //
//
//    }];
    
//    [[_redView rac_valuesForKeyPath:@"frame" observer:nil] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@",x);//结果：NSRect: {{0, 233.5}, {375, 200}}
//    }];
    
        [[_redView rac_valuesForKeyPath:@"frame" observer:nil] subscribeNext:^(id x) {
          // x:修改的值
            NSLog(@"%@",x);
        }];
    
        [_redView rac_observeKeyPath:@"bounds" options:NSKeyValueObservingOptionNew observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
            //
    
        }];
    
    
    
//     3.监听点击事件
    
        [[_btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            NSLog(@"按钮点击了");
        }];
    
    
    // 4.代替通知
    
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
    
            NSLog(@"%@",x);
        }];
    
    // 5.监听文本框
    [_textF.rac_textSignal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    
    
    
}

- (void)delegate
{
    // 1.代替代理:1.RACSubject 2.rac_signalForSelector
    // 只要传值,就必须使用RACSubject
    [[_redView rac_signalForSelector:@selector(btnClick:)] subscribeNext:^(id x) {
        NSLog(@"控制器知道按钮被点击");
    }];
    
    // RAC:
    // 把控制器调用didReceiveMemoryWarning转换成信号
    // rac_signalForSelector:监听某对象有没有调用某方法
        [[self rac_signalForSelector:@selector(didReceiveMemoryWarning)] subscribeNext:^(id x) {
            NSLog(@"控制器调用didReceiveMemoryWarning");
        }];
}

- (void) dicToModal{
    // 解析plist文件
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
    NSArray *dictArr = [NSArray arrayWithContentsOfFile:filePath];
    
    NSMutableArray *arr = [NSMutableArray array];
    [dictArr.rac_sequence.signal subscribeNext:^(NSDictionary *x) {
        Flag *flag = [Flag flagWithDict:x];//内部还是KVC
        [arr addObject:flag];
        
    }];
    NSLog(@"%@",arr);
    // 高级用法
    // 会把集合中所有元素都映射成一个新的对象
    NSArray *arr1 = [[dictArr.rac_sequence map:^id(NSDictionary *value) {
        // value:集合中元素
        // id:返回对象就是映射的值
        return [Flag flagWithDict:value];
    }] array];
    
    NSLog(@"%@",arr1);
    
}

- (void)dict
{
    
    // 字典
    NSDictionary *dict = @{@"account":@"aaa",@"name":@"xmg",@"age":@18};
    
    // 转换成集合
    [dict.rac_sequence.signal subscribeNext:^(RACTuple *x) {
        //       NSString *key = x[0];
        //        NSString *value = x[1];
        //        NSLog(@"%@ %@",key,value);
        
        // RACTupleUnpack:用来解析元组
        // 宏里面的参数,传需要解析出来的变量名
        // = 右边,放需要解析的元组
        RACTupleUnpack(NSString *key1,NSString *value) = x;
        
        NSLog(@"%@ %@",key1,value);
    }];
}

- (void)arr
{
    // 数组
    NSArray *arr = @[@"213",@"321",@1];
    
     //RAC集合
        RACSequence *sequence = arr.rac_sequence;
    
        // 把集合转换成信号
        RACSignal *signal = sequence.signal;
    
        // 订阅集合信号,内部会自动遍历所有的元素发出来
        [signal subscribeNext:^(id x) {
            NSLog(@"%@",x);
        }];
    //上面几步合起来就是
    [arr.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

- (void)tuple
{
    // 元组
    RACTuple *tuple = [RACTuple tupleWithObjectsFromArray:@[@"213",@"321",@1]];
    NSString *str = tuple[0];
    
    NSLog(@"%@",str);
    
}

- (void)RACReplaySubject
{
    // 1.创建信号
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    // 遍历所有的值,拿到当前订阅者去发送数据
    
    // 3.发送信号
    [subject sendNext:@1];
    //    [subject sendNext:@1];
    // RACReplaySubject发送数据:
    // 1.保存值
    // 2.遍历所有的订阅者,发送数据
    
    
    // RACReplaySubject:可以先发送信号,在订阅信号
}


- (void)RACSubject
{
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.订阅信号
    
    // 不同信号订阅的方式不一样
    // RACSubject处理订阅:仅仅是保存订阅者
    [subject subscribeNext:^(id x) {
        NSLog(@"订阅者一接收到数据:%@",x);
    }];
    
    // 3.发送数据
    [subject sendNext:@1];
    
    //    [subject subscribeNext:^(id x) {
    //        NSLog(@"订阅二接收到数据:%@",x);
    //    }];
    // 保存订阅者
    
    
    // 底层实现:遍历所有的订阅者,调用nextBlock
    
    // 执行流程:
    // 创建信号，并且创建了一个数组用于保存订阅者
    // RACSubject被订阅,仅仅是保存订阅者
    // RACSubject发送数据,遍历所有的订阅,调用他们的nextBlock
}


- (void)signal {
    // Do any additional setup after loading the view, typically from a nib.
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber ) {
        
        //        _subscriber = subscriber;// 将订阅者设为一个全局的属性，一直持有存在就需要手动取消订阅@property (nonatomic, strong) id<RACSubscriber> subscriber;
        
        // 3.发送信号
        [subscriber sendNext:@"123"];
        
        return [RACDisposable disposableWithBlock:^{
            // 只要信号取消订阅就会来这
            // 清空资源
            NSLog(@"信号被取消订阅了");
        }];
    }];

    // 2.订阅信号
    RACDisposable *disposable = [signal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
        
    }];
    // 1.创建订阅者,保存nextBlock
    // 2.订阅信号

    // 默认一个信号发送数据完毕们就会主动取消订阅.
    // 只要订阅者在,就不会自动取消信号订阅
    // 取消订阅信号
    [disposable dispose];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
