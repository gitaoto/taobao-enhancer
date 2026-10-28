#import <UIKit/UIKit.h>

// ==========================================
// 1. 去开屏广告（拦截广告加载与渲染，省流量、省电）
// ==========================================
%hook TBAdManager

- (BOOL)isSplashAdEnable {
    // 强制关闭开屏广告使能
    return NO;
}

- (void)loadSplashAd {
    // 阻断广告预加载请求
}

- (void)showSplashAd {
    // 阻断广告弹窗渲染
}

%end


// ==========================================
// 2. 去更新 & 去更新提示（切断后台自动更新轮询，省电防打扰）
// ==========================================
%hook TBUpdateService

- (void)checkUpdate {
    // 阻断后台定时请求版本更新，减少 CPU 唤醒与电量消耗
}

- (void)showUpdateAlert {
    // 阻断烦人的更新提示弹窗
}

- (BOOL)isForceUpdate {
    // 强制返回非强更状态
    return NO;
}

%end
