# TKStackCard
TKStackCard 是一个支持卡片叠层效果的自定义 UI 组件，用于展示多个卡片视图，并提供滑动切换、层叠动画和交互事件等功能。它适合在 App 中实现类似堆叠式卡片浏览或内容筛选的效果，常见于图片浏览、商品推荐、任务管理等场景。
![a](https://github.com/user-attachments/assets/a415cd0b-7421-4957-8fd7-9213f3243ca2)

主要特点
```
1.	多层卡片堆叠：
•	支持设置卡片之间的 x 和 y 轴的堆叠间距，呈现层次感。
•	动态控制卡片的层数，模拟真实的叠加效果。
2.	滑动切换效果：
•	支持卡片左右滑动切换。
•	可通过手势滑动翻页，同时支持跳转到指定卡片。
3.	自定义动画：
•	支持动画过渡，带有弹簧效果，滑动过程流畅自然。
•	可调整卡片的缩放比例、透明度等，增强动态交互体验。
4.	高扩展性：
•	提供 Delegate 和 DataSource 协议，便于自定义卡片内容和交互逻辑。
•	支持自定义卡片的布局和样式。
5.	轻量级设计：
•	高度模块化，简单易用，适合嵌入各种复杂项目。
6.	灵活控制：
•	可动态刷新数据，调整堆叠效果，甚至根据需求禁用滑动功能。
```

## Example

1、初始化视图
```
    _stackCardView = [[TKStackCardView alloc]
        initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40,
                                 172)];
    _stackCardView.dataSource = self;
    _stackCardView.delegate = self;
    [_stackCardView reloadData];
    [self.view addSubview:_stackCardView];
```
2、实现代理
、、、
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
、、、
## Requirements

## Installation

TKStackCard is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TKStackCard'
```

## Author

libtinker, 2028002516@qq.com

## License

TKStackCard is available under the MIT license. See the LICENSE file for more info.
