//
//  KVOViewController.m
//  iOSQuestion
//
//  Created by zhangshumeng on 2020/8/29.
//  Copyright © 2020 zhangshumeng. All rights reserved.
//

#import "KVOViewController.h"
#import "Person.h"
#import <objc/runtime.h>

//观察者ObserverPersonChage
@interface ObserverPersonChange : NSObject

@end

@implementation ObserverPersonChange

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@", keyPath);
    if ([keyPath isEqualToString:@"age"]) {
        NSLog(@"age %@", object);
    }
    if ([keyPath isEqualToString:@"name"]) {
        NSLog(@"name %@", object);
    }
}

@end

@interface KVOViewController ()

@property (nonatomic, strong) Person *person;
@property (nonatomic, strong) ObserverPersonChange *observerPerson;

@end

@implementation KVOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"KVO";
    
    self.person = [Person new];
    self.observerPerson = [ObserverPersonChange new];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:(CGRectMake(20, 100, 100, 30))];;
    [btn1 setTintColor:[UIColor blackColor]];
    btn1.backgroundColor = [UIColor greenColor];
    [btn1 setTitle:@"注册观察者" forState:(UIControlStateNormal)];
    [btn1 addTarget:self action:@selector(btn1Click) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:(CGRectMake(20, 150, 100, 30))];;
    [btn2 setTintColor:[UIColor blackColor]];
    btn2.backgroundColor = [UIColor redColor];
    [btn2 setTitle:@"移除观察者" forState:(UIControlStateNormal)];
    [btn2 addTarget:self action:@selector(btn2Click) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btn2];
    
    UIButton *btn3 = [[UIButton alloc] initWithFrame:(CGRectMake(20, 200, 100, 30))];;
    [btn3 setTintColor:[UIColor blackColor]];
    btn3.backgroundColor = [UIColor orangeColor];
    [btn3 setTitle:@"改变属性值" forState:(UIControlStateNormal)];
    [btn3 addTarget:self action:@selector(btn3Click) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btn3];
    
}

- (void)dealloc {
    NSLog(@"dealloc");
}

- (void)btn1Click {
    
    NSLog(@"person添加KVO监听对象之前-类对象 -%@", object_getClass(self.person));
    NSLog(@"person添加KVO监听之前-方法实现 -%p", [self.person methodForSelector:@selector(setAge:)]);
    NSLog(@"person添加KVO监听之前-元类对象 -%@", object_getClass(object_getClass(self.person)));
    
    
    [self.person addObserver:self.observerPerson forKeyPath:@"age" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:@"age change"];
    [self.person addObserver:self.observerPerson forKeyPath:@"name" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:@"name change"];
    
    NSLog(@"person添加KVO监听对象之后-类对象 -%@", object_getClass(self.person));
    NSLog(@"person添加KVO监听之后-方法实现 -%p", [self.person methodForSelector:@selector(setAge:)]);
    NSLog(@"person添加KVO监听之后-元类对象 -%@", object_getClass(object_getClass(self.person)));
    
}

- (void)btn2Click {
    [self.person removeObserver:self.observerPerson forKeyPath:@"age"];
    [self.person removeObserver:self.observerPerson forKeyPath:@"name"];
//    self.observerPerson = nil;
}

- (void)btn3Click {
    self.person.age = 10;
    self.person.name = @"小明";
}



@end
