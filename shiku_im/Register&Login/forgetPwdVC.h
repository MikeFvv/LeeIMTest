//
//  forgetPwdVC.h
//  shiku_im
//
//  Created by flyeagleTang on 14-6-7.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "admobViewController.h"


@interface forgetPwdVC : admobViewController{
    UITextField* _phone;
    UITextField* _oldPwd;
    UITextField* _pwd;
    UITextField* _repeat;
    UITextField* _code;
    UIButton* _send;
    NSString* _smsCode;
    int _seconds;
}

/**
 修改密码
 */
@property (nonatomic, assign) BOOL isModify;

@property (nonatomic, assign) NSInteger state;//0是忘记密码  1是修改密码 2是忘记支付密码
@end
