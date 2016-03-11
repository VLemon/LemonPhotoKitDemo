//
//  CKWaterFallLayout.m
//  CKWaterFall
//
//  Created by Skye on 15/11/25.
//  Copyright © 2015年 com.chuangkit. All rights reserved.
//

#import "CKWaterFallLayout.h"

@interface CKWaterFallLayout()
// 所有item的属性的数组
@property (nonatomic, strong) NSArray *layoutAttributesArray;

@end

@implementation CKWaterFallLayout

/**
 *  布局准备方法 当collectionView的布局发生变化时 会被调用
 *  通常是做布局的准备工作 itemSize.....
 *  UICollectionView 的 contentSize 是根据 itemSize 动态计算出来的
 */
- (void)prepareLayout {
    
    // 根据列数 计算item的宽度 宽度是一样的
    CGFloat contentWidth = self.collectionView.bounds.size.width - self.sectionInset.left - self.sectionInset.right;
    CGFloat marginX = self.minimumInteritemSpacing;
    CGFloat itemWidth = (contentWidth - marginX * (self.columnCount - 1)) / self.columnCount;
    // 计算布局属性
    [self computeAttributesWithItemWidth:itemWidth];
}

/**
 *  根据itemWidth计算布局属性
 */
- (void)computeAttributesWithItemWidth:(CGFloat)itemWidth {
    
    // 定义一个列高数组 记录每一列的总高度
    CGFloat columnHeight[self.columnCount];
    // 定义一个记录每一列的总item个数的数组
    NSInteger columnItemCount[self.columnCount];
    
    // 初始化
    for (int i = 0; i < self.columnCount; i++) {
        columnHeight[i] = self.sectionInset.top;
        columnItemCount[i] = 0;
        
    }
    
    // 遍历 goodsList 数组计算相关的属性
    NSInteger index = 0;
    
    NSMutableArray *attributesArray = [NSMutableArray arrayWithCapacity:self.itemList.count];
    for (NSDictionary *item in self.itemList) {
        
        // 建立布局属性
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        //判断cell 类型( 根据需要设置判断条件)
        if([[item objectForKey:ItemWidthKey] floatValue] / [[item objectForKey:ItemHeightKey] floatValue] > 1.5 && self.needBigPicture)
        {
            //找出最合适列号
            NSInteger column = [self findSuitPosition:columnHeight];
            //数据同时添加两行
            columnItemCount[column]++;
            columnItemCount[column + 1]++;
            
            CGFloat itemX = (itemWidth + self.minimumInteritemSpacing) * column + self.sectionInset.left;
            
            if (columnHeight[column] < columnHeight[column + 1]) {
                columnHeight[column] = columnHeight[column + 1];
            }
            else
            {
                columnHeight[column + 1] = columnHeight[column];
            }
            CGFloat itemY = columnHeight[column];
            CGFloat itemH = ([[item objectForKey:ItemHeightKey] floatValue] * itemWidth * 2 +  self.minimumInteritemSpacing )/ [[item objectForKey:ItemWidthKey] floatValue];
            //累加列高
            columnHeight[column] += itemH + self.minimumLineSpacing;
            columnHeight[column + 1] += itemH + self.minimumLineSpacing;
            attributes.frame = CGRectMake(itemX, itemY, itemWidth * 2 + self.minimumInteritemSpacing, itemH);
            [attributesArray addObject:attributes];
            
        }
        else
        {
            // 找出最短列号
            NSInteger column = [self shortestColumn:columnHeight];
            // 数据追加在最短列
            columnItemCount[column]++;
            // X值
            CGFloat itemX = (itemWidth + self.minimumInteritemSpacing) * column + self.sectionInset.left;
            // Y值
            CGFloat itemY = columnHeight[column];
            // 等比例缩放 计算item的高度
            CGFloat itemH = [[item objectForKey:ItemHeightKey] floatValue] * itemWidth / [[item objectForKey:ItemWidthKey] floatValue];
            // 设置frame
            attributes.frame = CGRectMake(itemX, itemY, itemWidth, itemH);
            [attributesArray addObject:attributes];
            // 累加列高
            columnHeight[column] += itemH + self.minimumLineSpacing;
        }
        index++;
        
    }
    
    // 找出最高列列号
    NSInteger column = [self highestColumn:columnHeight];
    // 根据最高列设置itemSize 使用总高度的平均值
    CGFloat itemH = (columnHeight[column] - self.minimumLineSpacing * columnItemCount[column]) / columnItemCount[column];
    self.itemSize = CGSizeMake(itemWidth, itemH);
    
    // 添加页脚属性
    NSIndexPath *footerIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *footerAttr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:footerIndexPath];
    footerAttr.frame = CGRectMake(0, columnHeight[column], self.collectionView.bounds.size.width, 50);
    [attributesArray addObject:footerAttr];
    
    // 给属性数组设置数值
    self.layoutAttributesArray = attributesArray.copy;
    self.maxHeight = columnHeight[[self highestColumn:columnHeight]];
}

/**
 *  找出columnHeight数组中最短列号 追加数据的时候追加在最短列中
 */
- (NSInteger)shortestColumn:(CGFloat *)columnHeight {
    
    CGFloat max = CGFLOAT_MAX;
    NSInteger column = 0;
    for (int i = 0; i < self.columnCount; i++) {
        if (columnHeight[i] < max) {
            max = columnHeight[i];
            column = i;
        }
    }
    return column;
}


/**
 *  找出columnHeight数组中最高列号
 */
- (NSInteger)highestColumn:(CGFloat *)columnHeight {
    CGFloat min = 0;
    NSInteger column = 0;
    for (int i = 0; i < self.columnCount; i++) {
        if (columnHeight[i] > min) {
            min = columnHeight[i];
            column = i;
        }
    }
    return column;
}

- (NSInteger )findSuitPosition:(CGFloat *)columnHeight
{
    NSMutableArray *array = [NSMutableArray array];
    
    //计算每个相邻的列之间的差
    for(int i = 0; i < self.columnCount ; i++)
    {
        if (i < 1)  continue;
        CGFloat difference = columnHeight[i] - columnHeight[i-1];
        [array addObject:@{@"difference":@(difference),@"column":@(i)}];
    }
    
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if (fabs([[obj1 objectForKey:@"difference"] floatValue]) <= fabs([[obj2 objectForKey:@"difference"] floatValue])) {
            return NSOrderedAscending;
        }
        else
            return NSOrderedDescending;
    }];
    
    // 判断是否合理
    NSInteger index = [[array.firstObject objectForKey:@"column"] integerValue] - 1;
//    if(columnHeight[index] - columnHeight[[self shortestColumn:columnHeight]] > 200)
//    {
//        index = [[array[2] objectForKey:@"column"] integerValue] - 1;
//    }
//    
    return index;
}

/**
 *  进行排序
 */
- (NSArray *)sortColumns:(CGFloat *)columnHeight
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < self.columnCount; i++) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"columnHeight"] = @(columnHeight[i]);
        dict[@"columnNum"]  = @(i);
        [array addObject:dict];
    }
    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        if ( [[obj1 objectForKey:@"columnHeight"] floatValue] <= [[obj2 objectForKey:@"columnHeight"] floatValue]) {
            return NSOrderedAscending;
        }
        else
            return NSOrderedDescending;
    }];
    return sortedArray;
}

/**
 *  跟踪效果：当到达要显示的区域时 会计算所有显示item的属性
 *           一旦计算完成 所有的属性会被缓存 不会再次计算
 *  @return 返回布局属性(UICollectionViewLayoutAttributes)数组
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    // 直接返回计算好的布局属性数组
    return self.layoutAttributesArray;
}

#pragma mark - 子类必须重写此方法并使用它来返回的宽度和高度的视图的内容。这些值表示的宽度和高度的所有内容，视图使用此信息来配置其自身内容的大小，以便滚动。
- (CGSize)collectionViewContentSize
{
    CGSize size = CGSizeMake(0, self.maxHeight);
    return size;
}



@end
