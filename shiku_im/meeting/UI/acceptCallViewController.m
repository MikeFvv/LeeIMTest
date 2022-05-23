//
//  acceptCallViewController.m
//  shiku_im
//
//  Created by MacZ on 2017/8/7.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "acceptCallViewController.h"
#import "JXCustomButton.h"
#import "JXAVCallViewController.h"

#import "MJExtension.h"

@interface acceptCallViewController ()
@property (strong, nonatomic) UIView *viewTop;
@property (strong, nonatomic) UIImageView *headerImage;
@property (strong, nonatomic) UILabel *labelStatus;
@property (strong, nonatomic) UILabel *labelRemoteParty;
@property (strong, nonatomic) UIView *viewCenter;

@property (strong, nonatomic) UIImageView *imageSecure;

@property (strong, nonatomic) UIView *viewBottom;
@property (strong, nonatomic) UIButton *buttonHangup;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int timerNum;


@end

#define Button_Width 80
#define Button_Height (Button_Width+20)
#define BtnImage_big 70
#define BtnImage_small 34

@implementation acceptCallViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.isGotoBack = YES;
        self.heightHeader = 0;
        self.heightFooter = 0;
        self.view.frame = g_window.bounds;
        [self createHeadAndFoot];
        [self customView];
        JXUserObject *user = [[JXUserObject sharedInstance] getUserById:self.toUserId];
        if ([user.offlineNoPushMsg intValue] != 1) {
            _player = [[JXAudioPlayer alloc]init];
            _player.audioFile = [NSString stringWithFormat:@"%@dial.m4a",imageFilePath];
            [_player open];
            [_player play];
            _player.player.numberOfLoops = 10000;
        }
        
        g_meeting.isMeeting = YES;
        [g_notify addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsgNotifaction object:nil];
        [g_notify addObserver:self selector:@selector(callAnswerNotification:) name:kCallAnswerNotification object:nil];
        [g_notify addObserver:self selector:@selector(callEndNotification:) name:kCallEndNotification object:nil];
        
    }
    return self;
}

-(void)callAnswerNotification:(NSNotification *)notifacation{
    [self doInCall];
}

- (void)doInCall {
    NSLog(@"callAnswer - callView");
    
//    [g_server getAgoraInfo:self fileName:self.meetUrl];
    if (g_meeting.hasAnswer) {
        g_meeting.hasAnswer = NO;
        JXAVCallViewController *avVC = [[JXAVCallViewController alloc] init];
        if([self.type intValue] == kWCMessageTypeAudioMeetingInvite || [self.type intValue] == kWCMessageTypeAudioChatAsk){
            avVC.isAudio = YES;
            
        }
        
        if([self.type intValue] == kWCMessageTypeAudioMeetingInvite || [self.type intValue] == kWCMessageTypeVideoMeetingInvite){
            avVC.isGroup = YES;
            avVC.roomNum = self.roomNum;
        }else if ([self.type intValue] == kWCMessageTypeAudioChatAsk) {
            
            avVC.roomNum = self.roomNum;
            [g_meeting sendAccept:kWCMessageTypeAudioChatAccept toUserId:self.toUserId toUserName:self.toUserName];
        }else if ([self.type intValue] == kWCMessageTypeVideoChatAsk) {
            
            avVC.roomNum = self.roomNum;
            [g_meeting sendAccept:kWCMessageTypeVideoChatAccept toUserId:self.toUserId toUserName:self.toUserName];
        }
        avVC.toUserId = self.toUserId;
        avVC.toUserName = self.toUserName;
        avVC.model = self.model;
        avVC.view.frame = [UIScreen mainScreen].bounds;
        
        [g_window addSubview:avVC.view];
        
        
        [_player stop];
        _player = nil;
        [self actionQuit];
    }
    

}


-(void)callEndNotification:(NSNotification *)notifacation{
    
    [self onCancel];
}

- (void) customView {
    self.tableBody.backgroundColor = HEXCOLOR(0x1F2025);
    
    //viewHeader viewTop
    _viewTop = [[UIView alloc] init];
    _viewTop.frame = CGRectMake(0, 40, JX_SCREEN_WIDTH, 86);
    _viewTop.userInteractionEnabled = YES;
    _viewTop.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 - 100);
    [self.tableBody addSubview:_viewTop];
    
    _headerImage = [[UIImageView alloc] init];
    _headerImage.frame = CGRectMake(10, 0, 86, 86);
    _headerImage.userInteractionEnabled = YES;
    _headerImage.layer.cornerRadius = _headerImage.frame.size.width / 2;
    _headerImage.layer.masksToBounds = YES;
    _headerImage.center = CGPointMake(_viewTop.frame.size.width / 2, _viewTop.frame.size.height / 2);
    [g_server getHeadImageLarge:self.toUserId imageView:_headerImage];
    [_viewTop addSubview:_headerImage];
    
    _labelRemoteParty = [[UILabel alloc] init];
    _labelRemoteParty.frame = CGRectMake(0, CGRectGetMaxY(_headerImage.frame) + 10, _viewTop.frame.size.width, 43);
    _labelRemoteParty.textColor = [UIColor whiteColor];
    _labelRemoteParty.font = [UIFont systemFontOfSize:36];
    _labelRemoteParty.textAlignment = NSTextAlignmentCenter;
    _labelRemoteParty.text = self.toUserName;
    _labelRemoteParty.center = CGPointMake(_viewTop.frame.size.width / 2, _labelRemoteParty.center.y);
    [_viewTop addSubview:_labelRemoteParty];
    
    _labelStatus = [[UILabel alloc] init];
    _labelStatus.frame = CGRectMake(0, CGRectGetMaxY(_labelRemoteParty.frame) + 10, _viewTop.frame.size.width, 29);
    _labelStatus.textColor = [UIColor whiteColor];
    _labelStatus.font = [UIFont systemFontOfSize:14];
    _labelStatus.textAlignment = NSTextAlignmentCenter;
    _labelStatus.text = self.title;
    _labelStatus.center = CGPointMake(_viewTop.frame.size.width / 2, _labelStatus.center.y);
    [_viewTop addSubview:_labelStatus];
    
    
    //viewFooter viewBottom
    _viewBottom = [[UIView alloc] init];
    _viewBottom.frame = CGRectMake(0, JX_SCREEN_HEIGHT*3.2/5, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT/2);
    _viewBottom.userInteractionEnabled = YES;
    [self.tableBody addSubview:_viewBottom];
    
    CGFloat margX = 20;
    CGFloat margWidth = (JX_SCREEN_WIDTH-(4*Button_Width+margX*2))/3;
    
    _buttonHangup = [self createBottomButtonWithImage:@"hangup" SelectedImg:nil selector:@selector(onCancel) btnWidth:Button_Width imageWidth:BtnImage_big];
    [_buttonHangup setTitle:Localized(@"JXMeeting_Hangup") forState:UIControlStateNormal];
    _buttonHangup.frame = CGRectMake(JX_SCREEN_WIDTH/4 - (Button_Width/2)-5, JX_SCREEN_HEIGHT/4 - (Button_Height/2)-5-20, Button_Width, Button_Height);
    
    //
    _buttonAccept = [self createBottomButtonWithImage:@"accept" SelectedImg:nil selector:@selector(onAcceptCall) btnWidth:Button_Width imageWidth:BtnImage_big];
    [_buttonAccept setTitle:Localized(@"JXMeeting_Accept") forState:UIControlStateNormal];
    _buttonAccept.frame = CGRectMake(JX_SCREEN_WIDTH*3/4 - (Button_Width/2)-5, JX_SCREEN_HEIGHT/4 - (Button_Height/2)-5-20, Button_Width, Button_Height);
    self.tableBody.contentSize = CGSizeMake(0, 0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self doInCall];
    });
}

// 30秒无响应 自动挂断
- (void)timerAction:(NSTimer *)timer {
    _timerNum ++;
    NSLog(@"timerNum = %d", _timerNum);
    if (_timerNum > 30) {
        [timer invalidate];
        timer = nil;
        _timerNum = 0;
        [self onCancel];
    }
}

-(JXCustomButton *)createBottomButtonWithImage:(NSString *)Image SelectedImg:(NSString *)selectedImage selector:(SEL)selector btnWidth:(CGFloat)btnWidth imageWidth:(CGFloat)imageWidth{
    JXCustomButton * button = [JXCustomButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:Image] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
    
    [button.titleLabel setFont:g_factory.font12];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    button.titleRect = CGRectMake(0, imageWidth+(btnWidth-imageWidth)/2, btnWidth, 20);
    button.imageRect = CGRectMake((btnWidth-imageWidth)/2, (btnWidth-imageWidth)/2, imageWidth, imageWidth);
    if (selector)
        [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [_viewBottom addSubview:button];
    return button;
}

#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation{
    
    JXMessageObject *msg = (JXMessageObject *)notifacation.object;
    if ([msg.type intValue] == kWCMessageTypeAudioChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatEnd || [msg.type intValue] == kWCMessageTypeAudioChatEnd) {
        [_player stop];
        _player = nil;
        g_meeting.isMeeting = NO;
        [self actionQuit];
        [g_App endCall];
    }
    
    
    // 多点登录处理
    if ([msg.fromUserId isEqualToString:MY_USER_ID]) {
        if([msg.type intValue] == kWCMessageTypeAudioChatAccept){
            [_player stop];
            _player = nil;
            g_meeting.isMeeting = NO;
            [self actionQuit];
            [g_App endCall];
            
        }else if ([msg.type intValue] == kWCMessageTypeVideoChatAccept) {
            [_player stop];
            _player = nil;
            g_meeting.isMeeting = NO;
            [self actionQuit];
            [g_App endCall];
        }
        
        if ([msg.type intValue] == kWCMessageTypeAudioChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatCancel) {
            [_player stop];
            _player = nil;
            g_meeting.isMeeting = NO;
            [self actionQuit];
            [g_App endCall];
        }
    }
    
    
}

-(void)dealloc{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onAcceptCall{
    
    
    [g_server getAgoraInfo:self fileName:self.meetUrl];

}

-(void)onCancel{
    [_player stop];
    _player = nil;
    g_meeting.hasAnswer = NO;
    g_meeting.isMeeting = NO;
    [g_App endCall];
    if (self.isGroup) {
        [self actionQuit];
        return;
    }
    
    int n;
    if([self.type intValue] == kWCMessageTypeAudioChatAsk)
        n = kWCMessageTypeAudioChatCancel;
    else
        n = kWCMessageTypeVideoChatCancel;
    [g_meeting sendNoAnswer:n toUserId:self.toUserId toUserName:self.toUserName];
    [self actionQuit];
}



-(void)actionQuit{
    [g_notify removeObserver:self];//移除监听
    [_timer invalidate];
    _timer = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [super actionQuit];
    });
}
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    
    self.model = [AgoraModel mj_objectWithKeyValues:dict ];
    [_player stop];
    _player = nil;
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didTouch])
        [self.delegate performSelectorOnMainThread:self.didTouch withObject:self waitUntilDone:NO];
    [self actionQuit];

}
@end
