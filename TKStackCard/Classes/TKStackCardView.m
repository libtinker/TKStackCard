#import "TKStackCardView.h"

@interface TKStackCardView () <UIGestureRecognizerDelegate> {
    NSMutableArray<UIView *> *_cacheViews; // 存储卡片视图，至少2个
    BOOL _toRightSwipe;                    // 是否向右滑动
    BOOL _canSlide;             // 是否可以滑动（默认是可以的）
    NSInteger _stackCount;      // 叠层数量（默认为1）
    NSInteger _dataSourceCount; // 数据实际数量
}
@property(nonatomic, assign) NSInteger currentIndex; // 当前的下标

@end

@implementation TKStackCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self setupUI];
    }
    return self;
}

- (void)initData {
    _cacheViews = [[NSMutableArray alloc] init];
    _currentIndex = 0;
    _canSlide = YES;
    // 滑动翻页的距离应该是卡片宽度的 20%~40% 左右
    _slidingDistance = ceil(self.frame.size.width * 0.3);
    _stackCount = 1;
    _dataSourceCount = 0;
    _stackDistanceX = 17;
    _stackDistanceY = 5;
    _cornerRadiusMax = 10;
    _cornerRadiusMin = 8;
}

- (void)setupUI {
    self.clipsToBounds = YES;
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    [_cacheViews removeAllObjects];
    NSInteger viewCount = _stackCount + 1; // 多创建一个用于滑动的视图
    for (NSInteger i = 0; i < viewCount; i++) {
        TKStackCardCell *cell =
            [[TKStackCardCell alloc] initWithFrame:CGRectZero];
        cell.layer.cornerRadius = 10.0;
        cell.clipsToBounds = YES;
        cell.frame = [self getFrameWithIndex:i];
        cell.layer.cornerRadius = [self getCornerRadius:i];
        cell.backgroundColor = [UIColor whiteColor];
        [self insertSubview:cell atIndex:0];
        [_cacheViews addObject:cell];

        if (i == 0) {
            [self.dataSource stackCardView:self
                             configureCell:cell
                                  forIndex:_dataSourceCount - 1];
        } else {
            NSInteger index = i - 1;
            index = index % [self.dataSource numberOfItemsInStackCardView:self];
            [self.dataSource stackCardView:self
                             configureCell:cell
                                  forIndex:index];
        }
        // 给顶部卡片添加拖拽手势
        if (i == 1) {
            [self addPanGestureToView:cell];
        }
    }
}

// 单击手势
- (void)tapGestureClicked {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(stackCardView:
                                              didSelectItemAtIndex:)]) {
        [self.delegate stackCardView:self
                didSelectItemAtIndex:self.currentIndex];
    }
}

// 添加拖拽手势
- (void)addPanGestureToView:(UIView *)view {
    UIPanGestureRecognizer *panGesture =
        [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handlePan:)];
    panGesture.cancelsTouchesInView = NO;
    panGesture.delaysTouchesBegan = NO;
    panGesture.delegate = self;
    [view addGestureRecognizer:panGesture];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(tapGestureClicked)];
    [self addGestureRecognizer:tapGesture];
}

// 拖拽手势处理
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    if (!_canSlide) {
        return;
    }

    UIView *view = gesture.view;
    CGPoint translation = [gesture translationInView:view];
    CGFloat offsetX = translation.x; // 获取x方向的平移距离
    _toRightSwipe = offsetX > 0;

    switch (gesture.state) {
    case UIGestureRecognizerStateBegan: // 表示手势的开始。手势识别器已识别到手势的起始动作并开始处理

        break;
    case UIGestureRecognizerStateChanged: // 表示手势的状态已发生变化，用户正在继续进行手势操作
        [self panMoveWithOffsetX:offsetX];
        break;
    case UIGestureRecognizerStateEnded: // 表示手势已结束，用户完成了手势的操作。此时手势识别器已完成对手势的识别。
        [self endPanMoveWithOffsetX:offsetX];
        break;
    case UIGestureRecognizerStateCancelled: // 表示手势被取消，通常是因为手势被打断或者视图的状态发生变化（例如触摸事件被外部干扰）
        [self endPanMoveWithOffsetX:offsetX];
        break;
    case UIGestureRecognizerStateFailed: // 表示手势识别失败。手势没有被成功识别，可以忽略或者进行失败处理。
        [self endPanMoveWithOffsetX:offsetX];
        break;

    default:
        break;
    }
}

- (void)panMoveWithOffsetX:(CGFloat)offsetX {
    if (_toRightSwipe) {
        UIView *view0 = _cacheViews[0];
        view0.frame =
            CGRectMake(offsetX - view0.bounds.size.width, 0,
                       view0.bounds.size.width, view0.bounds.size.height);
    } else {
        UIView *view1 = _cacheViews[1];
        view1.frame = CGRectMake(offsetX, 0, view1.bounds.size.width,
                                 view1.bounds.size.height);
    }
}

// 在手势结束后调用
- (void)updateCurrentIndexWithOffsetX:(CGFloat)offsetX {
    if ([self isEffectiveSlidingWithOffsetX:offsetX]) {
        if (_toRightSwipe) {
            self.currentIndex--; // 更新为前一个索引
        } else {
            self.currentIndex++; // 更新为后一个索引
        }
    }
}

- (BOOL)isEffectiveSlidingWithOffsetX:(CGFloat)offsetX {
    if (fabs(offsetX) >=
        self.slidingDistance) { // 滑动距离超过设置的距离视为可以翻页
        return YES;
    }
    return NO;
}

- (void)endPanMoveWithOffsetX:(CGFloat)offsetX {
    [self updateCurrentIndexWithOffsetX:offsetX];
    if ([self isEffectiveSlidingWithOffsetX:offsetX]) {
        [UIView animateWithDuration:0.2
            delay:0
            options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
              if (self->_toRightSwipe) {
                  self->_cacheViews[0].frame = self->_cacheViews[1].frame;
              } else {
                  self->_cacheViews[1].frame = self->_cacheViews[0].frame;
              }
            }
            completion:^(BOOL finished) {
              [self reloadViews];
            }];
    } else {
        [UIView animateWithDuration:0.2
            delay:0
            options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
              if (self->_toRightSwipe) {
                  self->_cacheViews[0].frame = [self getFrameWithIndex:0];
              } else {
                  self->_cacheViews[1].frame = [self getFrameWithIndex:1];
                  ;
              }
            }
            completion:^(BOOL finished) {
              [self reloadViews];
            }];
    }

    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(stackCardView:
                                              didEndScrollingToIndex:)]) {
        [self.delegate stackCardView:self
              didEndScrollingToIndex:self.currentIndex];
    }
}

- (CGFloat)getCornerRadius:(NSInteger)index {
    if (index <= 1) {
        return self.cornerRadiusMax;
    }
    if (index == _stackCount) {
        return self.cornerRadiusMin;
    }
    CGFloat space =
        (self.cornerRadiusMax - self.cornerRadiusMin) / (_stackCount - 1);
    return self.cornerRadiusMax - space * (index - 1);
}

- (CGRect)getFrameWithIndex:(NSInteger)index {

    CGFloat totalOffset = (_stackCount - 1) * self.stackDistanceX;
    CGFloat w = self.frame.size.width - totalOffset;
    CGFloat h = self.frame.size.height;

    CGFloat y = 0;
    CGFloat x = 0;

    if (index > 1) {
        h = self.frame.size.height -
            ((index - 1) * (self.stackDistanceY * 2)); // 高度逐渐减少
        y = (index - 1) * self.stackDistanceY;
    }

    if (index == 0) {
        x = -w;
    } else {
        x = self.stackDistanceX * (index - 1);
    }
    return CGRectMake(x, y, w, h);
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (currentIndex < 0) {
        _currentIndex = _dataSourceCount - 1; // 循环到最后一个索引
    } else if (currentIndex >= _dataSourceCount) {
        _currentIndex = 0; // 循环到第一个索引
    } else {
        _currentIndex = currentIndex;
    }
}

- (void)reloadViews {
    for (NSInteger i = 0; i < _cacheViews.count; i++) {
        TKStackCardCell *cell = (TKStackCardCell *)_cacheViews[i];
        cell.frame = [self getFrameWithIndex:i];
        NSInteger index = 0;

        if (i == 0) {
            index = _currentIndex - 1; // 最底层索引
            if (index < 0) {
                index = _dataSourceCount - 1;
            }
        } else if (i == 1) {
            index = _currentIndex; // 顶部卡片索引
        } else {
            index = _currentIndex + i - 1; // 中间卡片索引
        }

        if (index >= _dataSourceCount) {
            index = index % _dataSourceCount;
        }
        [self.dataSource stackCardView:self configureCell:cell forIndex:index];
    }
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    // 1. 检查目标索引是否有效
    if (index < 0 || index >= _dataSourceCount) {
        NSLog(@"目标索引超出范围");
        return;
    }

    // 如果当前的下标等于要跳转的下标，不执行动画
    if (self.currentIndex == index) {
        return;
    }

    // 2. 根据是否需要动画，调整视图
    if (animated) {
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.2
            delay:0
            options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
              if (index < self.currentIndex) { // 右滑

                  TKStackCardCell *toCell =
                      (TKStackCardCell *)self->_cacheViews[0];

                  [self.dataSource stackCardView:self
                                   configureCell:toCell
                                        forIndex:index];
                  toCell.frame = self->_cacheViews[1].frame;
              } else {

                  if (self->_cacheViews.count > 2) {
                      TKStackCardCell *toCell =
                          (TKStackCardCell *)self->_cacheViews[2];
                      [self.dataSource stackCardView:self
                                       configureCell:toCell
                                            forIndex:index];
                  }
                  TKStackCardCell *currentCell =
                      (TKStackCardCell *)self->_cacheViews[1];
                  currentCell.frame = self->_cacheViews[0].frame;
              }
            }
            completion:^(BOOL finished) {
              if (finished) {
                  self.currentIndex = index;
                  [self reloadViews]; // 确保最终状态刷新到位
                  self.userInteractionEnabled = YES;
              }
            }];
    } else {
        self.currentIndex = index;
        [self reloadViews];
    }
}

- (void)reloadData {

    // 1. 确保数据源存在
    if (!self.dataSource) {
        NSLog(@"数据源为空，无法刷新");
        return;
    }

    // 2. 重新加载数据源的数量
    _stackCount = [self.dataSource numberOfStacksInStackCardView:self];
    _dataSourceCount = [self.dataSource numberOfItemsInStackCardView:self];

    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(stackCardViewCanSlide:)]) {
        _canSlide = [self.delegate stackCardViewCanSlide:self];
    }

    if (_dataSourceCount <= 0) {
        NSLog(@"数据源数量为空");
        return;
    }

    if (_stackCount < 1) {
        NSLog(@"叠层数量小于1");
        return;
    }
    // 3. 重置索引
    self.currentIndex = 0;

    // 4. 刷新卡片布局
    [self setupUI];
    [self reloadViews];
}

/**
 * 解决外界上滑时候 无法滑动的问题
 * 这个方法是用来处理多手势共存的，返回NO则响应一个手势，返回YES为同时响应
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:
        (UIGestureRecognizer *)otherGestureRecognizer {
    CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer
        translationInView:_cacheViews[1]];
    // 如果translation.y的绝对值大于translation.x的绝对值就可以看成是上下方向
    if (fabs(translation.y) > fabs(translation.x)) {
        return true;
    }
    return false;
}
@end
