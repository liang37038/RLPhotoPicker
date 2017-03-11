//
//  RLAssetManager.m
//  RLPhotoKitDemo
//
//  Created by Richard Liang on 16/7/1.
//  Copyright © 2016年 lwj. All rights reserved.
//

#import "RLAssetManager.h"
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation RLAssetManager
{
    NSArray             *_alAssetAllPhotos;
    PHFetchResult       *_phAssetAllPhotos;
    PHAssetCollection   *_allPhotosCollection;
    BOOL                _usePhotoKit;
}
+ (instancetype)shareInstance{
    static RLAssetManager *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[RLAssetManager alloc]init];
    });
    return _shareInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            _usePhotoKit = NO;
        }else{
            _usePhotoKit = YES;
        }
    }
    return self;
}

- (ALAssetsLibrary *)shareLibrary{
    static ALAssetsLibrary *_shareLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareLibrary = [[ALAssetsLibrary alloc]init];
    });
    return _shareLibrary;
}

- (PHCachingImageManager *)shareManager{
    static PHCachingImageManager *_cachingManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cachingManager = [[PHCachingImageManager alloc]init];
    });
    return _cachingManager;
}

- (void)requestAuthorization:(RLAuthorizationStatusResult)statusCallback{
    if (_usePhotoKit) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            switch (status) {
                case PHAuthorizationStatusNotDetermined:
                    statusCallback(RLAuthorizationStatusNotDetermined);
                    break;
                case PHAuthorizationStatusDenied:
                    statusCallback(RLAuthorizationStatusDenied);
                    break;
                case PHAuthorizationStatusAuthorized:
                    statusCallback(RLAuthorizationStatusAuthorized);
                    break;
                case PHAuthorizationStatusRestricted:
                    statusCallback(RLAuthorizationStatusDenied);
                    break;
            }
        }];
    }else{
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        switch (status) {
            case ALAuthorizationStatusNotDetermined:
                statusCallback(RLAuthorizationStatusNotDetermined);
                break;
            case ALAuthorizationStatusDenied:
                statusCallback(RLAuthorizationStatusDenied);
                break;
            case ALAuthorizationStatusAuthorized:
                statusCallback(RLAuthorizationStatusAuthorized);
                break;
            case ALAuthorizationStatusRestricted:
                statusCallback(RLAuthorizationStatusDenied);
                break;
        }
    }
}

- (void)fetchAllPhotoAssetswithCallback:(PhotoAssetsCallback)callback{
    NSMutableArray *commonAssetsArray = [NSMutableArray array];
    if (_usePhotoKit) {
        PHFetchResult *phPhotoAssets = [self phAssetAllPhotos];
        for (PHAsset *phAsset in phPhotoAssets){
            RLCommonAsset *commonAsset = [[RLCommonAsset alloc]initWithResouce:phAsset];
            [commonAssetsArray addObject:commonAsset];
        }
        callback(commonAssetsArray);
    }else{
        [self alAssetAllPhotosWithCallback:^(NSArray *alPhotoAssets) {
            for (ALAsset *alAsset in alPhotoAssets){
                RLCommonAsset *commonAsset = [[RLCommonAsset alloc]initWithResouce:alAsset];
                [commonAssetsArray addObject:commonAsset];
            }
            callback(commonAssetsArray);
        }];
    }
}

- (void)alAssetAllPhotosWithCallback:(PhotoAssetsCallback)callback{
    __block ALAssetsGroup *assetGroup;
    __block NSMutableArray *assetsArray = [NSMutableArray array];
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
            {
                if (group == nil) {
                    return;
                }
                NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                if (nType == ALAssetsGroupSavedPhotos) {
                    assetGroup = group;
                    [assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                    [assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if (result == nil) {
                            return;
                        }
                        [assetsArray addObject:result];
                    }];
                    if (callback) {
                        callback(assetsArray);
                    }
                }
            };
            void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                
            };
            [[[RLAssetManager shareInstance]shareLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll
                                                                        usingBlock:assetGroupEnumerator
                                                                      failureBlock:assetGroupEnumberatorFailure];
        }
    });
    
}

- (NSArray<RLCommonAsset *> *)fetchAssetFromCollection:(PHAssetCollection *)collection{
    NSMutableArray<RLCommonAsset *> *commonAssetsArray = [NSMutableArray new];
    PHFetchOptions *assetOptions = [[PHFetchOptions alloc] init];
    assetOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    assetOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %ld", PHAssetMediaTypeImage];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:assetOptions];
    for (PHAsset *phAsset in fetchResult){
        RLCommonAsset *commonAsset = [[RLCommonAsset alloc]initWithResouce:phAsset];
        [commonAssetsArray addObject:commonAsset];
    }
    return commonAssetsArray;
}

- (PHFetchResult *)phAssetAllPhotos{
    PHFetchOptions *assetOptions = [[PHFetchOptions alloc] init];
    assetOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    assetOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %ld", PHAssetMediaTypeImage];
    _phAssetAllPhotos = [PHAsset fetchAssetsInAssetCollection:[self allPhotosCollection] options:assetOptions];
    return _phAssetAllPhotos;
}

- (PHAssetCollection *)allPhotosCollection{
    if (!_allPhotosCollection) {
        PHFetchResult *userLibraryResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        _allPhotosCollection = userLibraryResult.firstObject;
    }
    return _allPhotosCollection;
}

@end
