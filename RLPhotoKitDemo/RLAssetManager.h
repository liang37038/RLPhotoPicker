//
//  RLAssetManager.h
//  RLPhotoKitDemo
//
//  Created by Richard Liang on 16/7/1.
//  Copyright © 2016年 lwj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "RLCommonAsset.h"

@interface RLAssetManager : NSObject

+ (instancetype)shareInstance;

- (PHCachingImageManager *)shareManager;

- (NSArray <RLCommonAsset *> *)allPhotoAssets;

@end
