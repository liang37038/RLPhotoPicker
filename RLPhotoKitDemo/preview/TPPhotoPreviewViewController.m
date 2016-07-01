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
TPPhotoPreviewCollectionViewCellDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
UIScrollViewDelegate
>

@property (assign, nonatomic) BOOL isFirstTimeViewDidLayoutSubviews; // variable name could be re-factored

@property (weak, nonatomic) IBOutlet UIView *navigationView;

//@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@property (assign, nonatomic) BOOL previewMode;
//
//@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//
//@property (weak, nonatomic) IBOutlet UIButton *deleteButton;


@end

@implementation TPPhotoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupCollectionViewCell];
    [self.collectionView reloadData];
    self.isFirstTimeViewDidLayoutSubviews = YES;
    
//    self.deleteButton.hidden = !self.showDeleteButton;
    
    [self setupTitleWithCurrentIndex:@(self.currentIndexPath.row + 1) total:@(self.assetsArray.count)];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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


- (void)setPreviewMode:(BOOL)previewMode{
    CGFloat navigationBarAlpha = 0;
    if (previewMode) {
        navigationBarAlpha = 0;
    }else{
        navigationBarAlpha = 1;
    }
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.navigationView.alpha = navigationBarAlpha;
    }];
    _previewMode = previewMode;
}

/**
 *  解决collectionView边缘左滑不能pop的问题
 */
- (void)setupGestures{
    for (UIGestureRecognizer *gr in self.collectionView.gestureRecognizers) {
        [gr requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    }
}


- (void)setupTitleWithCurrentIndex:(NSNumber *)index total:(NSNumber *)total{
//    self.titleLabel.text = [NSString stringWithFormat:@"%ld/%ld",index.integerValue, total.integerValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupCollectionViewCell {
    static NSString *identifier = @"TPPhotoPreviewCollectionViewCell";
    UINib *nib = [UINib nibWithNibName:identifier bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    [self.collectionView setDelegate:self];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmDeleteImage{
    NSUInteger currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
    [self.assetsArray removeObjectAtIndex:currentIndex];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationReloadPreReleaseImages object:nil];
    if (!self.assetsArray.count) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.collectionView reloadData];
        NSUInteger currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
        if (currentIndex + 1 <= self.assetsArray.count) {
            [self setupTitleWithCurrentIndex:@(currentIndex + 1) total:@(self.assetsArray.count)];
        }else{
            [self setupTitleWithCurrentIndex:@(self.assetsArray.count) total:@(self.assetsArray.count)];
        }
    }
}

- (void)didReceiveSingleTap{
    self.previewMode = !self.previewMode;
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
    cell.delegate = self;
    id photoResource = [self.assetsArray objectAtIndex:indexPath.row];
    if ([photoResource isKindOfClass:[ALAsset class]]) {
        cell.asset = (ALAsset *)photoResource;
    }else if([photoResource isKindOfClass:[UIImage class]]){
        cell.previewImage = (UIImage *)photoResource;
    }else{
        cell.photoURL = (NSString *)photoResource;
    }
    return cell;
}

#pragma mark -
#pragma mark -------------------- UICollectionViewDelegate --------------------
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark -
#pragma mark ------------------- UIScrollViewDelegate -------------------

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSUInteger currentIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    [self setupTitleWithCurrentIndex:@(currentIndex + 1) total:@(self.assetsArray.count)];
}

@end
