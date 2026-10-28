#import <UIKit/UIKit.h>

// 前向声明淘宝商品详情页控制器及相关类
@class TBItemDetailViewController;
@class TBAdManager;
@class TBUpdateService;

%hook TBItemDetailViewController

- (void)viewDidLoad {
    %orig;
    
    // 显式将 self 转换为 UIViewController *，解决 forward class 无法识别属性及指针类型不匹配的问题
    UIViewController *rootVC = (UIViewController *)self;
    UIView *selfView = rootVC.view;
    
    if (selfView) {
        NSLog(@"[TaobaoEnhancer] 成功获取到商品详情页 View: %@", selfView);
        
        // 可以在这里加入你的 UI 增强、去广告或自定义布局逻辑
        // 例如：动态修改背景色测试插件是否生效
        // selfView.backgroundColor = [UIColor redColor];
    }
}

%end

// ==========================================
// 示例：屏蔽淘宝开屏广告或更新提示（可选）
// ==========================================
%hook TBUpdateService

- (void)checkUpdate {
    // 拦截更新检测，防止强制弹窗更新
    NSLog(@"[TaobaoEnhancer] 已成功拦截淘宝自动更新检测");
}

%end
