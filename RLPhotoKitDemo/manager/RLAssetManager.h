//
//  RLAssetManager.h
//  RLPhotoKitDemo
//
//  Created by Richard Liang on 16/7/1.
//  Copyright © 2016年 lwj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLCommonAsset.h"

typedef NS_ENUM(NSInteger, RLAuthorizationStatus){
    RLAuthorizationStatusAuthorized,
    RLAuthorizationStatusDenied,
    RLAuthorizationStatusNotDetermined
};

typedef void(^RLAuthorizationStatusResult)(RLAuthorizationStatus status);

typedef void(^PhotoAssetsCallback)(NSArray<RLCommonAsset *> *assets);

@interface RLAssetManager : NSObject

+ (instancetype)shareInstance;

- (ALAssetsLibrary *)shareLibrary;

- (PHCachingImageManager *)shareManager;

/**
 *  获取 所有照片 下的所有图片
 *
 *  @param callback 结果回调
 */
- (void)fetchAllPhotoAssetswithCallback:(PhotoAssetsCallback)callback;

/**
 *  尝试获取权限
 *
 *  @param status 权限
 */
- (void)requestAuthorization:(RLAuthorizationStatusResult)statusCallback;

@end
