//
//  RLImageCollectionViewCell.m
//  RLPhotoKitDemo
//
//  Created by Richard Liang on 16/7/1.
//  Copyright © 2016年 lwj. All rights reserved.
//

#import "RLImageCollectionViewCell.h"

@implementation RLImageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.thumbImageView.contentMode =  UIViewContentModeScaleAspectFill;
    self.thumbImageView.backgroundColor = [UIColor lightGrayColor];
}

@end
