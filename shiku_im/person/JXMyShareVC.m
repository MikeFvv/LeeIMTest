//
//  JXMyShareVC.m
//  shiku_im
//
//  Created by LewisHe on 2020/5/7.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "JXMyShareVC.h"
#import <Photos/Photos.h>

@implementation JXMyShareVC

- (id)init {
    self = [super init];
    if (self) {
        self.isGotoBack   = YES;
        self.title = @"分享好友";
        
        self.heightFooter = 0;
        self.heightHeader = JX_SCREEN_TOP;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
        
        JXImageView* iv = [[JXImageView alloc] init];
        iv.frame = CGRectMake(20, 20+JX_SCREEN_TOP, JX_SCREEN_WIDTH-40, JX_SCREEN_HEIGHT-JX_SCREEN_TOP-JX_SCREEN_BOTTOM-100);
        iv.backgroundColor = [UIColor whiteColor];
        iv.image = [UIImage imageNamed:@"myshare"];
        [self.view addSubview:iv];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(40, JX_SCREEN_HEIGHT-JX_SCREEN_BOTTOM-50, JX_SCREEN_WIDTH-80, 50)];
        btn.backgroundColor = HEXCOLOR(0xebebeb);
        [btn setTitleColor:HEXCOLOR(0x327afc) forState:UIControlStateNormal];
        [btn setTitle:@"保存图片" forState:UIControlStateNormal];
        btn.layer.cornerRadius = 5.0f;
        [btn addTarget:self action:@selector(onSaveImage) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btn];
    }
    
    return self;
}

-(void)dealloc {
    NSLog(@"PSMyViewController.dealloc");
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)onSaveImage {
    UIImage *image = [UIImage imageNamed:@"myshare"];
    
    NSMutableArray *imageIds = [NSMutableArray array];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //写入图片到相册
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        //记录本地标识，等待完成后取到相册中的图片对象
        [imageIds addObject:req.placeholderForCreatedAsset.localIdentifier];
        
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        NSLog(@"success = %d, error = %@", success, error);
        
        if (success)  {
            [g_App showAlert:@"图片保存成功！"];
        }
        
    }];

}
@end
