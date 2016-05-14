//
//  VideoMakerViewController.m
//  FinalProject
//
//  Created by lautmn on 2016/4/7.
//  Copyright © 2016年 lautmn. All rights reserved.
//

#import "VideoMakerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SelectImageCollectionViewController.h"

// Frames per Photo
#define FRAMES 60
// Sec per Photo
#define SEC_PER_PHOTO 3.0
// FPS = FRAMES / SEC_PER_PHOTO

@interface VideoMakerViewController () {
    NSMutableArray *imageArr;
    NSString *theVideoPath;
    NSTimer *previewTimer;
    int photoCount;
    int photoFrame;
    UIImageView *videoPreview;
    int effectType;
    int musicType;
    //    NSMutableArray *imageWithEffects;
    UIScrollView *effectSelect;
    UIScrollView *musicSelect;
    
}


@end

@implementation VideoMakerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    photoCount = 0;
    photoFrame = 0;
    effectType = 1;
    imageArr = [[NSMutableArray alloc] init];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenWidth = screenSize.width;
    
    videoPreview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, screenWidth, screenWidth)];
    videoPreview.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:videoPreview];
    
    
    // Resize all photo to 640*640, and add into imageArr
    
    //開背景執行緒
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //派工到背景執行緒上
    dispatch_async(aQueue, ^{
        for (NSURL *url in _imageArray) {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            UIImage *resizeImage = [self resizeFromImage:image];
            NSData *imageData = UIImageJPEGRepresentation(resizeImage, 1);
            NSLog(@"%ld",imageData.length);
            [imageArr addObject:resizeImage];
        }
        //切回主執行緒
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
        });
    });
    
    
    
    /*
     //開背景執行緒
     dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     //派工到背景執行緒上
     dispatch_async(aQueue, ^{
     // Do something
     // ...
     //切回主執行緒
     dispatch_queue_t mainQueue = dispatch_get_main_queue();
     dispatch_async(mainQueue, ^{
     });
     });
     */
    
    
    // Preview Video (UIImage)
    previewTimer = [NSTimer scheduledTimerWithTimeInterval:SEC_PER_PHOTO/FRAMES target:self selector:@selector(showVideoPreView) userInfo:nil repeats:true];
    
    /*
     UIButton * playVideo =[UIButton buttonWithType:UIButtonTypeRoundedRect];
     [playVideo setFrame:CGRectMake(100,screenWidth+200, 100,100)];
     [playVideo setTitle:@"播放"forState:UIControlStateNormal];
     [playVideo addTarget:self action:@selector(playAction)forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:playVideo];
     */
    
    UIView *musicOrEffect = [[UIView alloc] initWithFrame:CGRectMake(0, 60+screenWidth, screenWidth, 60)];
    musicOrEffect.backgroundColor = [UIColor blackColor];
    [self.view addSubview:musicOrEffect];
    
    UIButton *musicMode = [UIButton buttonWithType:UIButtonTypeCustom];
    musicMode.backgroundColor = [UIColor blackColor];
    [musicMode addTarget:self action:@selector(musicMode) forControlEvents:UIControlEventTouchUpInside];
    [musicMode setImage:[UIImage imageNamed:@"music.png"] forState:UIControlStateNormal];
    musicMode.frame = CGRectMake(0, 0, screenWidth/2, 60);
    [musicOrEffect addSubview:musicMode];
    
    UIButton *effectMode = [UIButton buttonWithType:UIButtonTypeCustom];
    effectMode.backgroundColor = [UIColor blackColor];
    [effectMode addTarget:self action:@selector(effectMode) forControlEvents:UIControlEventTouchUpInside];
    [effectMode setImage:[UIImage imageNamed:@"effect.png"] forState:UIControlStateNormal];
    effectMode.frame = CGRectMake(screenWidth/2, 0, screenWidth/2, 60);
    [musicOrEffect addSubview:effectMode];
    
    
    
    /*
     UIScrollView *musicOrEffect=[[UIScrollView alloc]initWithFrame:CGRectMake(0,65+screenWidth,;
     musicOrEffect.backgroundColor = [UIColor redColor];
     musicOrEffect.showsVerticalScrollIndicator=YES;
     musicOrEffect.scrollEnabled=YES;
     musicOrEffect.userInteractionEnabled=YES;
     [self.view addSubview:musicOrEffect];
     musicOrEffect.contentSize = CGSizeMake(960,120);
     */
    
    musicSelect=[[UIScrollView alloc]initWithFrame:CGRectMake(0,120+screenWidth,screenWidth,120)];
    musicSelect.backgroundColor = [UIColor colorWithRed:74.0/255 green:74.0/255 blue:74.0/255 alpha:1.0];
    musicSelect.showsVerticalScrollIndicator=YES;
    musicSelect.scrollEnabled=YES;
    musicSelect.userInteractionEnabled=YES;
    [self.view addSubview:musicSelect];
    musicSelect.contentSize = CGSizeMake(960,120);
    musicSelect.hidden = true;
    
    UIButton *music1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    music1.backgroundColor = [UIColor redColor];
    [music1 addTarget:self action:@selector(music1) forControlEvents:UIControlEventTouchUpInside];
    [music1 setTitle:@"Music1" forState:UIControlStateNormal];
    music1.frame = CGRectMake(5.0, 5.0, 110.0, 110.0);
    [musicSelect addSubview:music1];
    
    
    
    
    effectSelect=[[UIScrollView alloc]initWithFrame:CGRectMake(0,120+screenWidth,screenWidth,120)];
    effectSelect.backgroundColor = [UIColor colorWithRed:74.0/255 green:74.0/255 blue:74.0/255 alpha:1.0];
    effectSelect.showsVerticalScrollIndicator=YES;
    effectSelect.scrollEnabled=YES;
    effectSelect.userInteractionEnabled=YES;
    [self.view addSubview:effectSelect];
    effectSelect.contentSize = CGSizeMake(960,120);
    
    UIButton *effect1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    effect1.backgroundColor = [UIColor blueColor];
    [effect1 addTarget:self  action:@selector(effect1) forControlEvents:UIControlEventTouchUpInside];
    [effect1 setTitle:@"Effect1" forState:UIControlStateNormal];
    effect1.frame = CGRectMake(5.0, 5.0, 110.0, 110.0);
    [effectSelect addSubview:effect1];
    
    UIButton *effect2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    effect2.backgroundColor = [UIColor yellowColor];
    [effect2 addTarget:self  action:@selector(effect2) forControlEvents:UIControlEventTouchUpInside];
    [effect2 setTitle:@"Effect2" forState:UIControlStateNormal];
    effect2.frame = CGRectMake(120.0, 5.0, 110.0, 110.0);
    [effectSelect addSubview:effect2];
    
    UIButton *effect3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    effect3.backgroundColor = [UIColor greenColor];
    [effect3 addTarget:self  action:@selector(effect3) forControlEvents:UIControlEventTouchUpInside];
    [effect3 setTitle:@"Effect3" forState:UIControlStateNormal];
    effect3.frame = CGRectMake(235.0, 5.0, 110.0, 110.0);
    [effectSelect addSubview:effect3];
    
    /*
     UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     effect2.backgroundColor = [UIColor yellowColor];
     [effect2 addTarget:self  action:@selector(effect2) forControlEvents:UIControlEventTouchDown];
     [effect2 setTitle:@"Effect2" forState:UIControlStateNormal];
     effect2.frame = CGRectMake(125.0, 5.0, 110.0, 110.0);
     [scrollview addSubview:effect2];
     */
    
    
    
}


-(void)viewDidDisappear:(BOOL)animated {
    [previewTimer invalidate];
    previewTimer = nil;
}



- (void)testCompressionSession {
    //    NSLog(@"開始");
    //    NSString *moviePath = [[NSBundle mainBundle]pathForResource:@"Movie" ofType:@"mov"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *moviePath =[[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",dateString]];
    theVideoPath=moviePath;
    CGSize size =CGSizeMake(640,640);//定義影片大小
    
    NSError *error =nil;
    
    unlink([moviePath UTF8String]);
    //    NSLog(@"path->%@",moviePath);
    //—-initialize compression engine
    AVAssetWriter *videoWriter =[[AVAssetWriter alloc]initWithURL:[NSURL fileURLWithPath:moviePath]
                                                         fileType:AVFileTypeQuickTimeMovie
                                                            error:&error];
    NSParameterAssert(videoWriter);
    if(error) NSLog(@"error =%@", [error localizedDescription]);
    
    NSDictionary *videoSettings =[NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264,AVVideoCodecKey,
                                  [NSNumber numberWithInt:size.width],AVVideoWidthKey,
                                  [NSNumber numberWithInt:size.height],AVVideoHeightKey,nil];
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary *sourcePixelBufferAttributesDictionary =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if ([videoWriter canAddInput:writerInput]) NSLog(@"Add Input Success");
    else NSLog(@"Add Input Fail");
    
    [videoWriter addInput:writerInput];
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //將照片合成影片
    dispatch_queue_t dispatchQueue = dispatch_queue_create("mediaInputQueue",NULL);
    int __block frame = -1;
    
    
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        while([writerInput isReadyForMoreMediaData]) {
            if (++frame >=[imageArr count]*FRAMES) {
                //            if (++frame >= [imageArr count]) {
                [writerInput markAsFinished];
                [videoWriter finishWriting];
                //                [videoWriter finishWritingWithCompletionHandler:nil];
                break;
            }
            
            
            CVPixelBufferRef buffer = NULL;
            
            int idx =frame/FRAMES;
            //            int idx = frame;
            NSLog(@"idx==%d",idx);
            
            int frameRemainder = frame%FRAMES;
            NSLog(@"%i",frameRemainder);
            
            
            switch (effectType) {
                case 1:
                {
                    float remainderToFloat = [[NSNumber numberWithInt: frameRemainder] floatValue];
                    float scaleRate = 1.0+0.1*(remainderToFloat/FRAMES);
                    UIImage *animationScaleImage = [self scaleImage:[imageArr objectAtIndex:idx] toScale:scaleRate];
                    buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[animationScaleImage CGImage] size:size];
                    break;
                }
                    
                case 2:
                {
                    float remainderToFloat = [[NSNumber numberWithInt: frameRemainder] floatValue];
                    float scaleRate = 1.1-0.1*(remainderToFloat/FRAMES);
                    UIImage *animationScaleImage = [self scaleImage:[imageArr objectAtIndex:idx] toScale:scaleRate];
                    buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[animationScaleImage CGImage] size:size];
                    break;
                }
                    
                default:
                    break;
            }
            
            
            ////            if (frameRemainder < (FRAMES/2)) {
            //                float remainderToFloat = [[NSNumber numberWithInt: frameRemainder] floatValue];
            //                float scaleRate = 1.0+0.1*(remainderToFloat/FRAMES);
            //                UIImage *animationScaleImage = [self scaleImage:[imageArr objectAtIndex:idx] toScale:scaleRate];
            //                buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[animationScaleImage CGImage] size:size];
            ////            } else {
            ////                buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[[imageArr objectAtIndex:idx] CGImage] size:size];
            ////            }
            
            //            buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[[imageArr objectAtIndex:idx] CGImage] size:size];
            
            if (buffer) {
                NSLog(@"%d",frame);
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,FRAMES/SEC_PER_PHOTO)])
                    NSLog(@"FAIL");
                else
                    NSLog(@"OK");
                CFRelease(buffer);
            }
        }
    }];
}



- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size {
    NSDictionary *options =[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer,0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace=CGColorSpaceCreateDeviceRGB();
    CGContextRef context =CGBitmapContextCreate(pxdata,size.width,size.height,8,4*size.width,rgbColorSpace,kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    
    CGContextDrawImage(context,CGRectMake(0,0,CGImageGetWidth(image),CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer,0);
    
    return pxbuffer;
}

/*
- (void)playAction {
    MPMoviePlayerViewController *theMovie = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:theVideoPath]];
    [self presentMoviePlayerViewControllerAnimated:theMovie];
    theMovie.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [theMovie.moviePlayer play];
}
*/
 

- (UIImage *)resizeFromImage:(UIImage *)sourceImage {
    
    // Check sourceImage's size
    CGFloat maxValue = 640.0;
    CGSize originalSize = sourceImage.size;
    if (originalSize.width <= maxValue && originalSize.height <= maxValue) {
        return sourceImage;
    }
    // Decide final size
    
    CGSize targetSize;
    if (originalSize.width >= originalSize.height) {
        CGFloat ratio = originalSize.width/maxValue;
        targetSize = CGSizeMake(maxValue, originalSize.height/ratio);
    } else { // height > width
        CGFloat ratio = originalSize.width/originalSize.height;
        targetSize = CGSizeMake(maxValue *ratio, maxValue);
    }
    UIGraphicsBeginImageContext(targetSize);
    [sourceImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    resultImage = [self setBlackBackground:resultImage];
    
    return resultImage;
}

- (UIImage *)setBlackBackground:(UIImage *)sourceImage {
    UIImage *background = [UIImage imageNamed:@"blackBackground.jpg"];
    CGSize backgroundSize = CGSizeMake(640, 640);
    UIGraphicsBeginImageContext(backgroundSize);
    [background drawInRect:CGRectMake(0, 0, 640, 640)];
    [sourceImage drawInRect:CGRectMake(320-sourceImage.size.width/2, 0, sourceImage.size.width, sourceImage.size.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    scaledImage = [self setBlackBackground:scaledImage];
    
    return scaledImage;
}


- (void)showVideoPreView {
    
    switch (effectType) {
        case 1:
        {
            if (photoCount < imageArr.count) {
                if (photoFrame<FRAMES) {
                    float frameToFloat = [[NSNumber numberWithInt: photoFrame] floatValue];
                    videoPreview.image = [self scaleImage:imageArr[photoCount] toScale:1.0+0.1*(frameToFloat/FRAMES)];
                } else {
                    photoFrame = 0;
                    photoCount++;
                }
                photoFrame++;
            } else {
                photoFrame = 0;
                photoCount = 0;
            }
            break;
        }
            
        case 2:
        {
            if (photoCount < imageArr.count) {
                if (photoFrame<FRAMES){
                    float frameToFloat = [[NSNumber numberWithInt: photoFrame] floatValue];
                    videoPreview.image = [self scaleImage:imageArr[photoCount] toScale:1.1-0.1*(frameToFloat/FRAMES)];
                } else {
                    photoFrame = 0;
                    photoCount++;
                }
                photoFrame++;
            } else {
                photoFrame = 0;
                photoCount = 0;
            }
            break;
        }
            
        case 3:
        {
            if (photoCount < imageArr.count) {
                if (photoCount%2==0) {
                    if (photoFrame<FRAMES){
                        float frameToFloat = [[NSNumber numberWithInt: photoFrame] floatValue];
                        videoPreview.image = [self scaleImage:imageArr[photoCount] toScale:1.0+0.1*(frameToFloat/FRAMES)];
                    } else {
                        photoFrame = 0;
                        photoCount++;
                    }
                    photoFrame++;
                } else {
                    if (photoFrame<FRAMES){
                        float frameToFloat = [[NSNumber numberWithInt: photoFrame] floatValue];
                        videoPreview.image = [self scaleImage:imageArr[photoCount] toScale:1.1-0.1*(frameToFloat/FRAMES)];
                    } else {
                        photoFrame = 0;
                        photoCount++;
                    }
                    photoFrame++;
                }
            } else {
                photoFrame = 0;
                photoCount = 0;
            }
            break;
        }
            
        default:
            break;
    }
    
    
    
    
    
    
    /*
     if (photoCount < imageArr.count) {
     //        int frameRemainder = photoFrame%FRAMES;
     if (photoFrame<(FRAMES/2)) {
     float frameToFloat = [[NSNumber numberWithInt: photoFrame] floatValue];
     videoPreview.image = [self scaleImage:imageArr[photoCount] toScale:frameToFloat/(FRAMES/2)];
     } else if (photoFrame<FRAMES){
     videoPreview.image = imageArr[photoCount];
     } else {
     photoFrame = 0;
     photoCount++;
     }
     photoFrame++;
     } else {
     photoFrame = 0;
     photoCount = 0;
     }
     */
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)saveBtnPressed:(id)sender {
    [self testCompressionSession];
    NSLog(@"saved");
}

- (void)effect1 {
    effectType = 1;
    photoCount = 0;
    photoFrame = 0;
}

- (void)effect2 {
    effectType = 2;
    photoCount = 0;
    photoFrame = 0;
}

- (void)effect3 {
    effectType = 3;
    photoCount = 0;
    photoFrame = 0;
}

- (void)musicMode {
    effectSelect.hidden = true;
    musicSelect.hidden = false;
}

- (void)effectMode {
    effectSelect.hidden = false;
    musicSelect.hidden = true;
}

- (void)music1 {
    
    
}




@end



