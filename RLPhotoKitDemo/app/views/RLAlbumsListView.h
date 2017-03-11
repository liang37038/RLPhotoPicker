//
//  RLAlbumsListView.h
//  
//
//  Created by Richard Liang on 2017/3/6.
//
//

#import <UIKit/UIKit.h>
#import "RLAssetManager.h"

typedef void(^SelectedCollectionBlock)(PHAssetCollection *specifiedCollection);

@interface RLAlbumsListView : UIView

@property (copy, nonatomic) SelectedCollectionBlock selectedBlock;

- (void)showAlbumList;

- (void)hideAlbumList;

@end
