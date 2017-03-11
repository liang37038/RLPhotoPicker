//
//  RLPhotoPickerViewController.h
//
//
//  Created by Richard Liang on 16/7/14.
//
//

#import <UIKit/UIKit.h>
#import "RLAssetManager.h"

@protocol RLPhotoPickerViewControllerDelegate <NSObject>

- (void)didSelectedAssets:(NSArray<PHAsset *> *)assets;

@end

@interface RLPhotoPickerViewController : UIViewController

@property (weak, nonatomic) id<RLPhotoPickerViewControllerDelegate> delegate;

@property (strong, nonatomic) PHAssetCollection *specifiedCollection;

@end
