//
//  TPPhotoPreviewViewController.m
//  PhotoPicker
//
//  Created by Loong Lam on 15/11/16.
//  Copyright © 2015年 Loong Lam. All rights reserved.
//

#import "TPPhotoPreviewViewController.h"
#import "TPPhotoPreviewCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

const NSString *kNotificationReloadPreReleaseImages = @"kNotificationReloadPreReleaseImages";

@interface TPPhotoPreviewViewController ()
<
UIScrollViewDelegate
>

@property (assign, nonatomic) BOOL isFirstTimeViewDidLayoutSubviews; // variable name could be re-factored
@property (assign, nonatomic) BOOL previewMode;

@end

@implementation TPPhotoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionViewCell];
    [self.collectionView reloadData];
    self.isFirstTimeViewDidLayoutSubviews = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupGestures];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.isFirstTimeViewDidLayoutSubviews) {
        if (self.currentIndexPath) {
            [self.collectionView setContentOffset:CGPointMake(CGRectGetWidth(self.collectionView.frame) * self.currentIndexPath.item, 0)];
        }
        self.isFirstTimeViewDidLayoutSubviews = NO;
    }
}

/**
 *  解决collectionView边缘左滑不能pop的问题
 */
- (void)setupGestures{
    for (UIGestureRecognizer *gr in self.collectionView.gestureRecognizers) {
        [gr requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupCollectionViewCell {
    static NSString *identifier = @"TPPhotoPreviewCollectionViewCell";
    UINib *nib = [UINib nibWithNibName:identifier bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

#pragma mark -
#pragma mark -------------------- UICollectionViewDelegateFlowLayout --------------------
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

#pragma mark -
#pragma mark -------------------- UICollectionViewDataSource --------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = self.assetsArray.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TPPhotoPreviewCollectionViewCell *cell = (TPPhotoPreviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TPPhotoPreviewCollectionViewCell class]) forIndexPath:indexPath];
    
    RLCommonAsset *photoResource = [self.assetsArray objectAtIndex:indexPath.row];
    
    cell.commonAsset = photoResource;

    return cell;
}

#pragma mark -
#pragma mark -------------------- UICollectionViewDelegate --------------------
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
