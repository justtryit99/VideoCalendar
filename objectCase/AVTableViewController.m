//
//  AVTableViewController.m
//  objectCase
//
//  Created by  AndyLiou on 2016/4/21.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import "AVTableViewController.h"
#import "AVtableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "DetailViewController.h"
#import <AVKit/AVKit.h>

@interface AVTableViewController ()


@property(nonatomic,strong)NSMutableArray * AVurlArray;

@end

@implementation AVTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getFileUrl];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateTableView) name:@"updataTableView" object:nil];
    
}
-(NSURL *)getFileUrl{
    //取得URL
    NSString * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSLog(@"%@",path);

    
//    NSFileManager * fileManager = [NSFileManager defaultManager];
//    NSArray * urlLocation = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
//    NSString * url = [urlLocation objectAtIndex:0];
//    NSArray * paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
//    
//    for (NSString * mp4 in paths) {
//       
//        if ([mp4 hasSuffix:@".mp4"]) {
//            NSString * mp4String = [url stringByAppendingString:mp4];
//            [self.AVurlArray addObject:mp4String];
//        }
//        
//    }
//    NSLog(@"avurlarray : %@",self.AVurlArray);
    //所有檔案名稱存到array
    NSArray * paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    self.AVurlArray = [[NSMutableArray alloc] init];
   // 找出document mp4檔存在array
    for (NSString*url in paths) {
        if ([url hasSuffix:@".mp4"]) {
            NSString * stringfile = [NSString stringWithFormat:@"file://"];
            NSString * mp4Path = [stringfile stringByAppendingString:path];
          NSString * jpgString2 = [mp4Path stringByAppendingString:@"/"];
            NSString * jpgString = [jpgString2 stringByAppendingString:url];
            [self.AVurlArray addObject:jpgString];
           
        }
        NSLog(@"avurl %@", self.AVurlArray);
    }

    return 0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}



#pragma mark - Table view data source
//Cell
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.AVurlArray.count;
}
//Cell view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AVtableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
   
    
    NSURL * url = [NSURL URLWithString:[self.AVurlArray objectAtIndex:indexPath.row]];
    AVURLAsset * asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetImageGenerator * generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = true;
    
    
    CGImageRef cgImage = [generator copyCGImageAtTime:CMTimeMake(40, 10) actualTime:nil error:nil];
    UIImage * image = [UIImage imageWithCGImage:cgImage];


    
        
        cell.AVImageView.image=image;


    
    return cell;

}



//Detailviewcontroller View
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    
    //準備下一頁
    DetailViewController * detailVC =[self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailVC.test = self.AVurlArray[indexPath.row];
    detailVC.detailArray = self.AVurlArray;
//    [self presentViewController:detailVC animated:YES completion:nil];
    [self.navigationController pushViewController:detailVC animated:YES];
  
    
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


// reload tableview
-(void)updateTableView
{
    [self.tableView reloadData];
}
//移除聽口號
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"updataTableView" object:nil];
}

@end
