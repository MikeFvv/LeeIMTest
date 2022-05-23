//
//  JXQRCodeViewController.m
//  shiku_im
//
//  Created by 1 on 17/9/14.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXQRCodeViewController.h"
#import "QRImage.h"
#import <Photos/Photos.h>
#import "JXRelayVC.h"

@interface JXQRCodeViewController ()

@property (nonatomic, strong) UIImageView * qrImageView;
@property (nonatomic, strong)UIView *backView;
@property (nonatomic, strong) UIImage * newsImage;
@property (nonatomic, copy) NSString * fileName;

@end

@implementation JXQRCodeViewController

-(instancetype)init{
    if (self = [super init]) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.title = Localized(@"JXQR_QRImage");
        self.isGotoBack = YES;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self createHeadAndFoot];
    self.tableHeader.backgroundColor = RGB(244, 244, 244);
    self.tableBody.backgroundColor = RGB(244, 244, 244);
//    [self.tableHeader addSubview:self.saveButton];
    
//    NSMutableDictionary * qrDict = [NSMutableDictionary dictionary];
    NSMutableString * qrStr = [NSMutableString stringWithFormat:@"%@?action=",g_config.website];
    if(self.type == QRUserType)
    {
         [qrStr appendString:@"user"];
        NSString *temp = [NSString stringWithFormat:@"https://example.com/%@&shikuId=%@",qrStr,self.userId];
        qrStr.string = temp;
    }
       
    
//        [qrDict setObject:@"user" forKey:@"action"];
    else if(self.type == QRGroupType){
        [qrStr appendString:@"group"];
//        NSString *temp = [NSString stringWithFormat:@"%@",qrStr];
        NSString *temp = [NSString stringWithFormat:@"https://example.com/%@&shikuId=%@",qrStr,self.userId];
        qrStr.string = temp;
    }

//        [qrDict setObject:@"group" forKey:@"action"];
//    if(self.account != nil)
//        [qrStr appendFormat:@"&shikuId=%@",self.account];
//        [qrDict setObject:self.userId forKey:@"shiku"];
    
    
//     = [[[SBJsonWriter alloc] init] stringWithObject:qrDict];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    if (self.type == QRGroupType) {
//        NSString *groupImagePath = [NSString stringWithFormat:@"%@%@/%@.%@",NSTemporaryDirectory(),g_myself.userId,self.userId,@"jpg"];
//        if (groupImagePath && [[NSFileManager defaultManager] fileExistsAtPath:groupImagePath]) {
//            imageView.image = [UIImage imageWithContentsOfFile:groupImagePath];
//        }else{
//            [roomData roomHeadImageRoomId:self.userId toView:imageView];
//        }
        [g_server getRoomHeadImageSmall:self.roomJId roomId:self.userId imageView:imageView];
    }else {
        [g_server getHeadImageLarge:self.userId userName:self.nickName imageView:imageView];
    }
    
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake((JX_SCREEN_WIDTH-330)/2, 80, 330, 360)];
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.cornerRadius = 15;
    [self.tableBody addSubview:backView];
    self.backView = backView;
    
    UIImageView *headImgView = [[UIImageView alloc]initWithFrame:CGRectMake((backView.width-250)/2, 15, 40, 40)];
    headImgView.image = imageView.image;
    headImgView.layer.cornerRadius = headImgView.height*0.5;
    headImgView.layer.masksToBounds = YES;
    [backView addSubview:headImgView];
    
    UILabel *nameL = [[UILabel alloc]initWithFrame:CGRectMake(headImgView.right+10, headImgView.top, backView.width-headImgView.right-10-15, 40)];
    nameL.font  = [UIFont systemFontOfSize:16];
    nameL.text = self.nickName;
    [backView addSubview:nameL];
    
    UIImage * qrImage = [QRImage qrImageForString:qrStr imageSize:250 logoImage:imageView.image logoImageSize:50];
    _qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake((backView.width-250)/2, headImgView.bottom+20, 250, 250)];
    _qrImageView.image = qrImage;
    [backView addSubview:_qrImageView];
    
    UILabel *tipL = [[UILabel alloc]initWithFrame:CGRectMake(0, _qrImageView.bottom+10, backView.width, 13)];
    tipL.text = @"扫一扫上面的二维码图案,加我";
    tipL.font = [UIFont systemFontOfSize:12];
    tipL.textColor = HEXCOLOR(0x999999);
    tipL.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:tipL];
    
    UIButton *saveBtn = [UIButton buttonWithType:0];
    saveBtn.backgroundColor = [UIColor whiteColor];
    [saveBtn setTitle:@"保存到手机" forState:0];
    [saveBtn setTitleColor:[UIColor blackColor] forState:0];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    saveBtn.frame = CGRectMake(backView.left, backView.bottom+20, (backView.width-5)*0.5, 44);
    saveBtn.layer.cornerRadius = saveBtn.height*0.5;
    [saveBtn addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.tableBody addSubview:saveBtn];
    
    UIButton *shareBtn = [UIButton buttonWithType:0];
    shareBtn.backgroundColor = THEMECOLOR;
    [shareBtn setTitle:@"分享" forState:0];
    [shareBtn setTitleColor:[UIColor whiteColor] forState:0];
    shareBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    shareBtn.frame = CGRectMake(saveBtn.right+5, backView.bottom+20, (backView.width-5)*0.5, 44);
    [shareBtn addTarget:self action:@selector(shareButtonAction) forControlEvents:UIControlEventTouchUpInside];
    shareBtn.layer.cornerRadius = saveBtn.height*0.5;
    [self.tableBody addSubview:shareBtn];
    
}

-(void)saveButtonAction{
    UIImage * image = [self generateViewImage:self.backView];
    [self saveToLibary:image isShare:NO];
}
-(void)shareButtonAction{
    UIImage * image = [self generateViewImage:self.backView];
    self.newsImage = image;
    [self saveToLibary:image isShare:YES];
}

-(UIImage *)generateViewImage:(UIView *)view{
    CGSize s = view.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, YES, 1.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)saveToLibary:(UIImage *)image isShare:(BOOL)share{
    
     NSMutableArray *imageIds = [NSMutableArray array];
         [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{

             //写入图片到相册
             PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
             //记录本地标识，等待完成后取到相册中的图片对象
             [imageIds addObject:req.placeholderForCreatedAsset.localIdentifier];


         } completionHandler:^(BOOL success, NSError * _Nullable error) {

             NSLog(@"success = %d, error = %@", success, error);

             if (success)
             {
                 //成功后取相册中的图片对象
                 __block PHAsset *imageAsset = nil;
                 PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:imageIds options:nil];
                 [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                     imageAsset = obj;
                     *stop = YES;

                 }];
                 PHContentEditingInputRequestOptions *options =[[PHContentEditingInputRequestOptions alloc]init];
                 if (imageAsset)
                 {
                     [imageAsset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
                         NSLog(@"%@",contentEditingInput);
                        
                          if(share){
                              NSString *fileName = [contentEditingInput.fullSizeImageURL.absoluteString substringFromIndex:7];
                              
                                      JXMessageObject *msg=[[JXMessageObject alloc]init];
                                      msg.timeSend     = [NSDate date];
                                      msg.fromUserId   = MY_USER_ID;
                                      msg.fileName     = fileName;
                                      msg.content      = [[fileName lastPathComponent] stringByDeletingPathExtension];
                                      msg.type         = [NSNumber numberWithInt:kWCMessageTypeImage];
                                      msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
                                      msg.isRead       = [NSNumber numberWithBool:NO];
                                      msg.isUpload     = [NSNumber numberWithBool:NO];
     //                                 //新添加的图片宽高
                                      msg.location_x = [NSNumber numberWithInt:image.size.width];
                                      msg.location_y = [NSNumber numberWithInt:image.size.height];
     
//                                      msg.isReadDel    = [NSNumber numberWithInt:self.isReadDelete];
     
//                                      [msg insert:self.roomJid];
                                      [g_server uploadFile:fileName validTime:@"" messageId:msg.messageId toView:self];
                              
//                              JXRelayVC *vc = [[JXRelayVC alloc] init];
//                              vc.isMoreSel = YES;
////                              vc.chatVC = self;
//                              NSMutableArray *array = [NSMutableArray arrayWithObject:msg];
//                              vc.relayMsgArray = array;
//                              [g_navigation pushViewController:vc animated:YES];
                               
                          }else{
                               [g_server showMsg:@"已保存图片至手机"];
                          }
                     }];


                 }
             }

         }];
//    PHPhotoLibrary *libary = [PHPhotoLibrary sharedPhotoLibrary];
//    libary write
//
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSLog(@"嘻嘻%@",contextInfo);
    if (!error) {
        [g_server showMsg:Localized(@"JX_SaveSuessed") delay:1.5f];
    }else{
        [g_App showAlert:error.description];
    }
}
#pragma mark  -------------------服务器返回数据--------------------
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    if ([aDownload.action isEqualToString:act_UploadFile]) {
        NSArray *images = dict[@"images"];
        NSDictionary *imageDic = images[0];
        NSString *content = imageDic[@"oUrl"];
                          JXMessageObject *msg=[[JXMessageObject alloc]init];
                          msg.timeSend     = [NSDate date];
                          msg.fromUserId   = MY_USER_ID;
                          msg.fileName     = imageDic[@"oFileName"];;
                          msg.content      = content;
                          msg.type         = [NSNumber numberWithInt:kWCMessageTypeImage];
                          msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
                          msg.isRead       = [NSNumber numberWithBool:NO];
                          msg.isUpload     = [NSNumber numberWithBool:NO];
//                                 //新添加的图片宽高
                          msg.location_x = [NSNumber numberWithInt:self.newsImage.size.width];
                          msg.location_y = [NSNumber numberWithInt:self.newsImage.size.height];


                  
                  JXRelayVC *vc = [[JXRelayVC alloc] init];
//                              vc.chatPerson = self.chatPerson;
//                              vc.roomJid = self.roomJid;
                  vc.isMoreSel = YES;
//                              vc.chatVC = self;
                  NSMutableArray *array = [NSMutableArray arrayWithObject:msg];
                  vc.relayMsgArray = array;
                  [g_navigation pushViewController:vc animated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//-(UIButton *)saveButton{
//    if(!_saveButton){
//        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _saveButton.frame = CGRectMake(JX_SCREEN_WIDTH-30-8, JX_SCREEN_TOP - 34, 30, 30);
//        [_saveButton setImage:THESIMPLESTYLE ? [UIImage imageNamed:@"saveLibary_black"] : [UIImage imageNamed:@"saveLibary"] forState:UIControlStateNormal];
//        [_saveButton addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _saveButton;
//}

@end
