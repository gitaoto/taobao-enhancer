#import <UIKit/UIKit.h>

@interface UIViewController (TaobaoEnhancer)
- (void)tbEnhancer_showPriceHistory;
@end

// ==========================================
// 1. 商品详情页：“历史价格”按钮（稳健且省电）
// ==========================================
%hook TBItemDetailViewController

- (void)viewDidLoad {
    %orig; // 必须先执行原生的 viewDidLoad，保证排队与加载逻辑正常运行
    
    // 异步延迟到主线程，防止阻塞淘宝页面的正常初始化渲染
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = (UIViewController *)self;
        UIView *selfView = rootVC.view;
        
        if (!selfView) return;
        
        // 防重复注入标记
        NSInteger btnTag = 8881027;
        if ([selfView viewWithTag:btnTag]) return;
        
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
    });
}

// 历史价格按钮点击触发逻辑
%new
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
// 2. 精准去开屏广告（不影响正常启动流）
// ==========================================
%hook TBAdManager

- (BOOL)isSplashAdEnable {
    return NO;
}

// 使用安全阻断，不空置基础初始化
- (void)loadSplashAd {
    // 拦截开屏广告请求，防止后台消耗流量和电量
}

%end


// ==========================================
// 3. 安全去更新 & 屏蔽更新提示弹窗
// ==========================================
%hook TBUpdateService

- (void)checkUpdate {
    // 切断后台自动更新检测轮询
}

- (void)showUpdateAlert {
    // 阻断弹窗展示，避免弹窗打扰
}

- (BOOL)isForceUpdate {
    return NO;
}

%end
