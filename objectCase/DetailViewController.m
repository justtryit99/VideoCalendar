//
//  DetailViewController.m
//  objectCase
//
//  Created by  AndyLiou on 2016/4/24.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import "DetailViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <DropboxSDK/DropboxSDK.h>



@interface DetailViewController ()
{
    BOOL isOpen;
    
    //id timeObsever;
}
@property (nonatomic,strong) AVPlayer *player;
@property (weak, nonatomic) IBOutlet UIButton *playOPauseBtnPressed;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UISlider *AVSlider;



@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
-(void)dealloc{
   
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self setupUI];
    [self.player play];
    [self addNotification];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self removeObserverFromPlayerItem:self.player.currentItem];
    //    [self addProgressObserver];
   // [self removeNotification];
    //[self.player removeTimeObserver:timeObsever];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - 私有方法
-(void)setupUI{
    //播放器Layer
    AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame=self.AVMovieImage.frame;
    [self.AVMovieImage.layer addSublayer:playerLayer];
}
-(AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem=[self getPlayItem:0];
        _player=[AVPlayer playerWithPlayerItem:playerItem];
        [self addProgressObserver];
        [self addObserverToPlayerItem:playerItem];
    }
    return _player;
}
-(AVPlayerItem *)getPlayItem:(int)videoIndex{
   
    NSURL *url=[NSURL URLWithString:self.test];
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
    return playerItem;
}
#pragma mark - 通知

//播放器通知
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//播放玩通知
-(void)playbackFinished:(NSNotification *)notification{
    
}

#pragma mark - 監控

-(void)addProgressObserver{
    AVPlayerItem *playerItem=self.player.currentItem;
    UIProgressView *progress=self.progress;
    UISlider * slider = self.AVSlider;
    //每秒執行一次   可用 id timeObsever = 去接 在removeTimeObserve
   [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        float total=CMTimeGetSeconds([playerItem duration]);
        NSLog(@"已經播放%.2fs.",current);
        if (current) {
            [progress setProgress:(current/total) animated:YES];
           //self.AVSlider.value = current/total;
           [slider setValue:(current/total) animated:YES];
        }
    }];
    
}

#pragma mark - slider
- (IBAction)AVSliderBt:(id)sender {
    
    AVPlayerItem *playerItem=_player.currentItem;
    //從這裡開始播放
    CGFloat current = self.AVSlider.value;
    //獲取總時長
    float total = CMTimeGetSeconds([playerItem duration]);
    //進行播放
    [_player seekToTime:CMTimeMake(total * current,1)];
    //播放
    [_player play];

}


#pragma mark - 監控

-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //監控加載
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正播放:%.2f",CMTimeGetSeconds(playerItem.duration));
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//緩衝範圍
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//緩衝長度
        NSLog(@"共緩衝：%.2f",totalBuffer);
        
    }
}

#pragma mark - play or pause
- (IBAction)playOrPauseClick:(id)sender {
   
    if(self.player.rate==0){ //如果是暫停 就播放
        [self.player play];
    }else if(self.player.rate==1){//正在播放 就暫停
        [self.player pause];
    }
}

#pragma mark - Delete movie
- (IBAction)deleteBtnPressed:(id)sender {
    //取得plist檔案路徑
    //停止影片
    if (_player != nil) {
        _player.rate = 0.0;
        _player = nil;
    }
    //刪除陣列中路徑
    [self.detailArray removeObject:self.test];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL * url = [NSURL URLWithString:self.test];
    [fileManager removeItemAtURL:url error:nil];
    
      [[NSNotificationCenter defaultCenter] postNotificationName:@"updataTableView" object:nil];
    
}

#pragma mark - save
- (IBAction)saveToPhoneBtnPressed:(id)sender {
    NSURL * movieURL = [NSURL URLWithString:self.test];
    ALAssetsLibrary * library = [ALAssetsLibrary new];
    [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:nil];
}

#pragma mark - share
- (IBAction)shareToFBBtnPressed:(id)sender
{NSURL * url = [NSURL URLWithString:self.test];
    NSString * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString * name = [NSString stringWithFormat:@"file://"];
    NSString * name2 = [name stringByAppendingString:path];
    NSString * filename = [NSString stringWithFormat:@"/123.mp4"];
    NSString * finallyname = [name2 stringByAppendingString:filename];
    NSURL * outputURL =[NSURL URLWithString:finallyname];
    
    NSLog(@"outputURL:  %@ ", outputURL);
    
    
    [self lowQuailtyWithInputURL:url outputURL:outputURL blockHandler:nil];
}
- (void) lowQuailtyWithInputURL:(NSURL*)inputURL
                      outputURL:(NSURL*)outputURL
                   blockHandler:(void (^)(AVAssetExportSession*))handler
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset     presetName:AVAssetExportPresetLowQuality];
    session.outputURL = outputURL;
    session.outputFileType = AVFileTypeMPEG4;
    session.shouldOptimizeForNetworkUse = YES;
    [session exportAsynchronouslyWithCompletionHandler:^(void)
     {
         //handler(session);
         switch (session.status) {
                 
             case AVAssetExportSessionStatusUnknown:
                 
                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 
                 break;
                 
             case AVAssetExportSessionStatusWaiting:
                 
                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 
                 break;
                 
             case AVAssetExportSessionStatusExporting:
                 
                 NSLog(@"AVAssetExportSessionStatusExporting");
                 
                 break;
                 
             case AVAssetExportSessionStatusCompleted:
                 
                 NSLog(@"AVAssetExportSessionStatusCompleted");
                 
                 break;
                 
             case AVAssetExportSessionStatusFailed:
                 
                 NSLog(@"AVAssetExportSessionStatusFailed");
                 
                 break;
       
         }
     }];
}


#pragma mark - Upload DropBox
//連線DropBox
-(DBRestClient *)restClient{
    if(!restClient){
        restClient = [[DBRestClient alloc]initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
            return restClient;
}
- (IBAction)uploadButton:(id)sender {
    if (![[DBSession sharedSession]isLinked]) {
        [[DBSession sharedSession]linkFromController:self];
    }
    NSString *fileName=[NSString stringWithFormat:@"%@.png",[[NSDate date] description]];
    
    NSString *localFilePath = [[NSBundle mainBundle] pathForResource:@"job.png" ofType:nil];
//    NSLog(@"%@",localFilePath);
    NSString *targetPath=@"/";
    
    [restClient uploadFile:fileName
                    toPath:targetPath
             withParentRev:nil
                  fromPath:localFilePath];
}
//上傳成功
-(void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath

             from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    
    
    NSLog(@"File uploaded successfully: %@", metadata.path);
    
}

//失敗
-(void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    
    NSLog(@"File upload failed - %@", error);
    
}
@end
