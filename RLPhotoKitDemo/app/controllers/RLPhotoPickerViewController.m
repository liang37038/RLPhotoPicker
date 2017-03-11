//
//  RLPhotoPickerViewController.m
//
//
//  Created by Richard Liang on 16/7/14.
//
//

#import "RLPhotoPickerViewController.h"
#import "RLImageCollectionViewCell.h"
#import "RLAlbumSelectionView.h"
#import "RLAlbumsListView.h"

#define ItemsNumberEachRow  3
#define ItemSpacing         2

static CGSize AssetGridThumbnailSize;

@interface RLPhotoPickerViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>
@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;

@property (strong, nonatomic) NSMutableArray <RLCommonAsset *>*assetsDatasource;

@property (assign, nonatomic) BOOL permisionGranted;

@property (strong, nonatomic) NSMutableArray *selectedAssetArray;

@property (strong, nonatomic) RLAlbumSelectionView *albumSelectionView;

@property (strong, nonatomic) RLAlbumsListView *albumListView;

@end

@implementation RLPhotoPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavigationbar];
    [self setupViews];
    [self setupCollectionView];
    [self checkPermision];
}

- (void)setupNavigationbar{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_nav_close_black"] style:UIBarButtonItemStyleDone target:self action:@selector(didClickLeftBarItemAction)];
    self.navigationItem.titleView = self.albumSelectionView;
}

- (void)checkPermision{
    __weak __typeof(&*self)weakSelf = self;
    [[RLAssetManager shareInstance]requestAuthorization:^(RLAuthorizationStatus status) {
        switch (status) {
            case RLAuthorizationStatusAuthorized: {
                weakSelf.permisionGranted = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf fetchLocalPhotos];
                });
                break;
            }
            case RLAuthorizationStatusDenied: {
                break;
            }
            case RLAuthorizationStatusNotDetermined: {
                break;
            }
        }
    }];
}

- (void)setupViews{
    __weak __typeof(&*self)weakSelf = self;
    self.albumSelectionView.albumSelectionBlock = ^(BOOL isOpen){
        if (isOpen) {
            [weakSelf.albumListView showAlbumList];
        }else{
            [weakSelf.albumListView hideAlbumList];
        }
    };
    self.albumListView.selectedBlock = ^(PHAssetCollection *collection){
        weakSelf.specifiedCollection = collection;
    };
    [self.view addSubview:self.albumListView];
}

- (void)setupCollectionView{
    self.imagesCollectionView.backgroundColor = [UIColor whiteColor];
    self.imagesCollectionView.delegate = self;
    self.imagesCollectionView.dataSource = self;
    [self.imagesCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([RLImageCollectionViewCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([RLImageCollectionViewCell class])];
    AssetGridThumbnailSize = CGSizeMake((SCREEN_WIDTH - (ItemsNumberEachRow - 1) * ItemSpacing)/ItemsNumberEachRow, (SCREEN_WIDTH - (ItemsNumberEachRow - 1) * ItemSpacing)/ItemsNumberEachRow);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (void)didClickLeftBarItemAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 获取本地相机胶卷的相片
 默认操作
 */
- (void)fetchLocalPhotos{
    WEAK_SELF
    [[RLAssetManager shareInstance]fetchAllPhotoAssetswithCallback:^(NSArray<RLCommonAsset *> *assets) {
        weakSelf.assetsDatasource = [assets mutableCopy];
        [weakSelf.imagesCollectionView reloadData];
    }];
}

#pragma mark - Setter

- (void)setSpecifiedCollection:(PHAssetCollection *)specifiedCollection{
    _specifiedCollection = specifiedCollection;
    [self.assetsDatasource removeAllObjects];
    self.albumSelectionView.collectionTitle = specifiedCollection.localizedTitle;
    self.albumSelectionView.open = NO;
    [self.assetsDatasource addObjectsFromArray:[[RLAssetManager shareInstance]fetchAssetFromCollection:specifiedCollection]];
    [self.imagesCollectionView reloadData];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error == nil) {
        __weak __typeof(&*self)weakSelf = self;
        [[RLAssetManager shareInstance]fetchAllPhotoAssetswithCallback:^(NSArray<RLCommonAsset *> *assets) {
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didSelectedAssets:)]) {
                    [weakSelf.delegate didSelectedAssets:@[[assets firstObject].resource]];
                }
            }];
        }];
    }else{
        
    }
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == 0) {
        __weak __typeof(&*self)weakSelf = self;
        //        [[GGImagePickerHelper sharedInstance]showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera allowsEditing:NO finishPickingImageBlock:^(UIImage *image) {
        //            UIImageWriteToSavedPhotosAlbum(image, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        //        }];
    }else{
        RLCommonAsset *commonAsset = [self.assetsDatasource objectAtIndex:indexPath.item - 1];
        NSMutableArray *selectedAssets = [NSMutableArray array];
        if ([commonAsset.resource isKindOfClass:[PHAsset class]]) {
            [selectedAssets addObject:commonAsset.resource];
        }else{
            NSLog(@"Resource 不是 PHAsset类型！");
        }
        __weak __typeof(&*self)weakSelf = self;
        [self dismissViewControllerAnimated:YES completion:^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didSelectedAssets:)]) {
                [weakSelf.delegate didSelectedAssets:[selectedAssets mutableCopy]];
            }
        }];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    RLImageCollectionViewCell *thumbCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([RLImageCollectionViewCell class]) forIndexPath:indexPath];
    if (indexPath.item == 0) {
        thumbCell.thumbImageView.image = [UIImage imageNamed:@"icon_photo_camera"];
    }else{
        RLCommonAsset *commonAsset = [self.assetsDatasource objectAtIndex:indexPath.item - 1];
        thumbCell.commonAsset = commonAsset;
    }
    return thumbCell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.assetsDatasource.count + 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return AssetGridThumbnailSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return ItemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return ItemSpacing;
}
#pragma mark - Getter

- (NSMutableArray *)selectedAssetArray{
    if (!_selectedAssetArray) {
        _selectedAssetArray = [NSMutableArray array];
    }
    return _selectedAssetArray;
}

- (RLAlbumSelectionView *)albumSelectionView{
    if (!_albumSelectionView) {
        _albumSelectionView = [[NSBundle mainBundle]loadNibNamed:NSStringFromClass([RLAlbumSelectionView class]) owner:nil options:nil].firstObject;
        _albumSelectionView.frame = CGRectMake(0, 0, 150, 44);
    }
    return _albumSelectionView;
}

- (RLAlbumsListView *)albumListView{
    if (!_albumListView) {
        _albumListView = [[RLAlbumsListView alloc]initWithFrame:CGRectMake(0, - (SCREEN_HEIGHT), SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    }
    return _albumListView;
}


@end
