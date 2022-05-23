//
//  JXRedPacketCell.m
//  shiku_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXRedPacketCell.h"
#import "UIImage-Extensions.h"
#import "UIImage+Color.h"

@interface JXRedPacketCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *title;

@end

@implementation JXRedPacketCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)creatUI{
    
    self.bubbleBg.custom_acceptEventInterval = 1.0;
    
//    self.bubbleBg.layer.cornerRadius = 6;
//    self.bubbleBg.layer.masksToBounds = YES;
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    _imageBackground = [[JXImageView alloc] initWithFrame:CGRectZero];
    [_imageBackground setBackgroundColor:HEXCOLOR(0xeca052)];

    // 加载图片
    UIImage *image = [UIImage imageNamed:@"hongbaokuan"];
    // 设置左边端盖宽度
    NSInteger imageWidth = image.size.width;
    // 设置上边端盖高度
    NSInteger imageHeight = image.size.height;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(150, 30, 60, 40);
//    UIImage *newImage = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    
    UIImage *newImage = [UIImage createImageWithColor:HEXCOLOR(0xeca052)];
    
    _imageBackground.image = newImage;
    
//    _imageBackground.image = [UIImage imageNamed:@"hongbaokuan"];
    
    _imageBackground.layer.masksToBounds = YES;
    _imageBackground.layer.cornerRadius = 5;
    
    [self.bubbleBg addSubview:_imageBackground];
    
    _headImageView = [[UIImageView alloc] init];
    _headImageView.frame = CGRectMake(10,25, 20, 40);
    _headImageView.image = [UIImage imageNamed:@"hongb"];
    _headImageView.userInteractionEnabled = NO;
    [_imageBackground addSubview:_headImageView];
    
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 10, CGRectGetMinY(_headImageView.frame), 180, _headImageView.frame.size.height);
    
    _nameLabel.font = g_factory.font15;
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.numberOfLines = 0;
    _nameLabel.userInteractionEnabled = NO;
    
    _nameLabel.layer.cornerRadius = 10;
    _nameLabel.layer.masksToBounds = YES;
    [_imageBackground addSubview:_nameLabel];

    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 30)];
    _title.text = [NSString stringWithFormat:@"    %@", @"红包"];
    _title.font = SYSFONT(14.0);
    _title.textColor = [UIColor grayColor];
    _title.backgroundColor = [UIColor whiteColor];
    [_imageBackground addSubview:_title];
    
    //
//    _redPacketGreet = [[JXEmoji alloc]initWithFrame:CGRectMake(5, 25, 80, 16)];
//    _redPacketGreet.textAlignment = NSTextAlignmentCenter;
//    _redPacketGreet.font = [UIFont systemFontOfSize:12];
//    _redPacketGreet.textColor = [UIColor whiteColor];
//    _redPacketGreet.userInteractionEnabled = NO;
//    [_imageBackground addSubview:_redPacketGreet];
}

-(void)setCellData{
    
    [super setCellData];
    int n = imageItemHeight;
    
    if(self.msg.isMySend){
        
        self.bubbleBg.frame = CGRectMake((JX_SCREEN_WIDTH-HEAD_SIZE - kChatCellMaxWidth - INSETS * 4 + CHAT_WIDTH_ICON) / 0.8, INSETS, (kChatCellMaxWidth + INSETS * 2) * 0.9 , (n + INSETS - 4) * 0.9);
        _imageBackground.frame = self.bubbleBg.bounds;
        
    }
    else{
        self.bubbleBg.frame=CGRectMake(CGRectGetMaxX(self.headImage.frame) + INSETS-CHAT_WIDTH_ICON, INSETS2(self.msg.isGroup), (kChatCellMaxWidth + INSETS * 2) * 0.9 , (n+INSETS - 4) * 0.9);
        _imageBackground.frame = self.bubbleBg.bounds;
    }
    
    _imageBackground.layer.masksToBounds = YES;
    _imageBackground.layer.cornerRadius = 5;

    self.bubbleBg.layer.masksToBounds = YES;
    self.bubbleBg.layer.cornerRadius = 7;
    
    _title.frame = CGRectMake(0, _imageBackground.frame.size.height - 22, _imageBackground.frame.size.width, 22);
    _headImageView.frame = CGRectMake(12,  (_imageBackground.frame.size.height - 22 - 45) / 2 , 40, 45);
    _nameLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 10, CGRectGetMinY(_headImageView.frame), 180, _headImageView.frame.size.height);

    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    
//    [self setMaskLayer:_imageBackground];
    
    //服务端返回的数据类型错乱，强行改
    self.msg.fileName = [NSString stringWithFormat:@"%@",self.msg.fileName];
    if ([self.msg.fileName isEqualToString:@"3"]) {
//        _imageBackground.image = [UIImage imageNamed:@"口令红包"];
//        _redPacketGreet.frame = CGRectMake(5, 45, _imageBackground.frame.size.width -10, 16);
        _nameLabel.text = [NSString stringWithFormat:@"%@%@",Localized(@"JX_Message"),self.msg.content];
        _title.text = [NSString stringWithFormat:@"    %@", [NSString stringWithFormat:@"%@口令红包",XL_APP_NAME]];
    }else{
//        _imageBackground.image = [UIImage imageNamed:@"红包"];
//        _redPacketGreet.frame = CGRectMake(5, 25, _imageBackground.frame.size.width -10, 16);
        _nameLabel.text = self.msg.content;
        _title.text = [NSString stringWithFormat:@"    %@", [NSString stringWithFormat:@"%@传媒红包",XL_APP_NAME]];
    }
    
    if ([self.msg.fileSize intValue] == 2) {
        
        _imageBackground.alpha = 0.7;
    }else {
        
        _imageBackground.alpha = 1;
    }

}

-(void)didTouch:(UIButton*)button{
    
    NSLog(@"%@",self.msg);
    NSLog(@"%@",self.msg.fileName);
//    if ([self.msg.fileName isEqualToString:@"3"]) {
//        //如果可以打开
//        if([self.msg.fileSize intValue] != 2){
//            [g_App showAlert:Localized(@"JX_WantOpenGift")];
//            return;
//        }
       
        [g_notify postNotificationName:kcellRedPacketDidTouchNotifaction object:self.msg];
    }
    
//    if ([self.msg.fileName isEqualToString:@"1"] || [self.msg.fileName isEqualToString:@"2"]) {
//        //如果可以打开
////        if([self.msg.fileSize intValue] != 2){
//            [g_notify postNotificationName:kcellRedPacketDidTouchNotifaction object:self.msg];
//            return;
////        }
//    }
    
//    [g_server getRedPacket:self.msg.objectId toView:self.chatView];
//}

+ (float)getChatCellHeight:(JXMessageObject *)msg {
    
    if ([g_App.isShowRedPacket intValue] == 1){
        if ([msg.chatMsgHeight floatValue] > 1) {
            return [msg.chatMsgHeight floatValue];
        }
        
        float n = 0;
        if (msg.isGroup && !msg.isMySend) {
            if (msg.isShowTime) {
                n = JX_SCREEN_WIDTH/3 + 10 + 40;
            }else {
                n = JX_SCREEN_WIDTH/3 + 10;
            }
        }else {
            if (msg.isShowTime) {
                n = JX_SCREEN_WIDTH/3 + 40;
            }else {
                n = JX_SCREEN_WIDTH/3;
            }
        }
        
        msg.chatMsgHeight = [NSString stringWithFormat:@"%f",n];
        if (!msg.isNotUpdateHeight) {
            [msg updateChatMsgHeight];
        }
        return n;
        
    }
    else{
        
        msg.chatMsgHeight = [NSString stringWithFormat:@"0"];
        if (!msg.isNotUpdateHeight) {
            [msg updateChatMsgHeight];
        }
        return 0;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
