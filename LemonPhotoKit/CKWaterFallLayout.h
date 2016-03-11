//
//  CKWaterFallLayout.h
//  CKWaterFall
//
//  Created by Skye on 15/11/25.
//  Copyright © 2015年 com.chuangkit. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ItemWidthKey    @"itemWidth"
#define ItemHeightKey   @"itemheight"

@interface CKWaterFallLayout : UICollectionViewFlowLayout
// 总列数
@property (nonatomic, assign) NSInteger columnCount;

@property (nonatomic,strong) NSArray *itemList;

@property (nonatomic,assign) CGFloat maxHeight;

/**
 *  是否显示大图(跨列)
 */
@property (nonatomic,assign) BOOL needBigPicture;

@end
