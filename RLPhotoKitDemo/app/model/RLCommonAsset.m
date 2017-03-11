//
//  RLCommonAsset.m
//  RLPhotoKitDemo
//
//  Created by Richard Liang on 16/7/1.
//  Copyright © 2016年 lwj. All rights reserved.
//

#import "RLCommonAsset.h"
#import "RLAssetManager.h"

@interface RLCommonAsset()

@property (strong, nonatomic) UIImage *originImage;
@property (strong, nonatomic) UIImage *thumbnailImage;
@property (strong, nonatomic) UIImage *previewImage;

@property (assign, nonatomic) BOOL usePhotoKit;

@end

@implementation RLCommonAsset
{
    PHAsset *_phAsset;
    ALAsset *_alAsset;
    ALAssetRepresentation *_alAssetRepresentation;
    
    NSURL   *_imageURL;
}

- (instancetype)init{
    if (self = [super init]) {
        _assetType = AssetTypeNone;
    }
    return self;
}

- (instancetype)initWithResouce:(id)resource{
    if (self = [self init]) {
        _resource = resource;
        if ([resource isKindOfClass:[ALAsset class]]) {
            return [self initWithALAsset:resource];
        }else if([resource isKindOfClass:[PHAsset class]]){
            return [self initWithPHAsset:resource];
        }else if([resource isKindOfClass:[NSURL class]]){
            return [self initWithImageURL:resource];
        }else if([resource isKindOfClass:[UIImage class]]){
            return [self initWithImage:resource];
        }
    }
    return self;
}

- (instancetype)initWithALAsset:(ALAsset *)alAsset{
    if (self = [self init]) {
        _alAsset = alAsset;
        _alAssetRepresentation = alAsset.defaultRepresentation;
        _assetType = AssetTypeAsset;
    }
    return self;
}

- (instancetype)initWithPHAsset:(PHAsset *)phAsset{
    if (self = [self init]) {
        _phAsset = phAsset;
        _usePhotoKit = YES;
        _assetType = AssetTypeAsset;
    }
    return self;
}

- (instancetype)initWithImageURL:(NSURL *)imageURL{
    if (self = [self init]) {
        _imageURL = imageURL;
        _usePhotoKit = YES;
        _assetType = AssetTypeURL;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image{
    if (self = [self init]) {
        _previewImage = image;
        _usePhotoKit = YES;
        _assetType = AssetTypeImage;
    }
    return self;
}

- (NSURL *)imageURL{
    return _imageURL;
}

- (UIImage *)originImage {
    if (_originImage) {
        return _originImage;
    }
    __block UIImage *resultImage;
    if (_usePhotoKit) {
        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
        phImageRequestOptions.synchronous = YES;
        [[[RLAssetManager shareInstance] shareManager] requestImageForAsset:_phAsset
                                                                              targetSize:PHImageManagerMaximumSize
                                                                             contentMode:PHImageContentModeDefault
                                                                                 options:phImageRequestOptions
                                                                           resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                               resultImage = result;
                                                                           }];
    } else {
        CGImageRef fullResolutionImageRef = [_alAssetRepresentation fullResolutionImage];
        // 通过 fullResolutionImage 获取到的的高清图实际上并不带上在照片应用中使用“编辑”处理的效果，需要额外在 AlAssetRepresentation 中获取这些信息
        NSString *adjustment = [[_alAssetRepresentation metadata] objectForKey:@"AdjustmentXMP"];
        if (adjustment) {
            // 如果有在照片应用中使用“编辑”效果，则需要获取这些编辑后的滤镜，手工叠加到原图中
            NSData *xmpData = [adjustment dataUsingEncoding:NSUTF8StringEncoding];
            CIImage *tempImage = [CIImage imageWithCGImage:fullResolutionImageRef];
            
            NSError *error;
            NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:xmpData
                                                         inputImageExtent:tempImage.extent
                                                                    error:&error];
            CIContext *context = [CIContext contextWithOptions:nil];
            if (filterArray && !error) {
                for (CIFilter *filter in filterArray) {
                    [filter setValue:tempImage forKey:kCIInputImageKey];
                    tempImage = [filter outputImage];
                }
                fullResolutionImageRef = [context createCGImage:tempImage fromRect:[tempImage extent]];
            }
        }
        // 生成最终返回的 UIImage，同时把图片的 orientation 也补充上去
        resultImage = [UIImage imageWithCGImage:fullResolutionImageRef scale:[_alAssetRepresentation scale] orientation:(UIImageOrientation)[_alAssetRepresentation orientation]];
    }
    _originImage = resultImage;
    return resultImage;
}

- (NSInteger)requestOriginImageWithCompletion:(void (^)(UIImage *, NSDictionary *))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
    if (_usePhotoKit) {
        if (_originImage) {
            // 如果已经有缓存的图片则直接拿缓存的图片
            if (completion) {
                completion(_originImage, nil);
            }
            return 0;
        } else {
            PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
            imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
            imageRequestOptions.progressHandler = phProgressHandler;
            return [[[RLAssetManager shareInstance] shareManager] requestImageForAsset:_phAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
                // 排除取消，错误，低清图三种情况，即已经获取到了高清图时，把这张高清图缓存到 _originImage 中
                BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                if (downloadFinined) {
                    _originImage = result;
                }
                if (completion) {
                    completion(result, info);
                }
            }];
        }
    } else {
        if (completion) {
            completion([self originImage], nil);
        }
        return 0;
    }
}

- (UIImage *)thumbnailWithSize:(CGSize)size {
    if (_thumbnailImage) {
        return _thumbnailImage;
    }
    __block UIImage *resultImage;
    if (_usePhotoKit) {
        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
        phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
        [[[RLAssetManager shareInstance] shareManager] requestImageForAsset:_phAsset
                                                                              targetSize:CGSizeMake(size.width * ScreenScale, size.height * ScreenScale)
                                                                             contentMode:PHImageContentModeAspectFill options:phImageRequestOptions
                                                                           resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                               resultImage = result;
                                                                           }];
    } else {
        CGImageRef thumbnailImageRef = [_alAsset thumbnail];
        if (thumbnailImageRef) {
            resultImage = [UIImage imageWithCGImage:thumbnailImageRef];
        }
    }
    _thumbnailImage = resultImage;
    return resultImage;
}

- (NSInteger)requestThumbnailImageWithSize:(CGSize)size completion:(void (^)(UIImage *, NSDictionary *))completion {
    if (_usePhotoKit) {
        if (_thumbnailImage) {
            if (completion) {
                completion(_thumbnailImage, nil);
            }
            return 0;
        } else {
            PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
            imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
            // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
            return [[[RLAssetManager shareInstance] shareManager] requestImageForAsset:_phAsset targetSize:CGSizeMake(size.width * ScreenScale, size.height * ScreenScale) contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
                // 排除取消，错误，低清图三种情况，即已经获取到了高清图时，把这张高清图缓存到 _thumbnailImage 中
                BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                if (downloadFinined) {
                    _thumbnailImage = result;
                }
                if (completion) {
                    completion(result, info);
                }
            }];
        }
    } else {
        if (completion) {
            completion([self thumbnailWithSize:size], nil);
        }
        return 0;
    }
}

- (UIImage *)previewImage {
    if (_previewImage) {
        return _previewImage;
    }
    __block UIImage *resultImage;
    if (_usePhotoKit) {
        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.synchronous = YES;
        [[[RLAssetManager shareInstance] shareManager] requestImageForAsset:_phAsset
                                                                              targetSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                             contentMode:PHImageContentModeAspectFill
                                                                                 options:imageRequestOptions
                                                                           resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                               resultImage = result;
                                                                           }];
    } else {
        CGImageRef fullScreenImageRef = [_alAssetRepresentation fullScreenImage];
        resultImage = [UIImage imageWithCGImage:fullScreenImageRef];
    }
    _previewImage = resultImage;
    return resultImage;
}

- (NSInteger)requestPreviewImageWithCompletion:(void (^)(UIImage *, NSDictionary *))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
    if (_usePhotoKit) {
        if (_previewImage) {
            // 如果已经有缓存的图片则直接拿缓存的图片
            if (completion) {
                completion(_previewImage, nil);
            }
            return 0;
        } else {
            PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
            imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
            imageRequestOptions.progressHandler = phProgressHandler;
            return [[[RLAssetManager shareInstance] shareManager] requestImageForAsset:_phAsset targetSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT) contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
                // 排除取消，错误，低清图三种情况，即已经获取到了高清图时，把这张高清图缓存到 _previewImage 中
                BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                if (downloadFinined) {
                    _previewImage = result;
                }
                if (completion) {
                    completion(result, info);
                }
            }];
        }
    } else {
        if (completion) {
            completion([self previewImage], nil);
        }
        return 0;
    }
}

@end
