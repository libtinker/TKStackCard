//
//  StackCardView.h
//  StackCard
//
//  Created by 郑俊杰 on 2025/1/20.
//

#import <UIKit/UIKit.h>
#import "TKStackCardCell.h"

NS_ASSUME_NONNULL_BEGIN

@class TKStackCardView;
@protocol StackCardViewDataSource <NSObject>
@required

/// 配置 StackCardCell 数据
/// - Parameters:
///   - cell: 卡片视图实例
///   - index: 数据源的下标
- (void)stackCardView:(TKStackCardView *)stackCardView configureCell:(TKStackCardCell *)cell forIndex:(NSInteger)index;

/// 数据源的数量
/// - Parameter stackCardView: 当前的 StackCardView 实例
- (NSInteger)numberOfItemsInStackCardView:(TKStackCardView *)stackCardView;

/// 叠层的数量
/// - Parameter stackCardView: 当前的 StackCardView 实例
- (NSInteger)numberOfStacksInStackCardView:(TKStackCardView *)stackCardView;

@end

@protocol StackCardViewDelegate <NSObject>

@optional

/// 处理卡片点击事件
/// - Parameters:
///   - stackCardView: 当前的 StackCardView 实例
///   - index: 点击的卡片下标
- (void)stackCardView:(TKStackCardView *)stackCardView didSelectItemAtIndex:(NSInteger)index;

/// 卡片滚动结束后的回调
/// - Parameters:
///   - stackCardView: 当前的 StackCardView 实例
///   - index: 滚动到的卡片下标
- (void)stackCardView:(TKStackCardView *)stackCardView didEndScrollingToIndex:(NSInteger)index;

/// 判断是否允许滑动
/// - Parameter stackCardView: 当前的 StackCardView 实例
/// - Returns: 是否允许滑动（`YES` 为允许，`NO` 为不允许）
- (BOOL)stackCardViewCanSlide:(TKStackCardView *)stackCardView;

@end

@interface TKStackCardView : UIView

@property(nonatomic, assign) CGFloat stackDistanceX; // x轴叠层之间间距（默认是17）
@property(nonatomic, assign) CGFloat stackDistanceY; // y轴叠层之间间距（默认是5）
@property (nonatomic,assign) CGFloat cornerRadiusMax;//最大的圆角
@property (nonatomic,assign) CGFloat cornerRadiusMin;//最小的圆角
@property (nonatomic,assign) CGFloat slidingDistance;//滑动距离（默认150）超过这个数值视为滑动翻页

@property (nonatomic,weak) id<StackCardViewDelegate> delegate;
@property (nonatomic,weak) id<StackCardViewDataSource> dataSource;



/// 滚到到第几个视图
/// - Parameters:
///   - index: 下标
///   - animated: 是否动画
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;


/// 刷新数据(在所有属性都设置完成后再调用，否则不生效)
- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
