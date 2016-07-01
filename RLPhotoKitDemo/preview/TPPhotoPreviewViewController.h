//
//  TPPhotoPreviewViewController.h
//  PhotoPicker
//
//  Created by Loong Lam on 15/11/16.
//  Copyright © 2015年 Loong Lam. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "TPPhotoPickerViewController.h"

extern const NSString *kNotificationReloadPreReleaseImages;

@protocol TPPhotoPreviewCollectionViewDelegate <NSObject>

- (void)collection:(UICollectionView *)collectionView didSelectedIndexPath:(NSIndexPath *)indexPath;

@end

@interface TPPhotoPreviewViewController : UIViewController
/**
 *  可以存放Asset、URL、UIImage
 */
@property (nonatomic, strong) NSMutableArray *assetsArray;

@property (nonatomic, strong) NSIndexPath *currentIndexPath;
//@property (weak, nonatomic) id<TPPhotoPickerViewControllerDelegate> photoDelegate;
@property (weak, nonatomic) id<TPPhotoPreviewCollectionViewDelegate> photoCollectionViewDelegate;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (assign, nonatomic) BOOL showDeleteButton;

@end
