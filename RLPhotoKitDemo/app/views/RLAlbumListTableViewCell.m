//
//  RLAlbumListTableViewCell.m
//  
//
//  Created by Richard Liang on 2017/3/6.
//
//

#import "RLAlbumListTableViewCell.h"

@implementation RLAlbumListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lastestImageView.clipsToBounds = YES;
    self.lastestImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
