//
//  RecorderEngine.m
//  录音
//
//  Created by xiaerfei on 15-5-25.
//  Copyright (c) 2015年 xiaerfei. All rights reserved.
//

#import "RecorderEngine.h"
#import <CommonCrypto/CommonDigest.h>
#import "lame.h"
#import "MLAudioRecorder.h"
#import "Mp3RecordWriter.h"
#import <AVFoundation/AVFoundation.h>
#import "MLAudioMeterObserver.h"

@interface RecorderEngine ()<MLAudioRecorderDelegate>

@property (nonatomic, strong) MLAudioRecorder *mlRecorder;
@property (nonatomic, strong) Mp3RecordWriter *mp3Writer;
@property (nonatomic, strong) MLAudioMeterObserver *meterObserver;

@end

@implementation RecorderEngine
{
    NSString *_filaPath;
    NSDictionary *recorderSettingsDict;
    NSTimer *_timer;
    double lowPassResults;
    BOOL   _isRecorder;
    NSString *_currentRecorderName;
    BOOL _isPause;
    NSTimeInterval _currentTime;
    
    id playObserver;
    
    BOOL _isAVPlayer;
    
    NSTimeInterval _countRecorderTime;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([[[UIDevice currentDevice]systemVersion]doubleValue]>=7.0) {
            AVAudioSession *session = [AVAudioSession sharedInstance];
            [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            if (session) {
                [session setActive:YES error:nil];
            }
        }
        _refrechTime = 0.100f;
    }
    return self;
}
-(void)setRefrechTime:(double)refrechTime
{
    _refrechTime = refrechTime;
    if (!_timer) {
        [self initTimer];
    }
}
#pragma mark - init timer
- (void)initTimer
{
    //默认模式下长按（没有长按手势）timer暂停
//    _timer = [NSTimer scheduledTimerWithTimeInterval:_refrechTime target:self selector:@selector(refreshAction) userInfo:nil repeats:YES];
    
    _timer = [NSTimer timerWithTimeInterval:_refrechTime target:self selector:@selector(refreshAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer setFireDate:[NSDate distantFuture]];
}
/**
 *   @author xiaerfei
 *
 *   声波 录音进度、播放进度
 */
-(void)refreshAction
{
    double peakPowerForChannel = 0;
    if (_isAVPlayer || _isRecorder) {
        NSInteger rand = arc4random() % 1234567;
        peakPowerForChannel = rand*0.000001;
        if (_leftListView) {
            _leftListView.isPlay = YES;
            [_leftListView refreshPeak:peakPowerForChannel];
        }
        if (_rightListView) {
            _rightListView.isPlay = YES;
            [_rightListView refreshPeak:peakPowerForChannel];
        }
        if (_isRecorder == NO) {
            return;
        }
        
        if ([_delegate respondsToSelector:@selector(audioProgressWithEngine:currentTime:flag:)]) {
            NSTimeInterval currentTime = 0;
            if (_isRecorder) {
                currentTime = _recorder.currentTime;
            } else {
                currentTime = _player.currentTime;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate audioProgressWithEngine:self currentTime:_countRecorderTime flag:YES];
            });
            
            
            _countRecorderTime += 0.1;
        }
    } else {
        [_player updateMeters];
        const double ALPHA = 0.05;
        peakPowerForChannel = pow(10, (0.05 * [_player averagePowerForChannel:0]));
        lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
        if (_leftListView) {
            _leftListView.isPlay = YES;
            [_leftListView refreshPeak:peakPowerForChannel];
        }
        if (_rightListView) {
            _rightListView.isPlay = YES;
            [_rightListView refreshPeak:peakPowerForChannel];
        }
        if ([_delegate respondsToSelector:@selector(audioProgressWithEngine:currentTime:flag:)]) {
            NSTimeInterval currentTime = 0;
            currentTime = _player.currentTime;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate audioProgressWithEngine:self currentTime:currentTime flag:NO];
            });
            
        }
    }
}
#pragma mark - file path
- (NSString *)getRecorderFilePathWithName:(NSString *)name
{
    NSString *path = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSLog(@"%@",[paths lastObject]);
    path = [[paths lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/wav",name]];
    [self checkFilePathIsExists:path];
    return [path stringByAppendingPathComponent:[[name stringFromMD5] stringByAppendingString:@".wav"]];
}
- (NSString *)getMP3FilePathWithName:(NSString *)name
{
    NSString *path = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSLog(@"%@",[paths lastObject]);
    path = [[paths lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/mp3",name]];
    [self checkFilePathIsExists:path];
    return [path stringByAppendingPathComponent:[[name stringFromMD5] stringByAppendingString:@".mp3"]];
}

- (NSString *)getFilePathWithName:(NSString *)name {
    return [self getMP3FilePathWithName:name];
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
#pragma mark - AVAudioRecorder
+ (NSDictionary*)GetAudioRecorderSettingDict{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 44100.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,//通道的数目
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                   [NSNumber numberWithInt: AVAudioQualityMin],AVEncoderAudioQualityKey,//音频编码质量
                                   nil];
    return recordSetting;
}

- (void)startRecorderWithName:(NSString *)recorderName
{
    self.mp3Writer = [[Mp3RecordWriter alloc]init];
    self.mp3Writer.filePath = [self getMP3FilePathWithName:recorderName];
    self.mp3Writer.maxSecondCount = 120;
    self.mp3Writer.maxFileSize = 1024*1024;
    
    MLAudioMeterObserver *meterObserver = [[MLAudioMeterObserver alloc]init];
    meterObserver.actionBlock = ^(NSArray *levelMeterStates,MLAudioMeterObserver *meterObserver){
//        NSLog(@"volume:%f",[MLAudioMeterObserver volumeForLevelMeterStates:levelMeterStates]);
    };
    meterObserver.errorBlock = ^(NSError *error,MLAudioMeterObserver *meterObserver){
        //        [[[UIAlertView alloc]initWithTitle:@"错误" message:error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil]show];
    };
    self.meterObserver = meterObserver;
    
    self.mlRecorder = [[MLAudioRecorder alloc]init];
    __weak __typeof(self)weakSelf = self;
    self.mlRecorder.receiveStoppedBlock = ^{
        weakSelf.meterObserver.audioQueue = nil;
    };
    self.mlRecorder.receiveErrorBlock = ^(NSError *error){
        weakSelf.meterObserver.audioQueue = nil;
        
    };
    
    self.mlRecorder.fileWriterDelegate = self.mp3Writer;
    self.mlRecorder.delegate = self;

}

- (void)startRecorder
{
    @try {
        
        if (self.mlRecorder) {
            if (!_timer) {
                [self initTimer];
            }
            [self.mlRecorder startRecording];
            self.meterObserver.audioQueue = self.mlRecorder->_audioQueue;
            [_timer setFireDate:[NSDate distantPast]];
            _isRecorder = YES;
            _countRecorderTime = 0;
        }
        else
        {
            [_timer setFireDate:[NSDate distantFuture]];
            if ([_delegate respondsToSelector:@selector(audioRecorderEncodeErrorWithEngine:error:)]) {
                [_delegate audioRecorderEncodeErrorWithEngine:self error:nil];
            }
        }
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}


-(void)stopRecorder
{
    [_timer setFireDate:[NSDate distantFuture]];
    [self.mlRecorder stopRecording];
    self.mp3Writer = nil;
    self.mlRecorder = nil;
    self.meterObserver = nil;
    _countRecorderTime = 0;
    [_rightListView setAllListHeightZero];
    [_leftListView setAllListHeightZero];
    _isRecorder = NO;
}
#pragma mark AVAudioRecorderDelegate
- (void)recordError:(NSError *)error
{
    [_timer setFireDate:[NSDate distantFuture]];
    self.mp3Writer = nil;
    self.mlRecorder = nil;
    self.meterObserver = nil;
    _countRecorderTime = 0;
    [_rightListView setAllListHeightZero];
    [_leftListView setAllListHeightZero];
    
    if ([_delegate respondsToSelector:@selector(audioRecorderDidFinishWithEngine:)]) {
        [_delegate audioRecorderDidFinishWithEngine:self];
    }
}

- (void)recordStopped
{
    [_timer setFireDate:[NSDate distantFuture]];
    self.mp3Writer = nil;
    self.mlRecorder = nil;
    self.meterObserver = nil;
    [_rightListView setAllListHeightZero];
    [_leftListView setAllListHeightZero];
    
    if ([_delegate respondsToSelector:@selector(audioRecorderDidFinishWithEngine:)]) {
        [_delegate audioRecorderDidFinishWithEngine:self];
    }
}

#pragma mark - AVAudioPlayer
-(void)playRecorderWithName:(NSString *)name
{
    [_player stop];
    _player = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    _player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:[self getFilePathWithName:name]] error:nil];
    _player.meteringEnabled = YES;
    _player.delegate = self;
    [_player prepareToPlay];
    _duration = _player.duration;
}

- (void)audioPlay
{
    if (_player) {
        if (!_timer) {
            [self initTimer];
        }
        _isRecorder = NO;
        [_timer setFireDate:[NSDate distantPast]];
        
        [_player play];
    }
}

- (void)audioPause
{
    if (_player) {
        [_player pause];
    }
}

- (void)audioStop
{
    if (_player) {
        [_player stop];
        [_rightListView setAllListHeightZero];
        [_leftListView setAllListHeightZero];
        _player = nil;
        [_timer setFireDate:[NSDate distantFuture]];
    }
}
#pragma mark  AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_timer setFireDate:[NSDate distantFuture]];
    [_rightListView setAllListHeightZero];
    [_leftListView setAllListHeightZero];

    if ([_delegate respondsToSelector:@selector(audioPlayerDidFinishWithEngine:)]) {
        [_delegate audioPlayerDidFinishWithEngine:self];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [_timer setFireDate:[NSDate distantFuture]];
    if ([_delegate respondsToSelector:@selector(audioPlayerDecodeErrorWithEngine:error:)]) {
        [_delegate audioPlayerDecodeErrorWithEngine:self error:error];
    }
}
#pragma mark -  AVPlayer   网络播放
- (void)netPlayWithURL:(NSString *)url
{

    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
//        AVURLAsset *movieAsset    = [[AVURLAsset alloc]initWithURL:[NSURL URLWithString:@"http://sc1.111ttt.com/2015/1/07/02/100021232391.mp3"] options:nil];
//    AVPlayerItem *mp3PlayerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    AVPlayerItem *mp3PlayerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
    [mp3PlayerItem addObserver:self forKeyPath:@"status" options:0 context:NULL];
    [mp3PlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:mp3PlayerItem];
    self.mp3Player = [AVPlayer playerWithPlayerItem:mp3PlayerItem];
    [self monitoringPlayback:mp3PlayerItem];
    _isPause = NO;
}

- (void)netPlayPause
{
    _isAVPlayer = NO;
    [_rightListView setAllListHeightZero];
    [_leftListView setAllListHeightZero];
    [_timer setFireDate:[NSDate distantFuture]];
    [self.mp3Player pause];
    _isPause = YES;
//    _currentTime = self.mp3Player.currentTime;
    
    self.mp3Player = nil;
}

- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    __weak typeof(self) weakSelf = self;
//    [self.mp3Player removeTimeObserver:playObserver];
   playObserver = [self.mp3Player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;// 计算当前在第几秒
        //播放进度代理
        if ([weakSelf.delegate respondsToSelector:@selector(netPlayerDidPlayWithEngine:progress:)]) {
            [weakSelf.delegate netPlayerDidPlayWithEngine:weakSelf progress:[weakSelf convertTime:currentSecond]];
        }
    }];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"])
    {
        if (AVPlayerItemStatusReadyToPlay == self.mp3Player.currentItem.status)
        {
            [self.mp3Player play];
            if (!_timer) {
                [self initTimer];
            }
            [_timer setFireDate:[NSDate distantPast]];
            _isAVPlayer = YES;
            //播放成功代理
            if ([_delegate respondsToSelector:@selector(netPlayerDidPlaySuccessWithEngine:)]) {
                [_delegate netPlayerDidPlaySuccessWithEngine:self];
            }
        } else if (AVPlayerItemStatusFailed == self.mp3Player.currentItem.status) {
            [_rightListView setAllListHeightZero];
            [_leftListView setAllListHeightZero];
            [_timer setFireDate:[NSDate distantFuture]];
            _isAVPlayer = NO;
            if ([_delegate respondsToSelector:@selector(netPlayerDidPlayFailWithEngine:error:)]) {
                [_delegate netPlayerDidPlayFailWithEngine:self error:@"fail"];
            }
            
        } else {
            _isAVPlayer = NO;
            [_timer setFireDate:[NSDate distantFuture]];
            [_rightListView setAllListHeightZero];
            [_leftListView setAllListHeightZero];
            if ([_delegate respondsToSelector:@selector(netPlayerDidPlayFailWithEngine:error:)]) {
                
                [_delegate netPlayerDidPlayFailWithEngine:self error:@"unknown"];
            }
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
//        CMTime duration = self.mp3Player.currentItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds([self playerItemDuration]);
        //缓冲进度 总时间
        if ([_delegate respondsToSelector:@selector(netPlayerDidPlayWithEngine:availableDuration:totalDuration:)]) {
            [_delegate netPlayerDidPlayWithEngine:self availableDuration:[self convertTime:timeInterval] totalDuration:[self convertTime:totalDuration]];
        }
    }
}

- (void)moviePlayDidEnd:(NSNotification *)notification
{
    [_timer setFireDate:[NSDate distantFuture]];
    _isAVPlayer = NO;
    [_rightListView setAllListHeightZero];
    [_leftListView setAllListHeightZero];
    if ([_delegate respondsToSelector:@selector(netPlayerDidPlayEndWithEngine:)]) {
        [_delegate netPlayerDidPlayEndWithEngine:self];
//        [self.mp3Player removeTimeObserver:playObserver];
        self.mp3Player = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.mp3Player.currentItem];
        [self.mp3Player.currentItem removeObserver:self forKeyPath:@"status"];
        [self.mp3Player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    }
}

- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = [self.mp3Player currentItem];
    if ([playerItem respondsToSelector:@selector(duration)]) {
        return([playerItem duration]);
    } else if ([playerItem respondsToSelector:@selector(asset)]) {
        AVAsset *asset = [playerItem asset];
        if (asset) {
            return [asset duration];
        }
    }
     return(kCMTimeInvalid);
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.mp3Player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

#pragma mark - 读取录音文件
- (NSData *)readRecorderDataWithName:(NSString *)name
{
    NSData *data = [NSData dataWithContentsOfFile:[self getMP3FilePathWithName:name]];
    return data;
}
#pragma mark - 删除录音
- (BOOL)deleteRecorderWithName:(NSString *)name
{
    //modified by wbgao - 2015-7-9
    return ( [self deleteFileWithPath:[self getMP3FilePathWithName:name]]
        && [self deleteFileWithPath:[self getRecorderFilePathWithName:name]]);
}

- (BOOL)deleteFileWithPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL ret = [fileManager fileExistsAtPath:path];
    if (ret) {
        NSError *error = nil;
        if ([fileManager removeItemAtPath:path error:&error]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 转换为MP3格式
- (void)convertToMP3WithName:(NSString *)name
{
    
    NSString *cafFilePath =[self getRecorderFilePathWithName:name];
    NSString *mp3FilePath = [self getMP3FilePathWithName:name];
    NSLog(@"%@",mp3FilePath);
    @try {
        int read, write;
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        NSLog(@"转换成功");
        
        if ([_delegate respondsToSelector:@selector(audioRecorderDidFinishWithEngine:)]) {
            [_delegate audioRecorderDidFinishWithEngine:self];
        }
        
        [self deleteFileWithPath:[self getRecorderFilePathWithName:name]];
    }
}

- (void)hiddenAudioListView
{
    self.rightListView.hidden = YES;
    self.leftListView.hidden = YES;
}

- (void)displayAudioListView
{
    self.rightListView.hidden = NO;
    self.leftListView.hidden = NO;
}

#pragma mark - getters
-(AudioList *)rightListView
{
    if (!_rightListView) {
        _rightListView = [[AudioList alloc] init];
        _rightListView.numOfBins = 10;
    }
    return _rightListView;
}

- (AudioList *)leftListView
{
    if (!_leftListView) {
        _leftListView = [[AudioList alloc] init];
        _leftListView.numOfBins = 10;
    }
    return _leftListView;
}

#pragma mark - dealloc
-(void)dealloc
{
    NSLog(@"dealloc recorderEngine");
    [_timer invalidate];
    _timer = nil;
}


@end






#if __has_feature(objc_arc)
#define SAFE_AUTORELEASE(a) (a)
#else
#define SAFE_AUTORELEASE(a) [(a) autorelease]
#endif
@implementation NSString(MD5Addition)

- (NSString *) stringFromMD5{
    
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return SAFE_AUTORELEASE(outputString);
}

@end

