#import <UIKit/UIKit.h>

@interface UIViewController (TaobaoEnhancer)
- (void)tbEnhancer_showPriceHistory;
@end

// ==========================================
// 1. 商品详情页：“历史价格”按钮（省电/高效渲染）
// ==========================================
%hook TBItemDetailViewController

- (void)viewDidLoad {
    %orig;
    
    UIViewController *rootVC = (UIViewController *)self;
    UIView *selfView = rootVC.view;
    
    if (selfView) {
        // 使用 Tag 机制防止重复创建视图，降低 CPU/内存开销
        NSInteger btnTag = 8881027;
        if ([selfView viewWithTag:btnTag]) {
            return;
        }
        
        // 创建低功耗轻量级“历史价格”悬浮按钮
        UIButton *priceHistoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        priceHistoryBtn.tag = btnTag;
        priceHistoryBtn.frame = CGRectMake(selfView.bounds.size.width - 85, 130, 75, 32);
        [priceHistoryBtn setTitle:@"历史价格" forState:UIControlStateNormal];
        [priceHistoryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        priceHistoryBtn.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
        priceHistoryBtn.backgroundColor = [UIColor colorWithRed:1.00 green:0.30 blue:0.00 alpha:0.85]; // 淘宝橙红风格
        priceHistoryBtn.layer.cornerRadius = 16.0;
        priceHistoryBtn.clipsToBounds = YES;
        
        // 绑定点击事件
        [priceHistoryBtn addTarget:rootVC action:@selector(tbEnhancer_showPriceHistory) forControlEvents:UIControlEventTouchUpInside];
        
        [selfView addSubview:priceHistoryBtn];
        [selfView bringSubviewToFront:priceHistoryBtn];
    }
}

// 历史价格按钮点击触发逻辑
- (void)tbEnhancer_showPriceHistory {
    UIViewController *rootVC = (UIViewController *)self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"价格走势" 
                                                                   message:@"已成功拦截数据入口！\n（此处可对接比价 API 或加载历史价格网页）" 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    
    [rootVC presentViewController:alert animated:YES completion:nil];
}

%end


// ==========================================
// 2. 去开屏广告（拦截加载 + 零网络开销）
// ==========================================
%hook TBAdManager

- (BOOL)isSplashAdEnable {
    // 强制返回 NO，阻止广告预加载，节省蜂窝网络流量和系统电量
    return NO;
}

- (void)loadSplashAd {
    // 空方法直接阻断开屏广告请求
}

- (void)showSplashAd {
    // 空方法直接阻断广告渲染
}

%end


// ==========================================
// 3. 去更新 & 去更新提示（彻底切断后台轮询）
// ==========================================
%hook TBUpdateService

- (void)checkUpdate {
    // 直接阻断更新检查请求，省去后台 API 定时轮询电量
}

- (void)showUpdateAlert {
    // 阻断弹窗渲染
}

- (BOOL)isForceUpdate {
    // 强制标记非强更
    return NO;
}

%end
