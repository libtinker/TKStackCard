# TKStackCard



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
