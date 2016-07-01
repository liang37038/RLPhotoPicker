//
//  TPPhotoPreviewCollectionViewCell.h
//  PhotoPicker
//
//  Created by Loong Lam on 15/11/16.
//  Copyright © 2015年 Loong Lam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol TPPhotoPreviewCollectionViewCellDelegate <NSObject>

@optional

- (void)didReceiveSingleTap;

@end

@interface TPPhotoPreviewCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<TPPhotoPreviewCollectionViewCellDelegate> delegate;

@property (nonatomic, strong) ALAsset *asset;

@property (nonatomic, strong) UIImage *previewImage;

@property (strong, nonatomic) NSString *photoURL;

/**
 *  变回原来的状态
 */
- (void)resetState;

@end
