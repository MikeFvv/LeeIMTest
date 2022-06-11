//
//  loginVC.m
//  shiku_im
//
//  Created by flyeagleTang on 14-6-7.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "loginVC.h"
#import "forgetPwdVC.h"
#import "inputPhoneVC.h"
#import "JXTelAreaListVC.h"
#import "QCheckBox.h"
#import "webpageVC.h"
#import "JXServerListVC.h"
#import "JXLocation.h"
#import "UIImage+Color.h"
#import "UIView+Frame.h"
#import "RITLUtility.h"


#define HEIGHT 46
#define MarginWidth 24
#define tyCurrentWindow [[UIApplication sharedApplication].windows firstObject]

@interface loginVC ()<UITextFieldDelegate,QCheckBoxDelegate,JXLocationDelegate,JXLocationDelegate>
{
    UIButton *_areaCodeBtn;
    QCheckBox * _checkProtocolBtn;
    UIButton *_forgetBtn;
    BOOL _isFirstLocation;
    NSString *_myToken;
    
    //短信验证码登录
    UIButton *_switchLogin; //切换登录方式
    UIImageView * _imgCodeImg;
    UITextField *_imgCode;   //图片验证码
    UIButton *_send;   //发送短信
    UIButton * _graphicButton;
    NSString* _smsCode;
    int _seconds;
    NSTimer *_timer;
}
@property (nonatomic ,strong)UILabel *areaLabel;
@property (nonatomic ,strong)UIImageView *bgImageview;
@end

@implementation loginVC

- (id)init
{
    self = [super init];
    if (self) {
        
        _user = [[JXUserObject alloc] init];
        self.heightFooter = 0;
        self.heightHeader = JX_SCREEN_TOP;
        if (self.isSMSLogin) {
            self.isGotoBack = YES;
        }
        
        g_server.isManualLogin = NO;
        
        [self createHeadAndFoot];
        self.tableBody.backgroundColor = [UIColor clearColor];
        _myToken = [g_default objectForKey:kMY_USER_TOKEN];
        
        int n = INSETS;
        g_server.isLogin = NO;
        g_navigation.lastVC = nil;
        
        UIButton* btn = [UIFactory createButtonWithTitle:Localized(@"JX_SetupServer") titleFont:[UIFont systemFontOfSize:15] titleColor:[UIColor whiteColor] normal:nil highlight:nil];
        [btn setTitleColor:THESIMPLESTYLE ? [UIColor blackColor] : [UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onSetting) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(JX_SCREEN_WIDTH-160, JX_SCREEN_TOP - 38, 83, 30);
        btn.hidden = _isThirdLogin || self.isSMSLogin;
        
        
        n += 60;
        UILabel *titleL = [UIFactory createLabelWith:CGRectMake(50, n, JX_SCREEN_WIDTH-100, 30) text:@""]; // Localized(@"JX_Login")
        titleL.font = [UIFont systemFontOfSize:30 weight:UIFontWeightRegular];
        titleL.textColor =[UIColor whiteColor];
        titleL.textAlignment = NSTextAlignmentCenter;
        if (_isSMSLogin) {
            titleL.text = Localized(@"JX_SMSLogin"); //@"使用短信登录";
        }
        [self.tableBody addSubview:titleL];
        
        //酷聊title
        NSString * titleStr;
#if TAR_IM
        titleStr = APP_NAME;
#endif
        
        n += 70;
        
        
        UIImageView *topBackImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, JX_SCREEN_WIDTH, 544/2)];
        topBackImageView.image = [UIImage imageNamed:@"login_topback"];
        [self.bgImageview addSubview:topBackImageView];
        
        UIImageView *loginLogoImg = [[UIImageView alloc] initWithFrame: CGRectMake(JX_SCREEN_WIDTH/2-232/2/2, 80, 232/2, 218/2)];
        loginLogoImg.image = [UIImage imageNamed:@"login_logo"];
        [topBackImageView addSubview:loginLogoImg];
        
        UILabel *duduLabel = [[UILabel alloc] initWithFrame: CGRectMake(JX_SCREEN_WIDTH/2-100/2, 80+218/2, 100, 30)];
        duduLabel.text = @"DUDU";
        duduLabel.font = [UIFont boldSystemFontOfSize:18];
        duduLabel.textColor = [UIColor whiteColor];
        duduLabel.textAlignment = NSTextAlignmentCenter;
        [topBackImageView addSubview:duduLabel];
        
        UILabel *areaL = [UIFactory createLabelWith:CGRectMake(50, n,JX_SCREEN_WIDTH-100, HEIGHT) text:@""];
        areaL.textColor =[UIColor whiteColor];
        areaL.font = g_factory.font16;
        [self.tableBody addSubview:areaL];
        self.areaLabel = areaL;
        
        // 选择国际电话区号
//        UIImageView *rightArraw  =[[UIImageView alloc]initWithFrame:CGRectMake( areaL.width-20, (HEIGHT-20)*0.5, 20, 20)];
//        rightArraw.image = [UIImage imageNamed:@"set_list_next"];
//        [areaL addSubview:rightArraw];
//
////        UIView *areaLine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-4, areaL.frame.size.width, 0.5)];
////        areaLine.backgroundColor = HEXCOLOR(0xD6D6D6);
////        [areaL addSubview:areaLine];
//
//        UITapGestureRecognizer *areaTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(areaCodeBtnClick:)];
//        areaL.userInteractionEnabled = YES;
//        [areaL addGestureRecognizer:areaTap];
        
        n = n+HEIGHT+INSETS+50;
        
        //区号
        if (!_phone) {
            _phone = [UIFactory createTextFieldWith:CGRectMake(MarginWidth, n, JX_SCREEN_WIDTH-MarginWidth*2, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JX_InputPhone") font:g_factory.font16];
            
            _phone.layer.cornerRadius = HEIGHT/2;
            _phone.backgroundColor =  RITLColorFromIntRBG(244, 246, 248);
            _phone.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_InputPhone") attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
            _phone.textColor =[UIColor blackColor];
            _phone.clearButtonMode = UITextFieldViewModeWhileEditing;
            _phone.keyboardType = UIKeyboardTypeNumberPad;
            _phone.borderStyle = UITextBorderStyleNone;
            
            UIView *idLeftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
            _phone.leftView = idLeftView;
            _phone.leftViewMode = UITextFieldViewModeAlways;
            UIButton *idLeftBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 20, 20)];
            [idLeftBtn setBackgroundImage:[UIImage imageNamed:@"login_id"] forState:UIControlStateNormal];
            [idLeftView addSubview:idLeftBtn];
            
            [self.tableBody addSubview:_phone];
            _phone.delegate = self;
            
            [_phone addTarget:self action:@selector(longLimit:) forControlEvents:UIControlEventEditingChanged];
            
        }
        
        n = n+HEIGHT+INSETS+5;
        
        
        if (self.isSMSLogin) {
            //图片验证码
            _imgCode = [UIFactory createTextFieldWith:CGRectMake(50, n, JX_SCREEN_WIDTH-50*2-70-INSETS-35-4, HEIGHT) delegate:self returnKeyType:UIReturnKeyNext secureTextEntry:NO placeholder:Localized(@"JX_inputImgCode") font:g_factory.font16];
            _imgCode.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_inputImgCode") attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
            _imgCode.borderStyle = UITextBorderStyleNone;
            _imgCode.clearButtonMode = UITextFieldViewModeWhileEditing;
            [self.tableBody addSubview:_imgCode];
            _imgCode.textColor =[UIColor whiteColor];
            
            
            UIView *imCLine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-4, _phone.frame.size.width, 0.5)];
            imCLine.backgroundColor = HEXCOLOR(0xD6D6D6);
            [_imgCode addSubview:imCLine];
            
            _imgCodeImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_imgCode.frame)+INSETS, 0, 70, 35)];
            _imgCodeImg.center = CGPointMake(_imgCodeImg.center.x, _imgCode.center.y);
            _imgCodeImg.userInteractionEnabled = YES;
            [self.tableBody addSubview:_imgCodeImg];
            
            UIView *imgCodeLine = [[UIView alloc] initWithFrame:CGRectMake(_imgCodeImg.frame.size.width, 3, 0.5, _imgCodeImg.frame.size.height-6)];
            imgCodeLine.backgroundColor = HEXCOLOR(0xD6D6D6);
            [_imgCodeImg addSubview:imgCodeLine];
            
            _graphicButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _graphicButton.frame = CGRectMake(CGRectGetMaxX(_imgCodeImg.frame)+6, 7, 26, 26);
            _graphicButton.center = CGPointMake(_graphicButton.center.x,_imgCode.center.y);
            [_graphicButton setBackgroundImage:[UIImage imageNamed:@"refreshGraphic"] forState:UIControlStateNormal];
            [_graphicButton setBackgroundImage:[UIImage imageNamed:@"refreshGraphic"] forState:UIControlStateHighlighted];
            [_graphicButton addTarget:self action:@selector(refreshGraphicAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.tableBody addSubview:_graphicButton];
            n = n+HEIGHT+INSETS+5;
        }
        
        //密码
        _pwd = [[UITextField alloc] initWithFrame:CGRectMake(MarginWidth, n, JX_SCREEN_WIDTH-MarginWidth*2, HEIGHT)];
        _pwd.layer.cornerRadius = HEIGHT/2;
        _pwd.backgroundColor =  RITLColorFromIntRBG(244, 246, 248);
        _pwd.delegate = self;
        _pwd.font = g_factory.font16;
        _pwd.autocorrectionType = UITextAutocorrectionTypeNo;
        _pwd.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _pwd.enablesReturnKeyAutomatically = YES;
        //        _pwd.borderStyle = UITextBorderStyleRoundedRect;
        _pwd.returnKeyType = UIReturnKeyDone;
        _pwd.clearButtonMode = UITextFieldViewModeWhileEditing;
        _pwd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_InputPassWord") attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        _pwd.secureTextEntry = !self.isSMSLogin;
        _pwd.userInteractionEnabled = YES;
        _pwd.textColor =[UIColor blackColor];
        
        UIView *pwLeftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
        _pwd.leftView = pwLeftView;
        _pwd.leftViewMode = UITextFieldViewModeAlways;
        UIButton *pwLeftBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 20, 20)];
        [pwLeftBtn setBackgroundImage:[UIImage imageNamed:@"login_pw"] forState:UIControlStateNormal];
        [pwLeftView addSubview:pwLeftBtn];
        
        [self.tableBody addSubview:_pwd];
        
        
        
        if (self.isSMSLogin) {
            _pwd.width = JX_SCREEN_WIDTH-50*2-100;
            _pwd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:Localized(@"JX_InputMessageCode") attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
            _send = [UIButton buttonWithType:0];
            [_send setTitle:@"发送验证码" forState:0];
            [_send setTitleColor:[UIColor whiteColor] forState:0];
            _send.titleLabel.font = [UIFont systemFontOfSize:14];
            _send.frame = CGRectMake(JX_SCREEN_WIDTH-100-55, n+INSETS-1, 100, 32);
            [_send addTarget:self action:@selector(sendSMS) forControlEvents:UIControlEventTouchUpInside];
            _send.backgroundColor = HEXCOLOR(0x3F94F7);
            _send.layer.masksToBounds = YES;
            _send.layer.cornerRadius = _send.frame.size.height/2;
            [self.tableBody addSubview:_send];
            
        }else {
            UIView *eyeView = [[UIView alloc]initWithFrame:CGRectMake(_pwd.frame.size.width-60, 0, 40, 40)];
            _pwd.rightView = eyeView;
            _pwd.rightViewMode = UITextFieldViewModeAlways;
            UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 12, 20, 16)];
            [rightBtn setBackgroundImage:[UIImage imageNamed:@"ic_password_hide"] forState:UIControlStateNormal];
            [rightBtn setBackgroundImage:[UIImage imageNamed:@"ic_password_display"] forState:UIControlStateSelected];
            [rightBtn addTarget:self action:@selector(passWordRightViewClicked:) forControlEvents:UIControlEventTouchUpInside];
            [eyeView addSubview:rightBtn];
        }
        
        
        n = n+10+INSETS;
        
        n += 6;
        
        
        if (!self.isSMSLogin) {
            n = n+36;
        }else{
            n = n+36;
        }
        
        n+=20+10;
        
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn setTitle:@"登录" forState:UIControlStateNormal];
        [_btn addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
        _btn.custom_acceptEventInterval = 1.0f;
        _btn.backgroundColor = THEMECOLOR;
        
        UIImage *backgroundImage = [UIImage createImageWithColor:HEXCOLOR(0x3F94F7)];
        [_btn setBackgroundImage: backgroundImage forState:UIControlStateNormal];
        [_btn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x3F94F7)] forState:UIControlStateHighlighted];
        
        [_btn.titleLabel setFont:g_factory.font16];
        
        _btn.clipsToBounds = YES;
        _btn.frame = CGRectMake(MarginWidth, n, JX_SCREEN_WIDTH-MarginWidth*2, HEIGHT);
        _btn.layer.cornerRadius = HEIGHT*0.5;
        _btn.userInteractionEnabled = NO;
        [self.tableBody addSubview:_btn];
        n = n+HEIGHT+INSETS;
        
        //注册用户
        CGSize size =[@"注册用户" boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:g_factory.font16} context:nil].size;
        UIButton *registerBtn = [UIButton buttonWithType:0];
        registerBtn.frame  = CGRectMake(60, n+20, JX_SCREEN_WIDTH-60*2, HEIGHT);
        registerBtn.titleLabel.font = g_factory.font16;
        [registerBtn setTitleColor:RITLColorFromIntRBG(38, 108, 230) forState:UIControlStateNormal];
        [registerBtn setTitle:@"注册用户" forState:UIControlStateNormal];
        registerBtn.custom_acceptEventInterval = 1.0f;
        [registerBtn addTarget:self action:@selector(onRegister) forControlEvents:UIControlEventTouchUpInside];
        registerBtn.hidden = self.isSMSLogin;
        
        [self.tableBody addSubview:registerBtn];
        
        
        
        // 屏幕太小，第三方登录超过登录界面，就另外计算y
        CGFloat wxWidth = 48;
        BOOL isSmall = JX_SCREEN_HEIGHT-JX_SCREEN_TOP - wxWidth - 30 <= CGRectGetMaxY(_btn.frame)+30;
        CGFloat loginY = CGRectGetMaxY(_btn.frame) + 90;
        UIImageView *wxLogin = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH-wxWidth-wxWidth-5)/3, loginY, wxWidth, wxWidth)];
        wxLogin.image = [UIImage imageNamed:@"wechat_icon"];
        wxLogin.userInteractionEnabled = YES;
        //        [self.tableBody addSubview:wxLogin];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didWechatToLogin:)];
        [wxLogin addGestureRecognizer:tap];
        wxLogin.hidden = (_isThirdLogin || self.isSMSLogin);
        if (isSmall) {
            self.tableBody.contentSize = CGSizeMake(0, CGRectGetMaxY(wxLogin.frame)+20);
        }
        //         短信登录
        UIImageView *smsLogin = [[UIImageView alloc] initWithFrame:CGRectMake((JX_SCREEN_WIDTH - wxWidth) / 2, JX_SCREEN_HEIGHT-JX_SCREEN_TOP - wxWidth - 100, wxWidth, wxWidth)];
        smsLogin.image = [UIImage imageNamed:@"sms_login"];
        smsLogin.userInteractionEnabled = YES;
        [self.tableBody addSubview:smsLogin];
        
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.text = @"短信登录";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.frame = CGRectMake(CGRectGetMinX(smsLogin.frame) - 30, CGRectGetMaxY(smsLogin.frame) + 10 , smsLogin.frame.size.width + 60, 20);
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = [UIColor whiteColor];
        [self.tableBody addSubview:titleLabel];
        
        
        //        忘记密码
        UIButton *lbUser = [[UIButton alloc]initWithFrame:CGRectMake((JX_SCREEN_WIDTH-70)*0.5, titleLabel.bottom+20, 70, 20)];
        [lbUser setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [lbUser setTitle:Localized(@"JX_ForgetPassWord") forState:UIControlStateNormal];
        lbUser.titleLabel.font = [UIFont systemFontOfSize:12];
        lbUser.custom_acceptEventInterval = 1.0f;
        [lbUser addTarget:self action:@selector(onForget) forControlEvents:UIControlEventTouchUpInside];
        //        lbUser.titleEdgeInsets = UIEdgeInsetsMake(0, -27, 0, 0);
        [self.tableBody addSubview:lbUser];
        _forgetBtn = lbUser;
        
        smsLogin.hidden = (_isThirdLogin || self.isSMSLogin);
        titleLabel.hidden = (_isThirdLogin || self.isSMSLogin);
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchLoginWay)];
        [smsLogin addGestureRecognizer:tap1];
        
        if (XL_Hidden_MsgLoging == 1) {
            // XL修改
            smsLogin.hidden = YES;
            titleLabel.hidden = YES;
            _forgetBtn.hidden = YES;
        }
        
        
        if ([g_default objectForKey:kMY_USER_NICKNAME])
            _user.userNickname = MY_USER_NAME;
        
        if ([g_default objectForKey:kMY_USER_ID])
            _user.userId = [g_default objectForKey:kMY_USER_ID];
        
        if ([g_default objectForKey:kMY_USER_COMPANY_ID])
            _user.companyId = [g_default objectForKey:kMY_USER_COMPANY_ID];
        
        if ([g_default objectForKey:kMY_USER_LoginName]) {
            [_phone setText:[g_default objectForKey:kMY_USER_LoginName]];
            
            _user.telephone = _phone.text;
        }
        if ([g_default objectForKey:kMY_USER_PASSWORD]) {
            
            _user.password = _pwd.text;
            
        }
        if ([g_default objectForKey:kLocationLogin]) {
            NSDictionary *dict = [g_default objectForKey:kLocationLogin];
            g_server.longitude = [[dict objectForKey:@"longitude"] doubleValue];
            g_server.latitude = [[dict objectForKey:@"latitude"] doubleValue];
        }
        
        
        
        [g_notify addObserver:self selector:@selector(onRegistered:) name:kRegisterNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(authRespNotification:) name:kWxSendAuthRespNotification object:nil];
        
        if(!self.isAutoLogin || IsStringNull(_myToken)) {
            _btn.userInteractionEnabled = YES;
        }else {
            _launchImageView = [[UIImageView alloc] init];
            _launchImageView.frame = self.view.bounds;
            _launchImageView.image = [UIImage imageNamed:[self getLaunchImageName]];
            [self.view addSubview:_launchImageView];
        }
        
        if(self.isAutoLogin && !IsStringNull(_myToken))
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_wait startWithClearColor];
            });
        if (!_isThirdLogin) {
            [g_server getSetting:self];
        }
    }
    return self;
}

//验证手机号格式
- (void)sendSMS{
    if (!_send.selected) {
        _user = [JXUserObject sharedInstance];
        NSString *areaCode = [self getAreaCode];
        _user.areaCode = areaCode;
        [g_server sendSMS:[NSString stringWithFormat:@"%@",_phone.text] areaCode:areaCode isRegister:NO imgCode:_imgCode.text toView:self];
        [_send setTitle:Localized(@"JX_Sending") forState:UIControlStateNormal];
    }
}
//获取当前区号
-(NSString*)getAreaCode{
    if ([self.areaLabel.text containsString:@"+"]) {
        NSRange start = [self.areaLabel.text rangeOfString:@"+"];
        NSRange end = [self.areaLabel.text rangeOfString:@")"];
        NSRange range = NSMakeRange(start.location+start.length, end.location-start.location-start.length);
        NSString *areaCode = [self.areaLabel.text substringWithRange:range];
        return areaCode;
    } else {
        return @"86";
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (_isSMSLogin) {
        [self refreshGraphicAction:_graphicButton];
    }
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == _imgCode) {
    }
}


- (void)switchLoginWay {
    if (self.isSMSLogin) {
        [self actionQuit];
    }else {
        loginVC *vc = [loginVC alloc];
        vc.isSMSLogin = YES;
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
    }
}


-(void)refreshGraphicAction:(UIButton *)button{
    NSString *areaCode = [self getAreaCode];
    [g_server checkPhone:_phone.text areaCode:areaCode verifyType:1 toView:self];
}

-(void)getImgCodeImg{
    if([self isMobileNumber:_phone.text]){
        //请求图片验证码
        NSString *areaCode = [self getAreaCode];
        NSString * codeUrl = [g_server getImgCode:_phone.text areaCode:areaCode];
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:codeUrl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (!connectionError) {
                UIImage * codeImage = [UIImage imageWithData:data];
                _imgCodeImg.image = codeImage;
            }else{
                NSLog(@"%@",connectionError);
                [g_App showAlert:connectionError.localizedDescription];
            }
        }];
    }
    
}

//验证手机号码格式
- (BOOL)isMobileNumber:(NSString *)number{
    if ([g_config.isOpenSMSCode boolValue] && [g_config.regeditPhoneOrName intValue] != 1) {
        if ([_phone.text length] == 0) {
            [g_App showAlert:Localized(@"JX_InputPhone")];
            return NO;
        }
    }
    return YES;
}



#pragma mark - 微信登录
- (void)didWechatToLogin:(UITapGestureRecognizer *)tap {
    
}


- (void)agrBtnAction:(UIButton *)btn {
    
    _checkProtocolBtn.selected = !_checkProtocolBtn.selected;
    [self didSelectedCheckBox:_checkProtocolBtn checked:_checkProtocolBtn.selected];
}

//设置文本框只能输入数字
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (_phone == textField) {
        return [self validateNumber:string];
    }
    return YES;
    
}
- (BOOL)validateNumber:(NSString*)number {
    if ([g_config.regeditPhoneOrName intValue] == 1) {
        // 如果用户名注册选项开启， 则不筛选
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"] invertedSet];
        NSString *filtered = [[number componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [number isEqualToString:filtered];
    }
    BOOL res = YES;
    NSCharacterSet *tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString *string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i ++;
    }
    return res;
    
}

- (void)onSetting {
    
    JXServerListVC *vc = [[JXServerListVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)location:(JXLocation *)location getLocationWithIp:(NSDictionary *)dict {
    if (_isFirstLocation) {
        return;
    }
    NSString *area = [NSString stringWithFormat:@"%@,%@,%@",[dict objectForKey:@"country"],[dict objectForKey:@"region"],[dict objectForKey:@"city"]];
    [g_default setObject:area forKey:kLocationArea];
    [g_default synchronize];
    
    if(self.isAutoLogin && !IsStringNull(_myToken))
        [_wait start:Localized(@"JX_Logining")];
    if (!_isThirdLogin) {
        [g_server getSetting:self];
    }
}

- (void)location:(JXLocation *)location getLocationError:(NSError *)error {
    if (_isFirstLocation) {
        return;
    }
    [g_default setObject:nil forKey:kLocationArea];
    [g_default synchronize];
    
    if(self.isAutoLogin && !IsStringNull(_myToken))
        [_wait start:Localized(@"JX_Logining")];
    if (!_isThirdLogin) {
        [g_server getSetting:self];
    }
}

-(void)longLimit:(UITextField *)textField
{
    
}

-(void)dealloc {
    [g_notify  removeObserver:self name:kRegisterNotifaction object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bgImageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
//    [self.bgImageview setImage:[UIImage imageNamed:@"登录注册_bg_logo"]];
    self.bgImageview.backgroundColor = [UIColor whiteColor];
    self.bgImageview.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.bgImageview];
    self.tableHeader.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tap];
}

- (void)requestDiscoveryWebList {
    
    [g_server getDiscoverWebList:@"" toView:self];
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) textFieldDidChange:(UITextField *) TextField{
    if ([TextField.text isEqualToString:@""]) {
        _pwd.text = @"";
    }
}

-(void)onClick{
    
    //    self.isSwitchUser = NO;
    
    if([_phone.text length]<=0){
        if ([g_config.regeditPhoneOrName intValue] == 1) {
            [g_App showAlert:@"请输入账号"];
        }else {
            [g_App showAlert:Localized(@"JX_InputPhone")];
        }
        return;
    }
    if([_pwd.text length]<=0){
        [g_App showAlert:self.isSMSLogin ? Localized(@"JX_InputMessageCode") : Localized(@"JX_InputPassWord")];
        return;
    }
    [self.view endEditing:YES];
    if (self.isSMSLogin) {
        _user.verificationCode = _pwd.text;
    }else {
        _user.password  = [g_server getMD5String:_pwd.text];
    }
    _user.telephone = _phone.text;
    NSString *areaCode = [self getAreaCode];
    _user.areaCode = areaCode;
    self.isAutoLogin = NO;
    [_wait start:Localized(@"JX_Logining")];
    [g_App.jxServer login:_user toView:self];
}

- (void)actionConfig {
    // 自动登录失败，清除token后，重新赋值一次
    _myToken = [g_default objectForKey:kMY_USER_TOKEN];
    if ([g_config.regeditPhoneOrName intValue] == 1) {
        _areaCodeBtn.hidden = YES;
        self.areaLabel.hidden = YES;
        _forgetBtn.hidden = NO;
        _phone.keyboardType = UIKeyboardTypeDefault;  // 仅支持大小写字母数字
        _phone.placeholder = @"请输入账号";
    }else {
        _areaCodeBtn.hidden = NO;
        self.areaLabel.hidden = YES;
        _phone.keyboardType = UIKeyboardTypeNumberPad;  // 限制只能数字输入，使用数字键盘
        _phone.placeholder = Localized(@"JX_InputPhone");
        // 短信登录界面不显示忘记密码
        _forgetBtn.hidden = self.isSMSLogin;
    }
    
    if ([g_config.isOpenPositionService intValue] == 0) {
        _isFirstLocation = YES;
        _location = [[JXLocation alloc] init];
        _location.delegate = self;
        g_server.location = _location;
        [g_server locate];
    }
    if((self.isAutoLogin && !IsStringNull(_myToken)) || _isThirdLogin)
        if (_isThirdLogin) {
            [g_server thirdLogin:_user type:2 openId:g_server.openId isLogin:NO toView:self];
        }else {
            [self performSelector:@selector(autoLogin) withObject:nil afterDelay:.5];
        }
        else if (IsStringNull(_myToken) && !IsStringNull(_phone.text) && !IsStringNull(_pwd.text)) {
            g_server.isManualLogin = YES;
            [g_App.jxServer login:_user toView:self];
        }
        else
            [_wait stop];
    
    if (XL_Hidden_MsgLoging == 1) {
        // XL修改
        _forgetBtn.hidden = YES;
    }
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    if( [aDownload.action isEqualToString:act_Config]){
        
        [g_config didReceive:dict];
        
        [self actionConfig];
        
    }
    if( [aDownload.action isEqualToString:act_LoginConfig]){
        
        [g_config didReceive:dict];
        
        [self actionConfig];
        [g_App showMainUI];
    }
    if([aDownload.action isEqualToString:act_CheckPhone]){
        [self getImgCodeImg];
    }
    if([aDownload.action isEqualToString:act_SendSMS]){
        [JXMyTools showTipView:Localized(@"JXAlert_SendOK")];
        _send.selected = YES;
        _send.userInteractionEnabled = NO;
        _send.backgroundColor = [UIColor grayColor];
        _smsCode = [[dict objectForKey:@"code"] copy];
        
        [_send setTitle:@"60s" forState:UIControlStateSelected];
        _seconds = 60;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showTime:) userInfo:_send repeats:YES];
    }
    
    //登录成功
    if( [aDownload.action isEqualToString:act_UserLogin] || [aDownload.action isEqualToString:act_thirdLogin] || [aDownload.action isEqualToString:act_sdkLogin]){
        
        if ([aDownload.action isEqualToString:act_thirdLogin] || [aDownload.action isEqualToString:act_sdkLogin]) {
            g_server.openId = nil;
            [g_default setBool:YES forKey:kTHIRD_LOGIN_AUTO];
        }
        else {
            [g_default setBool:NO forKey:kTHIRD_LOGIN_AUTO];
        }
        
        [g_server doLoginOK:dict user:_user];
        
        if(self.isSwitchUser){
            //切换登录，同步好友
            [g_notify postNotificationName:kXmppClickLoginNotifaction object:nil];
            
            // 更新“我”页面
            [g_notify postNotificationName:kUpdateUserNotifaction object:nil];
        }
        else{
            if ([g_myself.telephone isEqualToString:@"13807380000"]) {
                [g_server getSetting:self];
            }else{
                [g_App showMainUI];
            }
            
        }
        
        [self actionQuit];
        
        [g_server getDiscoverWebList:@"" toView:self];
        
        [_wait stop];
    }
    if([aDownload.action isEqualToString:act_userLoginAuto]){
        
        
        
        [g_server doLoginOK:dict user:_user];
        [g_App showMainUI];
        [self actionQuit];
        [g_server getDiscoverWebList:@"" toView:self];
        
        [_wait stop];
    }
    if ([aDownload.action isEqualToString:act_GetWxOpenId]) {
        _launchImageView.hidden = NO;
        g_server.openId = [dict objectForKey:@"openid"];
        [g_server wxSdkLogin:_user type:2 openId:g_server.openId toView:self];
    }
    
    if ([aDownload.action isEqualToString:act_GetDiscoveryWebList]) {
        
        //朋友圈列表
        [g_default setObject:array1 forKey:@"act_GetDiscoveryWebList"];
        g_config.disconverWebArray = array1;
    }
    
    _btn.userInteractionEnabled = YES;
}

- (int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    _btn.userInteractionEnabled = YES;
    _launchImageView.hidden = YES;
    
    if ([aDownload.action isEqualToString:act_Config]) {
        
        NSString *url = [g_default stringForKey:kLastApiUrl];
        g_config.apiUrl = url;
        
        [self actionConfig];
        return hide_error;
    }
    [_wait stop];
    if ([aDownload.action isEqualToString:act_sdkLogin] && [[dict objectForKey:@"resultCode"] intValue] == 1040305) {
        loginVC *login = [loginVC alloc];
        login.isThirdLogin = YES;
        login.isAutoLogin = NO;
        login.isSwitchUser= NO;
        login = [login init];
        [g_navigation pushViewController:login animated:YES];
        return hide_error;
    }
    if ([aDownload.action isEqualToString:act_thirdLogin] && [[dict objectForKey:@"resultCode"] intValue] == 1040306) {
        [self onRegister];
        return hide_error;
    }
    if([aDownload.action isEqualToString:act_userLoginAuto]){
        [g_default removeObjectForKey:kMY_USER_TOKEN];
        [share_defaults removeObjectForKey:kMY_ShareExtensionToken];
    }
    if ([aDownload.action isEqualToString:act_thirdLogin]) {
        g_server.openId = nil;
    }
    
    NSLog(@"%@", dict);
    
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    _btn.userInteractionEnabled = YES;
    _launchImageView.hidden = YES;
    
    if ([aDownload.action isEqualToString:act_Config]) {
        
        // 如果没请求到Config接口，在请求一次
        
        if (error.code == -1009) {
            //没网, 继续请求
            [g_server getSetting:self];
            return hide_error;
        }
        
        if (error == nil) {
            [g_server getSetting:self];
            return hide_error;
        }
        
        
        
        NSString *url = [g_default stringForKey:kLastApiUrl];
        g_config.apiUrl = url;
        
        [self actionConfig];
        return hide_error;
    }
    if([aDownload.action isEqualToString:act_userLoginAuto]){
        [g_default removeObjectForKey:kMY_USER_TOKEN];
        [share_defaults removeObjectForKey:kMY_ShareExtensionToken];
    }
    if ([aDownload.action isEqualToString:act_thirdLogin]) {
        g_server.openId = nil;
    }
    
    [_wait stop];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    
    if([aDownload.action isEqualToString:act_thirdLogin] || [aDownload.action isEqualToString:act_sdkLogin]){
        [_wait start];
    }
}

-(void)onRegister{
    inputPhoneVC* vc = [[inputPhoneVC alloc]init];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)onForget{
    forgetPwdVC* vc = [[forgetPwdVC alloc] init];
    vc.state = 0;
    [g_navigation pushViewController:vc animated:YES];
}

-(void)autoLogin{
    
    _btn.userInteractionEnabled = ![g_server autoLogin:self];
    if (_btn.userInteractionEnabled) {
        _launchImageView.hidden = YES;
    }
}

-(void)onRegistered:(NSNotification *)notifacation{
    [self actionQuit];
    if(!self.isSwitchUser)
        [g_App showMainUI];
}

-(void)actionQuit{
    [super actionQuit];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _phone) {
        [_pwd becomeFirstResponder];
    }else{
        [self.view endEditing:YES];
    }
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.isSMSLogin) {
        if (textField == _phone) {
            [self getImgCodeImg];
        }
    }
}
- (void)areaCodeBtnClick:(UIButton *)but{
    [self.view endEditing:YES];
    JXTelAreaListVC *telAreaListVC = [[JXTelAreaListVC alloc] init];
    telAreaListVC.telAreaDelegate = self;
    telAreaListVC.didSelect = @selector(didSelectTelArea:);
    //    [g_window addSubview:telAreaListVC.view];
    [g_navigation pushViewController:telAreaListVC animated:YES];
}
- (void)didSelectTelArea:(NSDictionary *)areaCode{
    
    NSString *currentLocaleLanguageCode= @"en";
    NSArray *languages = [NSLocale preferredLanguages];
    if (languages.count>0) {
        currentLocaleLanguageCode = languages.firstObject;
        if ([currentLocaleLanguageCode hasPrefix:@"en"]) {
            currentLocaleLanguageCode = @"en";
        }
        else if ([currentLocaleLanguageCode hasPrefix:@"zh"]) {
            currentLocaleLanguageCode = @"zh";
        }
        else {
            currentLocaleLanguageCode = @"en";
        }
    }
    else {
        currentLocaleLanguageCode = @"en";
    }
    if ([currentLocaleLanguageCode hasPrefix:@"zh"]) {
        self.areaLabel.text = [NSString stringWithFormat:@"%@(+%@)",areaCode[@"country"],areaCode[@"prefix"]];
    }else{
        self.areaLabel.text = [NSString stringWithFormat:@"%@(+%@)",areaCode[@"enName"],areaCode[@"prefix"]];
    }
    [self resetBtnEdgeInsets:_areaCodeBtn];
}
- (void)resetBtnEdgeInsets:(UIButton *)btn{
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width-2, 0, btn.imageView.frame.size.width+2)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.frame.size.width+2, 0, -btn.titleLabel.frame.size.width-2)];
}
- (void)passWordRightViewClicked:(UIButton *)but{
    [_pwd resignFirstResponder];
    but.selected = !but.selected;
    _pwd.secureTextEntry = !but.selected;
    
}

- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{
    [g_default setObject:[NSNumber numberWithBool:checked] forKey:@"agreement"];
    [g_default synchronize];
}

-(void)catUserProtocol{
    webpageVC * webVC = [webpageVC alloc];
    webVC.url = [self protocolUrl];
    webVC.isSend = NO;
    webVC = [webVC init];
    [g_navigation.navigationView addSubview:webVC.view];
}

-(NSString *)protocolUrl{
    NSString * protocolStr = g_config.privacyPolicyPrefix;
    NSString * lange = g_constant.sysLanguage;
    if (![lange isEqualToString:ZHHANTNAME] && ![lange isEqualToString:NAME]) {
        lange = ENNAME;
    }
    return [NSString stringWithFormat:@"%@%@.html",protocolStr,lange];
}

// 获取启动图
- (NSString *)getLaunchImageName
{
    NSString *viewOrientation = @"Portrait";
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        viewOrientation = @"Landscape";
    }
    NSString *launchImageName = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    CGSize viewSize = tyCurrentWindow.bounds.size;
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImageName = dict[@"UILaunchImageName"];
        }
    }
    return launchImageName;
}

#pragma mark JXLocationDelegate
- (void)location:(JXLocation *)location CountryCode:(NSString *)countryCode CityName:(NSString *)cityName CityId:(NSString *)cityId Address:(NSString *)address Latitude:(double)lat Longitude:(double)lon{
    g_server.countryCode = countryCode;
    g_server.cityName = cityName;
    g_server.cityId = [cityId intValue];
    g_server.address = address;
    g_server.latitude = lat;
    g_server.longitude = lon;
    
    NSDictionary *dict = @{@"latitude":@(lat),@"longitude":@(lon)};
    
    [g_default setObject:dict forKey:kLocationLogin];
}

-(void)showTime:(NSTimer*)sender{
    UIButton *but = (UIButton*)[_timer userInfo];
    _seconds--;
    [but setTitle:[NSString stringWithFormat:@"%ds",_seconds] forState:UIControlStateSelected];
    
    if(_seconds<=0){
        but.selected = NO;
        but.userInteractionEnabled = YES;
        but.backgroundColor = g_theme.themeColor;
        [_send setTitle:Localized(@"JX_SendAngin") forState:UIControlStateNormal];
        if (_timer) {
            _timer = nil;
            [sender invalidate];
        }
        _seconds = 60;
        
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
