//
//  MXWAdapter.h
//  XXX
//
//  Created by BLOM on 2020/9/3.
//  Copyright © 2020 fhcq. All rights reserved.
//

#ifndef MXWAdapter_h
#define MXWAdapter_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



/** 适配手机类型 */
typedef NS_ENUM(NSInteger,MXWAdapterPhoneType) {
    /** iPhone3GS_4_4S */
    MXWAdapterPhoneType_iPhone3GS_4_4S    = 0,
    /** iPhone5_5C_5S_5SE */
    MXWAdapterPhoneType_iPhone5_5C_5S_5SE = 1,
    /** iPhone6_6S_7_8 */
    MXWAdapterPhoneType_iPhone6_6S_7_8_SE = 2,
    /** iPhone6Plus_6SPlus_7Plus_8Plus */
    MXWAdapterPhoneType_iPhone6Plus_6SPlus_7Plus_8Plus = 3,
    /** iPhoneX_XS_11Pro_12mini */
    MXWAdapterPhoneType_iPhoneX_XS_11Pro_12mini        = 4,
    /** iPhoneXSMax_XR_11_11ProMax */
    MXWAdapterPhoneType_iPhoneXSMax_XR_11_11ProMax     = 5,
    /** iPhone12_12Pro */
    MXWAdapterPhoneType_iPhone12_12Pro                 = 6,
    /** iPhone12ProMax */
    MXWAdapterPhoneType_iPhone12ProMax                 = 7,
    /** 其他 */
    MXWAdapterPhoneTypeOther                           = 8,
};

/** 所需适配机型-屏幕宽 */
UIKIT_EXTERN CGFloat const SCREEN_WIDTH_iPhone3GS_4_4S;
UIKIT_EXTERN CGFloat const SCREEN_WIDTH_iPhone5_5C_5S_5SE;
UIKIT_EXTERN CGFloat const SCREEN_WIDTH_iPhone6_6S_7_8_SE;
UIKIT_EXTERN CGFloat const SCREEN_WIDTH_iPhone6Plus_6SPlus_7Plus_8Plus;
UIKIT_EXTERN CGFloat const SCREEN_WIDTH_iPhoneX_XS_11Pro_12mini;
UIKIT_EXTERN CGFloat const SCREEN_WIDTH_iPhoneXSMax_XR_11_11ProMax;
UIKIT_EXTERN CGFloat const SCREEN_WIDTH_iPhone12_12Pro;
UIKIT_EXTERN CGFloat const SCREEN_WIDTH_iPhone12ProMax;

/** 所需适配机型-屏幕高 */
UIKIT_EXTERN CGFloat const SCREEN_HEIGHT_iPhone3GS_4_4S;
UIKIT_EXTERN CGFloat const SCREEN_HEIGHT_iPhone5_5C_5S_5SE;
UIKIT_EXTERN CGFloat const SCREEN_HEIGHT_iPhone6_6S_7_8_SE;
UIKIT_EXTERN CGFloat const SCREEN_HEIGHT_iPhone6Plus_6SPlus_7Plus_8Plus;
UIKIT_EXTERN CGFloat const SCREEN_HEIGHT_iPhoneX_XS_11Pro_12mini;
UIKIT_EXTERN CGFloat const SCREEN_HEIGHT_iPhoneXSMax_XR_11_11ProMax;
UIKIT_EXTERN CGFloat const SCREEN_HEIGHT_iPhone12_12Pro;
UIKIT_EXTERN CGFloat const SCREEN_HEIGHT_iPhone12ProMax;

/** 屏幕宽度 */
static inline CGFloat mxwScreenWidth() {
    return [UIScreen mainScreen].bounds.size.width;
}

/** 屏幕高度 */
static inline CGFloat mxwScreenHeight() {
    return [UIScreen mainScreen].bounds.size.height;
}

/** 当前屏幕类型 */
static inline MXWAdapterPhoneType mxwCurrentType() {
    if (mxwScreenHeight() == SCREEN_HEIGHT_iPhone3GS_4_4S) return MXWAdapterPhoneType_iPhone3GS_4_4S;
    if (mxwScreenHeight() == SCREEN_HEIGHT_iPhone5_5C_5S_5SE) return MXWAdapterPhoneType_iPhone5_5C_5S_5SE;
    if (mxwScreenHeight() == SCREEN_HEIGHT_iPhone6_6S_7_8_SE) return MXWAdapterPhoneType_iPhone6_6S_7_8_SE;
    if (mxwScreenHeight() == SCREEN_HEIGHT_iPhone6Plus_6SPlus_7Plus_8Plus) return MXWAdapterPhoneType_iPhone6Plus_6SPlus_7Plus_8Plus;
    if (mxwScreenHeight() == SCREEN_HEIGHT_iPhoneX_XS_11Pro_12mini) return MXWAdapterPhoneType_iPhoneX_XS_11Pro_12mini;
    if (mxwScreenHeight() == SCREEN_HEIGHT_iPhoneXSMax_XR_11_11ProMax) return MXWAdapterPhoneType_iPhoneXSMax_XR_11_11ProMax;
    if (mxwScreenHeight() == SCREEN_HEIGHT_iPhone12_12Pro) return MXWAdapterPhoneType_iPhone12_12Pro;
    if (mxwScreenHeight() == SCREEN_HEIGHT_iPhone12ProMax) return MXWAdapterPhoneType_iPhone12ProMax;
    return MXWAdapterPhoneTypeOther;
}

/** 屏幕适配 */
@interface MXWAdapter : NSObject

/** 屏幕默认类型 默认为MXWAdapterPhoneType_iPhone6_6S_7_8 */
@property(nonatomic)MXWAdapterPhoneType defaultType;

/** 屏幕宽度 */
@property (nonatomic,readonly)CGFloat defaultScreenWidth;

/** 屏幕高度 */
@property (nonatomic,readonly)CGFloat defaultScreenHeight;

/** 共享适配器 */
+ (instancetype)shareAdapter;

@end

/**
 注：屏幕及字体是以屏幕宽度来适配的
 */

/** 真实字体大小 */
static inline CGFloat mxwRealFontSize(CGFloat defaultSize) {
    if ([MXWAdapter shareAdapter].defaultType == mxwCurrentType())
        return defaultSize;
    return mxwScreenWidth() / [MXWAdapter shareAdapter].defaultScreenWidth * defaultSize;
}

/** 真实宽度 */
static inline CGFloat mxwRealWidth(CGFloat defaultWidth) {
    if ([MXWAdapter shareAdapter].defaultType == mxwCurrentType())
        return defaultWidth;
    return mxwScreenWidth()/[MXWAdapter shareAdapter].defaultScreenWidth * defaultWidth;
}
/** 真实高度 */
static inline CGFloat mxwRealHeight(CGFloat defaultHeight) {
    if ([MXWAdapter shareAdapter].defaultType == mxwCurrentType())
        return defaultHeight;
    return mxwScreenHeight()/[MXWAdapter shareAdapter].defaultScreenHeight * defaultHeight;
}


#pragma mark - 屏幕适配相关参数

/// 状态栏高度,刘海屏 44其它20
extern CGFloat mxwStatusHeight(void);
/// 导航栏高度 44
extern CGFloat const mxwNavBarHeight;
/// 状态栏高度+导航栏搞   64或88
extern CGFloat mxwStatusNavBarHeight(void);
/// 底部TabBar高度,刘海屏 83其他49
extern CGFloat mxwTabBarHeight(void);
/// iPhoneX 和 非 X高度 底部安全区域 34或0
extern CGFloat mxwBottomSafeAreaHeight(void);


#endif /* MXWAdapter_h */
