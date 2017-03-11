//
//  RLImageCollectionViewCell.m
//  RLPhotoKitDemo
//
//  Created by Richard Liang on 16/7/1.
//  Copyright © 2016年 lwj. All rights reserved.
//

#import "RLImageCollectionViewCell.h"

@interface RLImageCollectionViewCell()

@end

@implementation RLImageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.thumbImageView.contentMode =  UIViewContentModeScaleAspectFill;
    self.thumbImageView.backgroundColor = [UIColor lightGrayColor];
}

- (void)setCommonAsset:(RLCommonAsset *)commonAsset{
    _commonAsset = commonAsset;
    __weak __typeof(&*self)weakSelf = self;
    [commonAsset requestThumbnailImageWithSize:self.frame.size completion:^(UIImage *thumbImage, NSDictionary *dict) {
        weakSelf.thumbImageView.image = thumbImage;
    }];
}

@end
