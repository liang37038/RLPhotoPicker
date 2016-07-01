//
//  RLBrowserViewController.m
//  RLPhotoKitDemo
//
//  Created by Richard Liang on 16/7/1.
//  Copyright © 2016年 lwj. All rights reserved.
//

#import "RLBrowserViewController.h"
#import "RLImageCollectionViewCell.h"
#import "RLAssetManager.h"

static CGSize AssetGridThumbnailSize;

#define ItemsNumberEachRow  4
#define ItemSpacing         2

@interface RLBrowserViewController ()
<
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
>
@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;

@property (strong, nonatomic) NSArray <RLCommonAsset *>*assetsDatasource;

@end

@implementation RLBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imagesCollectionView.delegate = self;
    self.imagesCollectionView.dataSource = self;
    [self.imagesCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([RLImageCollectionViewCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([RLImageCollectionViewCell class])];
    AssetGridThumbnailSize = CGSizeMake((SCREEN_WIDTH - (ItemsNumberEachRow - 1) * ItemSpacing)/ItemsNumberEachRow, (SCREEN_WIDTH - (ItemsNumberEachRow - 1) * ItemSpacing)/ItemsNumberEachRow);
    
    WEAK_SELF
    [[RLAssetManager shareInstance]fetchAllPhotoAssetswithCallback:^(NSArray<RLCommonAsset *> *assets) {
        weakSelf.assetsDatasource = assets;
        [weakSelf.imagesCollectionView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionView Delegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    RLImageCollectionViewCell *thumbCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([RLImageCollectionViewCell class]) forIndexPath:indexPath];
    RLCommonAsset *commonAsset = [self.assetsDatasource objectAtIndex:indexPath.row];
    thumbCell.thumbImageView.image = [commonAsset thumbnailWithSize:AssetGridThumbnailSize];
    return thumbCell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.assetsDatasource.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return AssetGridThumbnailSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return ItemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return ItemSpacing;
}


@end
