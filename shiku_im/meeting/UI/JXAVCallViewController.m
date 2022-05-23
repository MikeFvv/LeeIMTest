//
//  JXAVCallViewController.m
//  shiku_im
//
//  Created by p on 2017/12/26.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXAVCallViewController.h"
#import "JXMediaObject.h"
#import <ReplayKit/ReplayKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "JXCustomButton.h"
#import "UIView+Frame.h"

@interface JXAVCallViewController ()<AgoraRtcEngineDelegate>

@property (strong, nonatomic) UIView *viewTop;
@property (strong, nonatomic) UIImageView *headerImage;
@property (strong, nonatomic) UILabel *labelStatus;
@property (strong, nonatomic) UILabel *labelRemoteParty;
@property (strong, nonatomic) UIView *viewCenter;
@property (strong, nonatomic) UIImageView *imageSecure;

@property (strong, nonatomic) UIView *viewBottom;
@property (strong, nonatomic) UIButton *buttonHangup;

@property (nonatomic, assign) NSTimeInterval startTime;

@property (nonatomic, strong) UIView *localVideoView;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIButton *suspensionBtn;
@property (nonatomic, strong) UILabel *suspensionLabel;
@property (nonatomic, assign) CGRect subWindowFrame;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int timerIndex;
@property (nonatomic, strong) UIButton *recorderBtn;
@property (nonatomic, strong) RPPreviewViewController *previewVC;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, strong)AgoraRtcEngineKit *agorakit;
//@property (nonatomic, strong)JXAVCallVideoView *videoView;

@property (nonatomic, strong)UIView *videoBackView;
@property (nonatomic, strong)UIView *remoteVideo;
@property (nonatomic, strong)UIImageView *remoteVideoMutedIndicator;
@property (nonatomic, strong)UIView *localVideo;
@property (nonatomic, strong)UIView *localVideoMutedIndicator;
@property (nonatomic, strong)UIButton *muteButton;
@property (nonatomic, strong)UIButton *hangUpButton;
@property (nonatomic, strong)UIButton *switchCameraButton;
@end


#define Button_Width 80
#define Button_Height (Button_Width+20)
#define BtnImage_big 70
#define BtnImage_small 34

@implementation JXAVCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (_pSelf) {
        return;
    }
    self.view.backgroundColor = HEXCOLOR(0x1F2025);
    g_meeting.isMeeting = YES;

    _pSelf = self;
    [self createSuspensionView];
    
    ZKWeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{


        BOOL audioMuted = NO;
        BOOL videoMuted = NO;
        NSString *serverStr;
        if (self.isGroup) {
            serverStr = g_config.jitsiServer;
        }else {
            if ([g_config.isOpenCluster integerValue] == 1 && [self.meetUrl length] > 0) {
                serverStr = self.meetUrl;
            }else {
                serverStr = g_config.jitsiServer;
            }
        }
        NSString *url = [NSString stringWithFormat:@"%@%@",serverStr,self.roomNum];
        if (self.isAudio && self.isGroup) {
            url = [NSString stringWithFormat:@"%@audio%@",serverStr,self.roomNum];
        }
        if (self.isAudio) {
            videoMuted = YES;
        }
        if (!_toUserName) {
            _toUserName = self.roomNum;
        }
//        [view loadURLObject:@{
//                              @"config": @{
//                                      @"startWithAudioMuted": [NSNumber numberWithBool:audioMuted],
//                                      @"startWithVideoMuted": [NSNumber numberWithBool:videoMuted]
//                                      },
//                              @"nickName" : _toUserName,
//                              @"isCallKit" : g_App.uuid ? @NO : @YES,
//                              @"url": url
//
//
//                              }];
        
//        [self creatLocalVideoView];
        [self initializeAgoraEngine];
        if (!_isAudio) {
//            JXAVCallVideoView *callVideoView = [JXAVCallVideoView loadNib];
//            callVideoView.frame = [UIScreen mainScreen].bounds;
//            callVideoView.delegate = self;
//            self.videoView = callVideoView;
//            [self.view addSubview:self.videoView];
            [self customView];
            [self setupVideo];
            [self setLocalVideo];
            

        }
        [self joinChannel];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 30, 38, 38)];
        [btn setImage:[UIImage imageNamed:@"callHide"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(hideAudioView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        /*
        _recorderBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(btn.frame) + 20, 38, 60)];
        [_recorderBtn setTitle:Localized(@"JX_Recording") forState:UIControlStateNormal];
        [_recorderBtn setTitle:Localized(@"STOP_IT") forState:UIControlStateSelected];
        [_recorderBtn setImage:[UIImage imageNamed:@"recording"] forState:UIControlStateNormal];
        [_recorderBtn setImage:[UIImage imageNamed:@"stoped"] forState:UIControlStateSelected];
        [_recorderBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 22, 0)];
        [_recorderBtn setTitleEdgeInsets:UIEdgeInsetsMake(30, -60, 0, 0)];
        [_recorderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_recorderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_recorderBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        _recorderBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_recorderBtn addTarget:self action:@selector(recorderBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_recorderBtn];
         */
    });
    
    [g_notify addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsgNotifaction object:nil];
    [g_notify addObserver:self selector:@selector(callEndNotification:) name:kCallEndNotification object:nil];

    _startTime = 0;
    [self networkStatusChange];
    

    
     
}
- (void)initializeAgoraEngine{
   
   self.agorakit = [AgoraRtcEngineKit sharedEngineWithAppId:self.model.appId delegate:self];
}
- (void)joinChannel{
   ZKWeakSelf
   [self.agorakit joinChannelByToken:self.model.ownToken channelId:self.model.channel info:nil uid:[MY_USER_ID integerValue] joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
       
       
       NSLog(@"join");
       [weakSelf.agorakit setEnableSpeakerphone:YES];
       dispatch_async(dispatch_get_main_queue(), ^{
           _startTime = [[NSDate date] timeIntervalSince1970];
           
           weakSelf.timerIndex = 0;
           // 通话计时
           weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(callTimerAction:) userInfo:nil repeats:YES];
           weakSelf.session = nil;
           weakSelf.localVideoView.hidden = YES;
           [weakSelf.previewLayer removeFromSuperlayer];
           [weakSelf.localVideoView removeFromSuperview];
           weakSelf.localVideoView = nil;
           if (weakSelf.isAudio) {
               [weakSelf customView];
           }else{
              
               weakSelf.remoteVideoMutedIndicator.hidden  = YES;
               weakSelf.localVideoMutedIndicator.hidden = YES;
           }
           
       });
//      [weakSelf.agorakit setEnableSpeakerphone:YES];
//      [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
   }];
   
}
- (void)onCancel{
    
    ZKWeakSelf
    [self.agorakit leaveChannel:^(AgoraChannelStats * _Nonnull stat) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //        _startTime = [[NSDate date] timeIntervalSince1970];
            if (!self.isGroup) {
    //        int n = [[NSDate date] timeIntervalSince1970]-_startTime;
            int type = kWCMessageTypeVideoChatEnd;
            if (self.isAudio) {
                type = kWCMessageTypeAudioChatEnd;
            }
            [g_meeting sendEnd:type toUserId:self.toUserId toUserName:self.toUserName timeLen:self.timerIndex];
        }
            [self actionQuit];
            weakSelf.session = nil;
            weakSelf.localVideoView.hidden = YES;
            [weakSelf.previewLayer removeFromSuperlayer];
            [weakSelf.localVideoView removeFromSuperview];
            [weakSelf.videoBackView removeFromSuperview];
            weakSelf.localVideoView = nil;
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        });
    }];

    
}
- (void)setupVideo{
    
    [self.agorakit enableVideo];
    AgoraVideoEncoderConfiguration *configuration = [[AgoraVideoEncoderConfiguration alloc]initWithSize:AgoraVideoDimension640x360 frameRate:AgoraVideoFrameRateFps15 bitrate:AgoraVideoBitrateStandard orientationMode:AgoraVideoOutputOrientationModeAdaptative];
    
    [self.agorakit setVideoEncoderConfiguration:configuration];
    
}
- (void)setLocalVideo{
    
    AgoraRtcVideoCanvas*canvas = [[AgoraRtcVideoCanvas alloc]init];
    canvas.uid = [MY_USER_ID integerValue];
    canvas.view = self.localVideo;
    canvas.renderMode = AgoraVideoRenderModeHidden;
    [self.agorakit setupLocalVideo:canvas];
}
- (void) customView {
  
    if (_isAudio) {
        //viewHeader viewTop
        _viewTop = [[UIView alloc] init];
        _viewTop.frame = CGRectMake(0, 40, JX_SCREEN_WIDTH, 86);
        _viewTop.userInteractionEnabled = YES;
        _viewTop.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 - 100);
        [self.view addSubview:_viewTop];
        
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
        [self.view addSubview:_viewBottom];
        
        CGFloat margX = 20;
    //    CGFloat margWidth = (JX_SCREEN_WIDTH-(4*Button_Width+margX*2))/3;
        
        _buttonHangup = [self createBottomButtonWithImage:@"hangup" SelectedImg:nil selector:@selector(onCancel) btnWidth:Button_Width imageWidth:BtnImage_big];
        [_buttonHangup setTitle:Localized(@"JXMeeting_Hangup") forState:UIControlStateNormal];
        _buttonHangup.frame = CGRectMake((JX_SCREEN_WIDTH - Button_Width)*0.5, JX_SCREEN_HEIGHT/4 - (Button_Height/2)-5-20, Button_Width, Button_Height);
        
        UIButton *muteButton = [UIButton buttonWithType:0];
        [muteButton setImage:[UIImage imageNamed:@"mic"] forState:0];
        [muteButton setImage:[UIImage imageNamed:@"mute"] forState:UIControlStateSelected];
        muteButton.frame  = CGRectMake(_buttonHangup.left-28-80, _buttonHangup.top, 80, 80);
        [muteButton addTarget:self action:@selector(muteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_viewBottom addSubview:muteButton];
        self.muteButton = muteButton ;
        
        UIButton *switchSpeakerButton= [UIButton buttonWithType:0];
         [switchSpeakerButton setImage:[UIImage imageNamed:@"btn_speaker"] forState:0];
        [switchSpeakerButton setImage:[UIImage imageNamed:@"btn_speaker_blue"] forState:UIControlStateSelected];
         switchSpeakerButton.frame  = CGRectMake(_buttonHangup.right+28, _buttonHangup.top+5, 70, 70);
         [switchSpeakerButton addTarget:self action:@selector(speakerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
         [_viewBottom addSubview:switchSpeakerButton];
         
        
            
    }else{
        
        UIView *videoBackView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [self.view addSubview:videoBackView];
        self.videoBackView = videoBackView;
        
        UIView *remoteVideo = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        remoteVideo.backgroundColor = HEXCOLOR(0x484258);
        [videoBackView addSubview:remoteVideo];
        self.remoteVideo = remoteVideo;
        
        UIImageView *remoteVideoMutedIndicator = [[UIImageView alloc]initWithFrame:CGRectMake((JX_SCREEN_WIDTH-100)*0.5, (JX_SCREEN_HEIGHT-100)*0.5, 100, 100)];
        remoteVideoMutedIndicator.image =[UIImage imageNamed:@"big_logo"];
        [videoBackView addSubview:remoteVideoMutedIndicator];
        self.remoteVideoMutedIndicator = remoteVideoMutedIndicator;
        
        UIView *localVideo = [[UIView alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-85-25, 36, 85, 113.5)];
        localVideo.backgroundColor = HEXCOLOR(0x827B92);
        [videoBackView addSubview:localVideo];
        self.localVideo = localVideo;
        
//        UIView *localVideoMutedIndicator = [[UIView alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH-85-25, 36, 85, 113.5)];
//        localVideoMutedIndicator.backgroundColor = HEXCOLOR(0x827B92);
//        [videoBackView addSubview:localVideoMutedIndicator];
//        self.localVideoMutedIndicator = localVideoMutedIndicator;
//
//        UIImageView *localVideoImage = [[UIImageView alloc]initWithFrame:CGRectMake((85-36)*0.5, (113.5-36)*0.5, 36, 36)];
//        localVideoImage.image = [UIImage imageNamed:@"logo"];
//        [localVideoMutedIndicator addSubview:localVideo];
        
        UIButton *hangUpButton  = [UIButton buttonWithType:0];
        [hangUpButton setImage:[UIImage imageNamed:@"end"] forState:0];
        hangUpButton.frame  = CGRectMake((JX_SCREEN_WIDTH-80)*0.5, JX_SCREEN_HEIGHT-80-45, 80, 80);
        [hangUpButton addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
        [videoBackView addSubview:hangUpButton];
        self.hangUpButton = hangUpButton;
        
        UIButton *muteButton = [UIButton buttonWithType:0];
        [muteButton setImage:[UIImage imageNamed:@"mic"] forState:0];
        [muteButton setImage:[UIImage imageNamed:@"mute"] forState:UIControlStateSelected];
        muteButton.frame  = CGRectMake(hangUpButton.left-28-80, hangUpButton.top, 80, 80);
        [muteButton addTarget:self action:@selector(muteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [videoBackView addSubview:muteButton];
        self.muteButton = muteButton ;
        
        UIButton *switchCameraButton= [UIButton buttonWithType:0];
        [switchCameraButton setImage:[UIImage imageNamed:@"switch"] forState:0];
        switchCameraButton.frame  = CGRectMake(hangUpButton.right+28, hangUpButton.top, 80, 80);
        [switchCameraButton addTarget:self action:@selector(cameraBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [videoBackView addSubview:switchCameraButton];
        self.switchCameraButton = switchCameraButton;
    }

    //

}

- (void)recorderBtnAction:(UIButton *)btn {

    if (!btn.selected) {
        self.isRecording = NO;
        //如果还没有开始录制，判断系统是否支持
        if ([RPScreenRecorder sharedRecorder].isAvailable && [[UIDevice currentDevice].systemVersion floatValue] > 9.0) {
            //如果支持，就使用下面的方法可以启动录制回放
            [btn setTitle:Localized(@"JX_Opening") forState:UIControlStateDisabled];
            btn.enabled = NO;
            [self startRecord];

        } else {
            [JXMyTools showTipView:Localized(@"JX_NotScreenRecording")];
        }
    }else {
        [btn setTitle:Localized(@"JX_Stopping") forState:UIControlStateDisabled];
        btn.enabled = NO;
        [self stopRecord];
    }
}

- (void)startRecord {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.isRecording) {

            [self startRecord];
        }
    });
    NSLog(@"recorder -- OK");
    [[RPScreenRecorder sharedRecorder] startRecordingWithMicrophoneEnabled:YES handler:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
        if (!error) {
            NSLog(@"recorder -- 已开启");
            self.isRecording = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                _recorderBtn.enabled = YES;
                _recorderBtn.selected = YES;
            });
        }
        //处理发生的错误，如设用户权限原因无法开始录制等
    }];
}

- (void)stopRecord {
    dispatch_async(dispatch_get_main_queue(), ^{

        NSLog(@"stopRecord");

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.isRecording) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    _recorderBtn.enabled = YES;
                    _recorderBtn.selected = NO;
                });

                [JXMyTools showTipView:@"录屏失败，请重新录制"];

//                [self stopRecord];
            }
        });

        //停止录制回放，并显示回放的预览，在预览中用户可以选择保存视频到相册中、放弃、或者分享出去
        [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
            _previewVC = previewViewController;

            self.isRecording = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                _recorderBtn.enabled = YES;
                _recorderBtn.selected = NO;
            });

            NSLog(@"recorder -- stop");
            if (error) {
                NSLog(@"recorder -- errro:%@", error);
                //处理发生的错误，如磁盘空间不足而停止等
            }else {
                NSURL *url = [_previewVC valueForKey:@"movieURL"];


//                [[NSFileManager defaultManager] copyItemAtURL:url toURL:[NSURL URLWithString:str] error:nil];
////                [[NSFileManager defaultManager] moveItemAtURL:url toURL:[NSURL URLWithString:str] error:nil];
//
//                NSString *str = [FileInfo getUUIDFileName:@"mp4"];
//                JXMediaObject* p = [[JXMediaObject alloc]init];
//                p.userId = g_server.myself.userId;
//                p.fileName = str;
//                p.isVideo = [NSNumber numberWithBool:YES];
//                //                    p.timeLen = [NSNumber numberWithInteger:timeLen];
//                [p insert];

                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error) {
                    
                    if (error) {
                        [JXMyTools showTipView:Localized(@"JX_SaveFiled")];
                    }else {
                        [JXMyTools showTipView:Localized(@"JX_SaveSuessed")];
                    }
                }];

//                if (_previewVC) {
//                    //设置预览页面到代理
//                    _previewVC.previewControllerDelegate = self;
//
//                    [g_window addSubview:_previewVC.view];
//                    [g_navigation.subViews.lastObject presentViewController:previewViewController animated:YES completion:nil];
//                }

            }

        }];
    });
}

- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController {
    ZKWeakSelf
    [self.agorakit leaveChannel:^(AgoraChannelStats *stat) {
         [weakSelf dismissViewControllerAnimated:YES completion:nil];
     }];
}

- (void)creatLocalVideoView {
    
    self.localVideoView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.localVideoView.backgroundColor = HEXCOLOR(0x1F2025);
    [g_window addSubview:self.localVideoView];
    
    // 获取需要的设备
    AVCaptureDevice *device =  [self cameraWithPosition:AVCaptureDevicePositionFront];
    if (self.isAudio || !device) {
        
        UIImageView *headImage = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH / 2 - 50, JX_SCREEN_HEIGHT / 2 - 110, 100, 100)];
        headImage.layer.cornerRadius = headImage.frame.size.width / 2;
        headImage.layer.masksToBounds = YES;
        headImage.image = [UIImage imageNamed:@"酷聊120"];
        [self.localVideoView addSubview:headImage];
        
    }else {
        NSError *error = nil;
        
        // 初始化会话
        _session = [[AVCaptureSession alloc] init];
        
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                            error:&error];
        [_session addInput:input];
        [_session startRunning];
        
        //预览层的生成，实时获取摄像头数据
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
        self.previewLayer.frame = [UIScreen mainScreen].bounds;
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.localVideoView.layer addSublayer:self.previewLayer];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT / 2, JX_SCREEN_WIDTH, 20)];
    label.font = g_factory.font17;
    label.text = Localized(@"JX_Connection");
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.localVideoView addSubview:label];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

- (void)createSuspensionView {
    _suspensionBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 100)];
    _suspensionBtn.backgroundColor = [UIColor whiteColor];
    _suspensionBtn.layer.cornerRadius = 2.0;
    _suspensionBtn.layer.masksToBounds = YES;
    _suspensionBtn.layer.borderWidth = 0.5;
    _suspensionBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    [_suspensionBtn addTarget:self action:@selector(showAudioView) forControlEvents:UIControlEventTouchUpInside];
    g_subWindow.frame = CGRectMake(JX_SCREEN_WIDTH - 80 - 10, 50, _suspensionBtn.frame.size.width, _suspensionBtn.frame.size.height);
    g_subWindow.backgroundColor = [UIColor cyanColor];
    [g_subWindow addSubview:_suspensionBtn];
    g_subWindow.hidden = YES;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [g_subWindow addGestureRecognizer:pan];
    
    UIImageView *suspensionImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    suspensionImage.image = [UIImage imageNamed:@"callShow"];
    suspensionImage.center = CGPointMake(_suspensionBtn.frame.size.width / 2, _suspensionBtn.frame.size.height / 2 - 10);
    [_suspensionBtn addSubview:suspensionImage];
    
    _suspensionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(suspensionImage.frame) + 5, _suspensionBtn.frame.size.width, 20)];
    _suspensionLabel.textColor = THEMECOLOR;
    _suspensionLabel.textAlignment = NSTextAlignmentCenter;
    _suspensionLabel.font = g_factory.font13;
    _suspensionLabel.text = @"00:00";
    [_suspensionBtn addSubview:_suspensionLabel];
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.subWindowFrame = g_subWindow.frame;
    }
    CGPoint offset = [pan translationInView:g_App.window];
    CGPoint offset1 = [pan translationInView:g_subWindow];
    NSLog(@"pan - offset = %@, offset1 = %@", NSStringFromCGPoint(offset), NSStringFromCGPoint(offset1));
    
    CGRect frame = self.subWindowFrame;
    frame.origin.x += offset.x;
    frame.origin.y += offset.y;
    g_subWindow.frame = frame;
    
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        if (frame.origin.x <= JX_SCREEN_WIDTH / 2) {
            frame.origin.x = 10;
        }else {
            frame.origin.x = JX_SCREEN_WIDTH - frame.size.width - 10;
        }
        if (frame.origin.y < 0) {
            frame.origin.y = 10;
        }
        if ((frame.origin.y + frame.size.height) > JX_SCREEN_HEIGHT) {
            frame.origin.y = JX_SCREEN_HEIGHT - frame.size.height - 10;
        }
        [UIView animateWithDuration:0.5 animations:^{
            
            g_subWindow.frame = frame;
        }];
    }
}
- (void)callTimerAction:(NSTimer *)timer {
    self.timerIndex ++;
    NSString *str = [NSString stringWithFormat:@"%.2d:%.2d", self.timerIndex / 60,self.timerIndex % 60];
    self.suspensionLabel.text = str;
}

- (void)hideAudioView {
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, self.view.frame.size.width, 0);
    } completion:^(BOOL finished) {
        g_subWindow.hidden = NO;
        self.view.hidden = YES;
    }];
}

- (void)showAudioView {
    g_subWindow.hidden = YES;
    self.view.hidden = NO;
    self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, self.view.frame.size.width, 0);
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
    }];
}

-(void)newMsgCome:(NSNotification *)notifacation{
   
    JXMessageObject *msg = (JXMessageObject *)notifacation.object;
    
     
    if ([msg.type intValue] == kWCMessageTypeVideoChatEnd || [msg.type intValue] == kWCMessageTypeAudioChatEnd || [msg.type intValue] == kWCMessageTypeAudioChatCancel || [msg.type intValue] == kWCMessageTypeVideoChatCancel) {
        if ([msg.fromUserId isEqualToString:self.toUserId]) {
            [self actionQuit];
        }
    }
}

// 监听网络状态
- (void)networkStatusChange {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            [self actionQuit];
        }
    }];
}

-(void)callEndNotification:(NSNotification *)notifacation{
    if (self.timerIndex == 5) {
        return;
    }
    if (!self.isGroup) {
        //        int n = [[NSDate date] timeIntervalSince1970]-_startTime;
        int type = kWCMessageTypeVideoChatEnd;
        if (self.isAudio) {
            type = kWCMessageTypeAudioChatEnd;
        }
        [g_meeting sendEnd:type toUserId:self.toUserId toUserName:self.toUserName timeLen:self.timerIndex];
    }
    [self actionQuit];
}


-(void)muteBtnClick:(UIButton *)btn{
    
    btn.selected = !btn.selected;
    if (_isAudio) {
        [self.agorakit muteLocalAudioStream:btn.selected];
    }else{
        [self.agorakit muteLocalVideoStream:btn.selected];
    }
}
-(void)cameraBtnClick{
    
    [self.agorakit switchCamera];
    
}

-(void)speakerBtnClick:(UIButton *)btn{
    
    btn.selected = !btn.selected;
    [self.agorakit setEnableSpeakerphone:btn.selected];
    
}
#pragma mark- <AgoraRtcEngineDelegate>


 
-(void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoFrameOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed{
    

}
// self joined success
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString*)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed {


}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    NSLog(@"Uid");
//    [self appendInfoToTableViewWithInfo:[NSString stringWithFormat:@"Uid:%lu joined channel with elapsed:%ld", (unsigned long)uid, (long)elapsed]];
    AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc]init];
     canvas.uid = uid;
     canvas.view = self.remoteVideo;
     canvas.renderMode = AgoraVideoRenderModeHidden;
     [self.agorakit setupRemoteVideo:canvas];
}

- (void)rtcEngineConnectionDidInterrupted:(AgoraRtcEngineKit *)engine {
     NSLog(@"Interrupt");
    NSLog(@"%@",engine);
//    [self appendInfoToTableViewWithInfo:@"ConnectionDidInterrupted"];
}

- (void)rtcEngineConnectionDidLost:(AgoraRtcEngineKit *)engine {
    NSLog(@"Lost");
//    [self appendInfoToTableViewWithInfo:@"ConnectionDidLost"];
    ZKWeakSelf
    [self.agorakit leaveChannel:^(AgoraChannelStats * _Nonnull stat) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
        //        _startTime = [[NSDate date] timeIntervalSince1970];
                weakSelf.session = nil;
                weakSelf.localVideoView.hidden = YES;
                [weakSelf.previewLayer removeFromSuperlayer];
                [weakSelf.localVideoView removeFromSuperview];
                weakSelf.localVideoView = nil;
                [weakSelf.videoBackView removeFromSuperview];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
    }];

}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraErrorCode)errorCode {
    NSLog(@"Error");
//    [self appendInfoToTableViewWithInfo:[NSString stringWithFormat:@"Error Code:%ld", (long)errorCode]];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    NSLog(@"Offline");
    ZKWeakSelf
    [self.agorakit leaveChannel:^(AgoraChannelStats * _Nonnull stat) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
        //        _startTime = [[NSDate date] timeIntervalSince1970];
                weakSelf.session = nil;
                weakSelf.localVideoView.hidden = YES;
                [weakSelf.previewLayer removeFromSuperlayer];
                [weakSelf.localVideoView removeFromSuperview];
                weakSelf.localVideoView = nil;
                [weakSelf.videoBackView removeFromSuperview];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
    }];
//    [self appendInfoToTableViewWithInfo:[NSString stringWithFormat:@"Uid:%lu didOffline reason:%lu", (unsigned long)uid, (unsigned long)reason]];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didAudioRouteChanged:(AgoraAudioOutputRouting)routing {
    switch (routing) {
        case AgoraAudioOutputRoutingDefault:
            NSLog(@"AgoraRtc_AudioOutputRouting_Default");
            break;
        case AgoraAudioOutputRoutingHeadset:
            NSLog(@"AgoraRtc_AudioOutputRouting_Headset");
            break;
        case AgoraAudioOutputRoutingEarpiece:
            NSLog(@"AgoraRtc_AudioOutputRouting_Earpiece");
            break;
        case AgoraAudioOutputRoutingHeadsetNoMic:
            NSLog(@"AgoraRtc_AudioOutputRouting_HeadsetNoMic");
            break;
        case AgoraAudioOutputRoutingSpeakerphone:
            NSLog(@"AgoraRtc_AudioOutputRouting_Speakerphone");
            break;
        case AgoraAudioOutputRoutingLoudspeaker:
            NSLog(@"AgoraRtc_AudioOutputRouting_Loudspeaker");
            break;
        case AgoraAudioOutputRoutingHeadsetBluetooth:
            NSLog(@"AgoraRtc_AudioOutputRouting_HeadsetBluetooth");
            break;
        default:
            break;
    }
}


/*
void _onJitsiMeetViewDelegateEvent(NSString *name, NSDictionary *data) {
    NSLog(
          @"[%s:%d] JitsiMeetViewDelegate %@ %@",
          __FILE__, __LINE__, name, data);
}

- (void)conferenceFailed:(NSDictionary *)data {
    _onJitsiMeetViewDelegateEvent(@"CONFERENCE_FAILED", data);
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        _startTime = [[NSDate date] timeIntervalSince1970];
        self.session = nil;
        self.localVideoView.hidden = YES;
        [self.previewLayer removeFromSuperlayer];
        [self.localVideoView removeFromSuperview];
        self.localVideoView = nil;
    });
}

- (void)conferenceJoined:(NSDictionary *)data {
    _onJitsiMeetViewDelegateEvent(@"CONFERENCE_JOINED", data);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _startTime = [[NSDate date] timeIntervalSince1970];
        
        self.timerIndex = 0;
        // 通话计时
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(callTimerAction:) userInfo:nil repeats:YES];
        self.session = nil;
        self.localVideoView.hidden = YES;
        [self.previewLayer removeFromSuperlayer];
        [self.localVideoView removeFromSuperview];
        self.localVideoView = nil;
    });
}

- (void)conferenceLeft:(NSDictionary *)data {
    _onJitsiMeetViewDelegateEvent(@"CONFERENCE_LEFT", data);
    
}

- (void)conferenceWillJoin:(NSDictionary *)data {
    _onJitsiMeetViewDelegateEvent(@"CONFERENCE_WILL_JOIN", data);
}

- (void)conferenceWillLeave:(NSDictionary *)data {
    _onJitsiMeetViewDelegateEvent(@"CONFERENCE_WILL_LEAVE", data);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.isGroup) {
//        int n = [[NSDate date] timeIntervalSince1970]-_startTime;
        int type = kWCMessageTypeVideoChatEnd;
        if (self.isAudio) {
            type = kWCMessageTypeAudioChatEnd;
        }
        [g_meeting sendEnd:type toUserId:self.toUserId toUserName:self.toUserName timeLen:self.timerIndex];
    }
        [self actionQuit];
    });
}

- (void)loadConfigError:(NSDictionary *)data {
    _onJitsiMeetViewDelegateEvent(@"LOAD_CONFIG_ERROR", data);
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actionQuit {
    
    if (_recorderBtn.selected) {
        [self stopRecord];
    }
    
    [g_App endCall];
    [self.timer invalidate];
    self.timer = nil;
    g_meeting.isMeeting = NO;
//    [self dismissViewControllerAnimated:YES completion:nil];
    [g_subWindow removeFromSuperview];
    g_subWindow = nil;
    [self.view removeFromSuperview];
    _pSelf = nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].statusBarHidden = NO;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    });
}

- (void)dealloc {
    NSLog(@"%@ -- dealloc",NSStringFromClass([self class]));
    [g_notify removeObserver:self];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
