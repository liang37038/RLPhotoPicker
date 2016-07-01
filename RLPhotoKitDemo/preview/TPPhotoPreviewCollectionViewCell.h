//
//  TPPhotoPreviewCollectionViewCell.h
//  PhotoPicker
//
//  Created by Loong Lam on 15/11/16.
//  Copyright © 2015年 Loong Lam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RLCommonAsset.h"

@interface TPPhotoPreviewCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) RLCommonAsset *commonAsset;

/**
 *  变回原来的状态
 */
- (void)resetState;

@end
