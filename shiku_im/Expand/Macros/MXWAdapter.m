//
//  MXWAdapter.m
//  XXX
//
//  Created by BLOM on 2020/9/3.
//  Copyright © 2020 fhcq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXWAdapter.h"

/** 所需适配机型-屏幕宽 */
CGFloat const SCREEN_WIDTH_iPhone3GS_4_4S       = 320.0f;
CGFloat const SCREEN_WIDTH_iPhone5_5C_5S_5SE    = 320.0f;
CGFloat const SCREEN_WIDTH_iPhone6_6S_7_8_SE    = 375.0f;
CGFloat const SCREEN_WIDTH_iPhone6Plus_6SPlus_7Plus_8Plus  = 414.0f;
CGFloat const SCREEN_WIDTH_iPhoneX_XS_11Pro_12mini         = 375.0f;
CGFloat const SCREEN_WIDTH_iPhoneXSMax_XR_11_11ProMax      = 414.0f;
CGFloat const SCREEN_WIDTH_iPhone12_12Pro                  = 390.0f;
CGFloat const SCREEN_WIDTH_iPhone12ProMax                  = 428.0f;

/** 所需适配机型-屏幕高 */
CGFloat const SCREEN_HEIGHT_iPhone3GS_4_4S      = 480.0f;
CGFloat const SCREEN_HEIGHT_iPhone5_5C_5S_5SE   = 568.0f;
CGFloat const SCREEN_HEIGHT_iPhone6_6S_7_8_SE   = 667.0f;
CGFloat const SCREEN_HEIGHT_iPhone6Plus_6SPlus_7Plus_8Plus = 736.0f;
CGFloat const SCREEN_HEIGHT_iPhoneX_XS_11Pro_12mini        = 812.0f;
CGFloat const SCREEN_HEIGHT_iPhoneXSMax_XR_11_11ProMax     = 896.0f;
CGFloat const SCREEN_HEIGHT_iPhone12_12Pro                 = 844.0f;
CGFloat const SCREEN_HEIGHT_iPhone12ProMax                 = 926.0f;

@implementation MXWAdapter

/** 共享适配器 */
+ (instancetype)shareAdapter{
    static dispatch_once_t onceToken;
    static MXWAdapter * _instance = nil;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

/** 重载方法 */
- (instancetype)init{
    if (self = [super init]) {
        self.defaultType = MXWAdapterPhoneType_iPhone6_6S_7_8_SE;
    }
    return self;
}

/** 设置默认类型 */
- (void)setDefaultType:(MXWAdapterPhoneType)defaultType {
    _defaultType = defaultType;
    switch (_defaultType) {
        case MXWAdapterPhoneType_iPhone3GS_4_4S:
            _defaultScreenWidth  = SCREEN_WIDTH_iPhone3GS_4_4S;
            _defaultScreenHeight = SCREEN_HEIGHT_iPhone3GS_4_4S;
            break;
        case MXWAdapterPhoneType_iPhone5_5C_5S_5SE:
            _defaultScreenWidth  = SCREEN_WIDTH_iPhone5_5C_5S_5SE;
            _defaultScreenHeight = SCREEN_HEIGHT_iPhone5_5C_5S_5SE;
            break;
        case MXWAdapterPhoneType_iPhone6_6S_7_8_SE:
            _defaultScreenWidth  = SCREEN_WIDTH_iPhone6_6S_7_8_SE;
            _defaultScreenHeight = SCREEN_HEIGHT_iPhone6_6S_7_8_SE;
            break;
        case MXWAdapterPhoneType_iPhone6Plus_6SPlus_7Plus_8Plus:
            _defaultScreenWidth  = SCREEN_WIDTH_iPhone6Plus_6SPlus_7Plus_8Plus;
            _defaultScreenHeight = SCREEN_HEIGHT_iPhone6Plus_6SPlus_7Plus_8Plus;
            break;
        case MXWAdapterPhoneType_iPhoneX_XS_11Pro_12mini:
            _defaultScreenWidth  = SCREEN_WIDTH_iPhoneX_XS_11Pro_12mini;
            _defaultScreenHeight = SCREEN_HEIGHT_iPhoneX_XS_11Pro_12mini;
            break;
        case MXWAdapterPhoneType_iPhoneXSMax_XR_11_11ProMax:
            _defaultScreenWidth  = SCREEN_WIDTH_iPhoneXSMax_XR_11_11ProMax;
            _defaultScreenHeight = SCREEN_HEIGHT_iPhoneXSMax_XR_11_11ProMax;
            break;
        case MXWAdapterPhoneType_iPhone12_12Pro:
            _defaultScreenWidth  = SCREEN_WIDTH_iPhone12_12Pro;
            _defaultScreenHeight = SCREEN_HEIGHT_iPhone12_12Pro;
            break;
        case MXWAdapterPhoneType_iPhone12ProMax:
            _defaultScreenWidth  = SCREEN_WIDTH_iPhone12ProMax;
            _defaultScreenHeight = SCREEN_HEIGHT_iPhone12ProMax;
            break;
        case MXWAdapterPhoneTypeOther:
            break;
        default:
            break;
    }
}

@end


 

#pragma mark - 屏幕适配相关参数

/// 导航栏高度 44
CGFloat const mxwNavBarHeight = 44.0;

/// iPhoneX 和 非 X高度 状态栏高度
CGFloat mxwStatusHeight(void){
    
    // 获取状态栏高度
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
//    return statusHeight;
    if (statusHeight == 0) {
        if (@available(iOS 11.0, *)) {
            // 非刘海屏，若存在状态条隐藏显示的切换，会有window.safeAreaInsets.top返回为0的异常情况
            UIWindow *window = [UIApplication.sharedApplication.windows firstObject];
            if (window.safeAreaInsets.bottom > 0) {
                statusHeight = window.safeAreaInsets.top;
            }
        } else {
            statusHeight = 20;
        }
    }
    return statusHeight;
}


/// 状态栏高度+导航栏搞   64或88
CGFloat mxwStatusNavBarHeight(void){
    return mxwNavBarHeight + mxwStatusHeight();
}

/// 底部tabBar高度,刘海屏 83 其他 49
CGFloat mxwTabBarHeight(void){
    return (mxwScreenHeight() >= 812.0 ? 83 : 49);
}

/// iPhoneX 和 非 X高度 底部安全区域 34或0
CGFloat mxwBottomSafeAreaHeight(void){
    return (mxwScreenHeight() >= 812.0 ? 34 : 0);
}



