//
//  LVRecordView.m
//  RecordAndPlayVoice
//
//  Created by 刘春牢 on 15/3/15.
//  Copyright (c) 2015年 liuchunlao. All rights reserved.
//

#import "LVRecordView.h"
#import "RecorderEngine.h"

@interface LVRecordView () <RecorderDelegate>
/** 录音工具 */
@property (nonatomic, strong) RecorderEngine *recorderEngine;

/** 录音时的图片 */
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

/** 录音按钮 */
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;


/** 播放按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

@property (nonatomic, strong) RecordRelateView *recordRelateView;

@property (nonatomic, assign) CGFloat recordCurrentTime;

@end

@implementation LVRecordView

//+ (instancetype)recordView {
//    
//    LVRecordView *recordView = [[[NSBundle mainBundle] loadNibNamed:@"LVRecordView" owner:nil options:nil] lastObject];
//    
//    recordView.recordTool = [LVRecordTool sharedRecordTool];
//    // 初始化监听事件
//    [recordView setup];
//    
//    return recordView;
//}

- (void)relateRelationShipWithRecordRelateView:(RecordRelateView *)recordRelateView {

    _recordRelateView = recordRelateView;
    _recordRelateView.leadingImageView.image = [UIImage imageNamed:@""];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeImageViewClick)];
    _recordRelateView.closeImageView.userInteractionEnabled = YES;
    [_recordRelateView.closeImageView addGestureRecognizer:tapGes];
    
    
    UITapGestureRecognizer *recordPlayTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recordPlayTapGesClick)];
    _recordRelateView.leadingImageView.userInteractionEnabled = YES;
    [_recordRelateView.leadingImageView addGestureRecognizer:recordPlayTapGes];
    
}

- (void)setup {
    
    _fileName = @"recorder";
    
    self.recordBtn.layer.cornerRadius = 10;
    self.playBtn.layer.cornerRadius = 10;
    
    [self.recordBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self.recordBtn setTitle:@"松开 结束" forState:UIControlStateHighlighted];

    // 录音按钮
    [self.recordBtn addTarget:self action:@selector(recordBtnDidTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.recordBtn addTarget:self action:@selector(recordBtnDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordBtn addTarget:self action:@selector(recordBtnDidTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    
    // 播放按钮
    [self.playBtn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 录音按钮事件
// 按下
- (void)recordBtnDidTouchDown:(UIButton *)recordBtn {
    
    [self.recorderEngine startRecorderWithName:_fileName];
    [self.recorderEngine startRecorder];
    
    _tipLabel.hidden = NO;
    _timeLabel.hidden = NO;
    _imageView.hidden = NO;
    
}

// 点击
- (void)recordBtnDidTouchUpInside:(UIButton *)recordBtn {
    
    if (self.recordCurrentTime < 2) {
        
        self.imageView.image = [UIImage imageNamed:@"audio0"];
        [self alertWithMessage:@"说话时间太短"];
        
        [self.recorderEngine stopRecorder];
        [self.recorderEngine deleteRecorderWithName:_fileName];
    } else {
        
        [self.recorderEngine stopRecorder];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageNamed:@"audio0"];
        });
        
        // 已成功录音
        NSLog(@"已成功录音");
        _tipLabel.hidden = YES;
        _timeLabel.hidden = YES;
        _imageView.hidden = YES;
        _recordRelateView.timeLabel.hidden = NO;
        _recordRelateView.leadingImageView.image = [UIImage imageNamed:@"icon_record_layout_nor"];
        _recordRelateView.timeLabel.text = _timeLabel.text;
        
        if ([_delegate respondsToSelector:@selector(finishedRecord)]) {
            [_delegate finishedRecord];
        }
        
    }
}

// 手指从按钮上移除
- (void)recordBtnDidTouchDragExit:(UIButton *)recordBtn {
    self.imageView.image = [UIImage imageNamed:@"audio0"];
    
    [self.recorderEngine stopRecorder];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self alertWithMessage:@"已取消录音"];
    });
    
}

#pragma mark - 点击事件

- (void)closeImageViewClick {
    
    _recordRelateView.leadingImageView.image = [UIImage imageNamed:@""];
    _recordRelateView.timeLabel.hidden = YES;
    
    //停止播放
    [self.recorderEngine audioStop];
    
    [self.recorderEngine deleteRecorderWithName:_fileName];
    
}

- (void)recordPlayTapGesClick {
    
    //播放音频
    [self.recorderEngine playRecorderWithName:_fileName];
    [self.recorderEngine audioPlay];
    
    _recordRelateView.timeLabel.hidden = NO;
    _recordRelateView.timeLabel.text = _timeLabel.text;
    
}

#pragma mark - 弹窗提示
- (void)alertWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

#pragma mark - 播放录音
- (void)play {
    //播放音频
    [self.recorderEngine playRecorderWithName:_fileName];
    [self.recorderEngine audioPlay];
}

- (void)dealloc {
    
}

#pragma mark - RecorderDelegate
- (void)audioRecorderDidFinishWithEngine:(RecorderEngine *)engine {
    [self.recorderEngine stopRecorder];
}

- (void)audioPlayerDidFinishWithEngine:(RecorderEngine *)engine {
    NSLog(@"播放结束了");
    
}

- (void)audioProgressWithEngine:(RecorderEngine *)engine currentTime:(NSTimeInterval)currentTime flag:(BOOL)flag {
    
    self.recordCurrentTime = currentTime;
    
    NSString *timeStr = [NSString stringWithFormat:@"%d'",(int)currentTime];
    
    int index = ((int)currentTime)%4;
    
    NSString *imageName = [NSString stringWithFormat:@"audio%d", index];
    self.imageView.image = [UIImage imageNamed:imageName];
    self.timeLabel.text = timeStr;
    
    
    //进度条 flag:YES 录音  NO: 播放
    
    if (!flag) {
        
    }
    
}

//#pragma mark - LVRecordToolDelegate
//- (void)recordTool:(LVRecordTool *)recordTool didstartRecoring:(int)no {
//    
//    NSString *timeStr = [NSString stringWithFormat:@"%d'",(int)recordTool.recorder.currentTime];
//    
//    int index = ((int)recordTool.recorder.currentTime)%4;
//    
//    NSString *imageName = [NSString stringWithFormat:@"audio%d", index];
//    self.imageView.image = [UIImage imageNamed:imageName];
//    self.timeLabel.text = timeStr;
//}

- (NSData *)recordDataWithName:(NSString *)recordFileName {
    return [NSData dataWithContentsOfFile:[self.recorderEngine getFilePathWithName:recordFileName]];
}

//数据提交时需要转存数据到指定目录下
- (BOOL)turnRecordFileWithName:(NSString *)confirmFileName {
    
    NSData *mp3 = [NSData dataWithContentsOfFile:[self.recorderEngine getFilePathWithName:_fileName]];
    //[NSString stringWithFormat:@"%@.mp3",[confirmFileName stringFromMD5]]]
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *path = [[[paths lastObject] stringByAppendingPathComponent:confirmFileName] stringByAppendingPathComponent:@"/mp3"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    path = [path stringByAppendingFormat:@"/%@",[[confirmFileName stringFromMD5] stringByAppendingString:@".mp3"]];
    
    NSError *error = nil;
   
    BOOL isSuccessWrite = [mp3 writeToFile:path options:NSAtomicWrite error:&error];
    
    if (isSuccessWrite && mp3) {
        return YES;
    }
    
    return NO;
}

- (BOOL)checkFilePathIsExists:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExits = [fileManager fileExistsAtPath:path];
    BOOL ret = NO;
    if (!fileExits) {
        NSError *error = nil;
        ret = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return ret;
}

#pragma mark - getters & setters

- (RecorderEngine *)recorderEngine
{
    if (!_recorderEngine) {
        _recorderEngine = [[RecorderEngine alloc] init];
        _recorderEngine.delegate = self;
    }
    return _recorderEngine;
}

@end
