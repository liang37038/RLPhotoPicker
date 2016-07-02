//
//  TPPhotoPreviewCollectionViewCell.m
//  PhotoPicker
//
//  Created by Loong Lam on 15/11/16.
//  Copyright © 2015年 Loong Lam. All rights reserved.
//

#import "TPPhotoPreviewCollectionViewCell.h"

static const CGFloat kTPMinImageScale = 1.0f;
static const CGFloat kTPMaxImageScale = 2.5f;

@interface TPPhotoPreviewCollectionViewCell ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView * imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation TPPhotoPreviewCollectionViewCell

- (void)dealloc {
    NSLog(@"dealloc");
}

- (void)prepareForReuse {
    [self resetState];
}

- (void)resetState{
    if (self.scrollView.zoomScale > 1) {
        CGRect scrollViewFrame = self.scrollView.frame;
        CGRect rectToZoom = CGRectMake(CGRectGetWidth(scrollViewFrame) / 2.0, CGRectGetHeight(scrollViewFrame) / 2.0, CGRectGetWidth(scrollViewFrame), CGRectGetHeight(scrollViewFrame));
        [self.scrollView zoomToRect:rectToZoom animated:NO];
    }
}

- (void)awakeFromNib {
    // Initialization code
    self.scrollView.minimumZoomScale = kTPMinImageScale;
    self.scrollView.maximumZoomScale = kTPMaxImageScale;
    self.scrollView.zoomScale = 1;
    self.scrollView.bounces = YES;
    [self addGestureRecognizer];
}

- (void)setCommonAsset:(RLCommonAsset *)commonAsset{
    self.scrollView.delegate = self;
    if (_commonAsset != commonAsset) {
        _commonAsset = commonAsset;
        if (!self.imageView) {
            self.imageView = [[UIImageView alloc]init];
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            self.imageView.userInteractionEnabled = YES;
            [self.scrollView addSubview:self.imageView];
        }
        self.imageView.image = nil;
        [self.indicatorView startAnimating];
        WEAK_SELF
        [_commonAsset requestPreviewImageWithCompletion:^(UIImage *image, NSDictionary *info) {
            weakSelf.imageView.image = image;
            weakSelf.imageView.bounds = [weakSelf boundsFromImageDimensions:image.size];
            [weakSelf centerScrollViewContents];
            [weakSelf.indicatorView stopAnimating];
        } withProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {

        }];
    }
}

- (void)addGestureRecognizer {
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDobleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:doubleTapRecognizer];
}

- (void)didDobleTap:(UITapGestureRecognizer*)recognizer {
    CGPoint pointInView = [recognizer locationInView:self.imageView];
    [self zoomInZoomOut:pointInView];
}

# pragma mark - UIScrollView Delegate
- (void)centerScrollViewContents {
    CGSize boundsSize = [UIScreen mainScreen].bounds.size;

    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    self.imageView.frame = contentsFrame;
    self.scrollView.contentSize = contentsFrame.size;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    
}

- (void) zoomInZoomOut:(CGPoint)point {
    CGFloat newZoomScale = self.scrollView.zoomScale > (self.scrollView.maximumZoomScale / 2) ? self.scrollView.minimumZoomScale : self.scrollView.maximumZoomScale;
    
    CGSize scrollViewSize = self.scrollView.bounds.size;
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = point.x - (w / 2.0f);
    CGFloat y = point.y - (h / 2.0f);
    CGRect rectToZoom = CGRectMake(x, y, w, h);
    [self.scrollView zoomToRect:rectToZoom animated:YES];
}

- (CGRect)boundsFromImageDimensions:(CGSize) imageDimensions {
    if(imageDimensions.height == 0 || imageDimensions.width == 0) {
       return CGRectZero;
    }
    
    CGSize newImageSize = [self getScaleRect:imageDimensions targetSize:[UIScreen mainScreen].bounds.size];
    return CGRectMake(0.0f, 0.0f, newImageSize.width, newImageSize.height);
}

- (CGSize)getScaleRect:(CGSize)originSize targetSize:(CGSize)maxSize{
    CGFloat originalWidth = originSize.width;
    CGFloat originalHeight = originSize.height;
    
    CGFloat widthScale = originalWidth / maxSize.width;
   
    CGFloat finalWidth = maxSize.width;
    
    CGFloat finalHeight = originalHeight / widthScale;
    
    if (originalHeight == 0 || originalWidth == 0) {
        return CGSizeZero;
    }else{
        return CGSizeMake(finalWidth, finalHeight);
    }
}

@end
