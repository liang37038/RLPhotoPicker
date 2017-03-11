//
//  RLAlbumSelectionView.m
//
//
//  Created by Richard Liang on 2017/3/6.
//
//

#import "RLAlbumSelectionView.h"

@interface RLAlbumSelectionView()

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UILabel *collectionTitleLabel;
@property (strong, nonatomic) UITapGestureRecognizer *singleTapGesture;
@end

@implementation RLAlbumSelectionView{
    BOOL _isOpen;
    
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:self.singleTapGesture];
}

- (void)setOpen:(BOOL)open{
    _open = open;
    CGFloat rotateAngel = _open?M_PI:0;
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.arrowImageView.transform = CGAffineTransformMakeRotation(rotateAngel);
    } completion:^(BOOL finished) {
        weakSelf.userInteractionEnabled = YES;
    }];
}

- (void)setCollectionTitle:(NSString *)collectionTitle{
    _collectionTitle = collectionTitle;
    self.collectionTitleLabel.text = collectionTitle;
}

- (void)singleTapAction:(id)sender{
    __block BOOL blockIsOpen = _open;
    self.userInteractionEnabled = NO;
    if (self.albumSelectionBlock) {
        _open = !_open;
        blockIsOpen = _open;
        self.albumSelectionBlock(blockIsOpen);
    }
    CGFloat rotateAngel = blockIsOpen?M_PI:0;
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.arrowImageView.transform = CGAffineTransformMakeRotation(rotateAngel);
    } completion:^(BOOL finished) {
        weakSelf.userInteractionEnabled = YES;
    }];
}

#pragma mark - Getter

- (UITapGestureRecognizer *)singleTapGesture{
    if (!_singleTapGesture) {
        _singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
    }
    return _singleTapGesture;
}

@end
