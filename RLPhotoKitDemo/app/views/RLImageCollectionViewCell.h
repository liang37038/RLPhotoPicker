//
//  RLImageCollectionViewCell.h
//
//
//  Created by Richard Liang on 16/7/1.
//  Copyright © 2016年 lwj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RLCommonAsset.h"

@interface RLImageCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;

@property (strong, nonatomic) RLCommonAsset *commonAsset;

@end
