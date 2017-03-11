//
//  RLAlbumSelectionView.h
//
//
//  Created by Richard Liang on 2017/3/6.
//
//

#import <UIKit/UIKit.h>

typedef void(^AlbumSelectionBlock)(BOOL isOpen);

@interface RLAlbumSelectionView : UIView

@property (strong, nonatomic) NSString *collectionTitle;
@property (copy, nonatomic) AlbumSelectionBlock albumSelectionBlock;

@property (assign, nonatomic) BOOL open;

@end
