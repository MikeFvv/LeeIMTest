//
//  JXPickerView.m
//  shiku_im
//
//  Created by aaa on 2019/12/29.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXPickerView.h"

@interface JXPickerView ()


@end

@implementation JXPickerView

- (id)initWithFrame:(CGRect)frame{
    
    int h = 26;
    
    self = [super initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
//        self.backgroundColor = [UIColor whiteColor];
      
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT - 300, JX_SCREEN_WIDTH, 300)];
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.delegate = self.delegate;
        _pickerView.dataSource = self.dataSource;
        
        [self addSubview:self.pickerView];

//        [_sel release];
        
        UIView *barView = [UIView new];
        barView.frame =  CGRectMake(0, JX_SCREEN_HEIGHT - 340, JX_SCREEN_WIDTH, 40);
        [self addSubview:barView];
        barView.backgroundColor = [UIColor lightGrayColor];
     
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        cancelButton.frame = CGRectMake(0, JX_SCREEN_HEIGHT - 340, 80, 40);
        [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
         _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        _confirmButton.frame = CGRectMake(JX_SCREEN_WIDTH - 80, JX_SCREEN_HEIGHT - 340, 80, 40);
//        [_confirmButton addTarget:self action:self.didSelect forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.custom_acceptEventInterval = 0.2;
        [self addSubview:_confirmButton];
        
        
    }
    return self;
}

- (void)setDelegate:(id)delegate {
    
    _delegate = delegate;
    self.pickerView.delegate = delegate;
}

- (void)setDataSource:(id)dataSource {
    
    _dataSource = dataSource;
    self.pickerView.dataSource = dataSource;
    
//    [_confirmButton addTarget:self action:@selector(comfirmAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)comfirmAction {
    
    //点击确定的回调
   
    
}

- (void)setDidSelect:(SEL)didSelect {
    
    _didSelect = didSelect;
}


- (void)cancelButtonAction{
    
    [self removeFromSuperview];
}

@end
