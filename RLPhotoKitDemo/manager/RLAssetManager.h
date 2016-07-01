//
//  RLAssetManager.h
//  RLPhotoKitDemo
//
//  Created by Richard Liang on 16/7/1.
//  Copyright © 2016年 lwj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLCommonAsset.h"

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

@end
