//
//  TKViewController.m
//  TKStackCard
//
//  Created by 郑俊杰 on 01/22/2025.
//  Copyright (c) 2025 郑俊杰. All rights reserved.
//

#import "TKViewController.h"
#import <TKStackCardView.h>

@interface Item : NSObject
@property(nonatomic, copy) NSString *name;
@property(nonatomic, strong) UIColor *color;

@end

@implementation Item

- (instancetype)initWithName:(NSString *)name color:(UIColor *)color {
    self = [super init];
    if (self) {
        _name = name;
        _color = color;
    }
    return self;
}

+ (NSArray *)getDatas {
    return @[
        [[Item alloc] initWithName:@"0" color:[self randomColor]],
        [[Item alloc] initWithName:@"1" color:[self randomColor]],
        [[Item alloc] initWithName:@"2" color:[self randomColor]],
        [[Item alloc] initWithName:@"3" color:[self randomColor]],
        [[Item alloc] initWithName:@"4" color:[self randomColor]],
        [[Item alloc] initWithName:@"5" color:[self randomColor]],
        [[Item alloc] initWithName:@"6" color:[self randomColor]],
        [[Item alloc] initWithName:@"7" color:[self randomColor]],
        [[Item alloc] initWithName:@"8" color:[self randomColor]],
        [[Item alloc] initWithName:@"9" color:[self randomColor]],
        [[Item alloc] initWithName:@"10" color:[self randomColor]]

    ];
}

// 随机颜色生成器
+ (UIColor *)randomColor {
    return [UIColor colorWithRed:arc4random_uniform(256) / 255.0
                           green:arc4random_uniform(256) / 255.0
                            blue:arc4random_uniform(256) / 255.0
                           alpha:1.0];
}

@end


@interface TKViewController ()<StackCardViewDataSource, StackCardViewDelegate>
@property(nonatomic, strong) NSArray *dataArray;
@property(nonatomic, strong) TKStackCardView *stackCardView;
@end

@implementation TKViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    _dataArray = [Item getDatas];

    _stackCardView = [[TKStackCardView alloc]
        initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40,
                                 172)];
    _stackCardView.dataSource = self;
    _stackCardView.delegate = self;
    [_stackCardView reloadData];
    [self.view addSubview:_stackCardView];


    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(100, 400, 150, 50);
    button.backgroundColor = [UIColor systemBlueColor];
    [button setTitle:@"点击我滚动到第5页" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 10.0;
    button.clipsToBounds = YES;
    [button addTarget:self
                  action:@selector(buttonTapped:)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}



- (void)buttonTapped:(UIButton *)button {
    [self.stackCardView scrollToIndex:5 animated:YES];
}

//MARK: - StackCardViewDataSource

- (void)stackCardView:(TKStackCardView *)stackCardView configureCell:(TKStackCardCell *)cell forIndex:(NSInteger)index {
    if (cell.contentView == nil) {
        //在这里自定义视图
        UILabel *contentView =  [[UILabel alloc] initWithFrame:cell.bounds];
        contentView.font = [UIFont systemFontOfSize:50];
        contentView.textAlignment = NSTextAlignmentCenter;
        cell.contentView = contentView;
    }
    UILabel *label = (UILabel *)cell.contentView;
    Item *item = _dataArray[index];
    label.backgroundColor = item.color;
    label.text = item.name;
}

- (NSInteger)numberOfStacksInStackCardView:(TKStackCardView *)stackCardView {
    return 3;
}

- (NSInteger)numberOfItemsInStackCardView:(TKStackCardView *)stackCardView {
    return _dataArray.count;

}

//MARK: - StackCardViewDelegate

- (void)stackCardView:(TKStackCardView *)stackCardView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"点击了第%ld个视图",(long)index);
}

- (BOOL)stackCardViewCanSlide:(TKStackCardView *)stackCardView {
    return _dataArray.count>1;
}

- (void)stackCardView:(TKStackCardView *)stackCardView didEndScrollingToIndex:(NSInteger)index {
    NSLog(@"滚动到了第%ld个视图",(long)index);

}

@end
