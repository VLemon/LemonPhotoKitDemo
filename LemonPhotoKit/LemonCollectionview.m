//
//  LemonCollectionview.m
//  LemonPhotoKit
//
//  Created by Skye on 16/3/11.
//  Copyright © 2016年 com.chuangkit. All rights reserved.
//

#import "LemonCollectionview.h"
#import "LemonCell.h"
#import "CKWaterFallLayout.h"
#import <Photos/Photos.h>

#define COLUMNCOUNT 3
@interface LemonCollectionview ()

@property (nonatomic,strong) PHFetchResult *allPhotos;

@property (nonatomic,strong) PHImageManager *manager;

@end

@implementation LemonCollectionview

- (PHImageManager *)manager
{
    if (_manager == nil) {
        _manager = [PHImageManager defaultManager];
    }
    return _manager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CKWaterFallLayout *waterFallLayout = (CKWaterFallLayout *)self.collectionViewLayout;
    waterFallLayout.needBigPicture = NO;
    waterFallLayout.columnCount = COLUMNCOUNT;
    
    [self loadImageArray];
}

- (void)loadImageArray
{
    
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    self.allPhotos = allPhotos;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    CKWaterFallLayout *waterFallLayout = (CKWaterFallLayout *)self.collectionViewLayout;
    NSMutableArray *itemArray = [NSMutableArray array];
    for (PHAsset *asset in self.allPhotos) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[ItemHeightKey] = @(asset.pixelHeight);
        dict[ItemWidthKey]  = @(asset.pixelWidth);
        [itemArray addObject:dict];
    }
    waterFallLayout.itemList = itemArray;
    return  self.allPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LemonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    PHAsset *asset = [self.allPhotos objectAtIndex:indexPath.item];
    CGFloat width = self.collectionView.bounds.size.width / COLUMNCOUNT;
    CGFloat height = width / asset.pixelWidth * asset.pixelHeight;
    
    PHImageRequestOptions *ops = [[PHImageRequestOptions alloc] init];
    ops.resizeMode = PHImageRequestOptionsResizeModeExact;
    ops.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    //经过测试size越大获取图片的速度越慢，如果滑动过快会导致加载错位
    [self.manager requestImageForAsset:asset
                            targetSize:CGSizeMake(width, height)
                           contentMode:PHImageContentModeDefault
                               options:ops
                         resultHandler:^(UIImage *result, NSDictionary *info) {
                             cell.imageView.image = result;
                         }];
    
    
    return cell;
}

@end
