//
//  RLAlbumsListView.m
// 
//
//  Created by Richard Liang on 2017/3/6.
//
//

#import "RLAlbumsListView.h"
#import "RLAlbumListTableViewCell.h"
#import <Photos/Photos.h>

@interface RLAlbumsListView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *ablumsArray;

@property (nonatomic, strong) NSMutableArray *resultFetchesArray;
@property (nonatomic, strong) NSMutableArray *displayAlbumsArray;


@end


@implementation RLAlbumsListView{
    UITableView *_tableView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupViewsWithFrame:frame];
        [self fetchPhotos];
    }
    return self;
}

- (void)setupViewsWithFrame:(CGRect)frame{
    _tableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([RLAlbumListTableViewCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([RLAlbumListTableViewCell class])];
    _tableView.tableFooterView = [[UIView alloc]init];
    [self addSubview:_tableView];
}

- (void)fetchAlbums{
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [self addAlbumsFromFetchResult:smartAlbums];
}

//相册列表需要与微信一模一样
- (void)fetchPhotos{
    PHFetchResult *userLibraryResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    PHFetchResult *myPhotoStream = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *userFavorites = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumFavorites options:nil];
    PHFetchResult *panoramas = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumPanoramas options:nil];
    PHFetchResult *recentlyAdded = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil];
    PHFetchResult *otherAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    [self addAlbumsFromFetchResult:userLibraryResult];
    if (myPhotoStream && myPhotoStream.count > 0) {
        [self addAlbumsFromFetchResult:myPhotoStream];
    }
    [self addAlbumsFromFetchResult:userFavorites];
    [self addAlbumsFromFetchResult:panoramas];
    
    if (([[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending)) {
        PHFetchResult *selfPortraits = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumSelfPortraits options:nil];
        [self addAlbumsFromFetchResult:selfPortraits];
    }
    [self addAlbumsFromFetchResult:recentlyAdded];
    if (([[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending)) {
        PHFetchResult *screenShots = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots options:nil];
        [self addAlbumsFromFetchResult:screenShots];
    }
    [self addAlbumsFromFetchResult:otherAlbums];
    [_tableView reloadData];
}

- (void)addAlbumsFromFetchResult:(PHFetchResult *)fetchResult{
    for (PHAssetCollection *assetCollection in fetchResult ) {
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        if (assetsFetchResult.count > 0) {
            [self.displayAlbumsArray addObject:assetCollection];
            [self.resultFetchesArray addObject:assetsFetchResult];
        }
    }
}


/**
 显示相册列表
 */
- (void)showAlbumList{
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    } completion:^(BOOL finished) {
    }];
}

/**
 隐藏相册列表
 */
- (void)hideAlbumList{
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.frame = CGRectMake(0, - ([UIScreen mainScreen].bounds.size.height), [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    } completion:^(BOOL finished) {
    }];
}


#pragma mark - UITableView Delegate && UITableView Datasource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    /**
     *  全部相册 + 智能相册的数量
     */
    return self.displayAlbumsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RLAlbumListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([RLAlbumListTableViewCell class]) forIndexPath:indexPath];

    PHAssetCollection *cellCollection = [self.displayAlbumsArray objectAtIndex:indexPath.row];
    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:cellCollection options:nil];
    cell.albumTitleLabel.text = [NSString stringWithFormat:@"%@（%ld）",  cellCollection.localizedTitle?cellCollection.localizedTitle:@"",assetsFetchResult.count];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.synchronous = NO;

    [[PHImageManager defaultManager]requestImageForAsset:assetsFetchResult.lastObject targetSize:CGSizeMake(cell.lastestImageView.frame.size.width * 2, cell.lastestImageView.frame.size.height * 2) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            cell.lastestImageView.image = result;
        }
    }];
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PHAssetCollection *cellCollection = [self.displayAlbumsArray objectAtIndex:indexPath.row];
    if (self.selectedBlock) {
        self.selectedBlock(cellCollection);
    }
    [self hideAlbumList];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Loop through the section fetch results, replacing any fetch results that have been updated.
        NSMutableArray *updatedSectionFetchResults = [self.resultFetchesArray mutableCopy];
        __block BOOL reloadRequired = NO;
        
        [self.resultFetchesArray enumerateObjectsUsingBlock:^(PHFetchResult *collectionsFetchResult, NSUInteger index, BOOL *stop) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            if (changeDetails != nil) {
                [updatedSectionFetchResults replaceObjectAtIndex:index withObject:[changeDetails fetchResultAfterChanges]];
                reloadRequired = YES;
            }
        }];
        if (reloadRequired) {
            self.resultFetchesArray = updatedSectionFetchResults;
            [_tableView reloadData];
        }
    });
}

#pragma mark -
#pragma mark ---------------- Getter ------------------

- (NSMutableArray *)assetsArray {
    if (!_ablumsArray) {
        _ablumsArray = [NSMutableArray array];
    }
    return _ablumsArray;
}

- (NSMutableArray *)displayAlbumsArray{
    if (!_displayAlbumsArray) {
        _displayAlbumsArray = [NSMutableArray array];
    }
    return _displayAlbumsArray;
}


- (NSMutableArray *)resultFetchesArray{
    if (!_resultFetchesArray) {
        _resultFetchesArray = [NSMutableArray array];
    }
    return _resultFetchesArray;
}

@end
