

// CellFrame
#define CELL_ROW 4
#define CELL_MARGIN 5
#define CELL_LINE_MARGIN CELL_MARGIN
// 通知
#define PICKER_TAKE_DONE @"PICKER_TAKE_DONE"
// 间距
#define TOOLBAR_IMG_MARGIN 2
#define TOOLBAR_HEIGHT 44

#import "ZLPhotoPickerAssetsViewController.h"
#import "ZLPhotoPickerCollectionView.h"
#import "ZLPhotoPickerGroup.h"
#import "ZLPhotoPickerDatas.h"
#import "ZLPhotoPickerCollectionViewCell.h"
#import "ZLPhotoPickerFooterCollectionReusableView.h"
#import "ZLPhotoPickerBrowserViewController.h"
#import "UIView+Extension.h"
#import "UIView+ZLAutoLayout.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString *const _cellIdentifier = @"cell";
static NSString *const _footerIdentifier = @"FooterView";
static NSString *const _identifier = @"toolBarThumbCollectionViewCell";
@interface ZLPhotoPickerAssetsViewController () <ZLPhotoPickerCollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,ZLPhotoPickerBrowserViewControllerDataSource,ZLPhotoPickerBrowserViewControllerDelegate>

// 相片View
@property (nonatomic , strong) ZLPhotoPickerCollectionView *collectionView;
// 标记View
@property (nonatomic , weak) UILabel *makeView;
@property (nonatomic , strong) UIButton *doneBtn;
// 数据源
@property (nonatomic , strong) NSMutableArray *assets;
// 记录选中的assets
@property (nonatomic , strong) NSMutableArray *selectAssets;

@end

@implementation ZLPhotoPickerAssetsViewController

#pragma mark - getter
- (UIButton *)doneBtn{
    if (!_doneBtn) {
        
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:91/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        rightBtn.enabled = YES;
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        rightBtn.frame = CGRectMake(15, 0, [UIScreen mainScreen].bounds.size.width - 30, 44);
        rightBtn.layer.masksToBounds = YES ;
        rightBtn.layer.cornerRadius = 22 ;
        rightBtn.backgroundColor = [UIColor colorWithRed:252/255.0 green:163/255.0 blue:17/255.0 alpha:1];
        [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        self.doneBtn = rightBtn;
        
    }
    
    return _doneBtn;
}

- (NSMutableArray *)selectAssets{
    if (!_selectAssets) {
        _selectAssets = [NSMutableArray array];
    }
    return _selectAssets;
}

- (void)setSelectPickerAssets:(NSArray *)selectPickerAssets{
    NSSet *set = [NSSet setWithArray:selectPickerAssets];
    _selectPickerAssets = [set allObjects];
    
    if (!self.assets) {
        self.assets = [NSMutableArray arrayWithArray:selectPickerAssets];
    }else{
        [self.assets addObjectsFromArray:selectPickerAssets];
    }
    
    for (ZLPhotoAssets *assets in selectPickerAssets) {
        if ([assets isKindOfClass:[ZLPhotoAssets class]]) {
            [self.selectAssets addObject:assets];
        }
    }

    self.collectionView.lastDataArray = nil;
    self.collectionView.isRecoderSelectPicker = YES;
    self.collectionView.selectAsstes = self.selectAssets;
    NSInteger count = self.selectAssets.count;
    self.makeView.hidden = count;
    self.doneBtn.enabled = (count > 0);
}

#pragma mark collectionView

#pragma mark -红点标记View
- (UILabel *)makeView{
    if (!_makeView) {
        UILabel *makeView = [[UILabel alloc] init];
        makeView.textColor = [UIColor whiteColor];
        makeView.textAlignment = NSTextAlignmentCenter;
        makeView.font = [UIFont systemFontOfSize:13];
        makeView.frame = CGRectMake(-5, -5, 20, 20);
        makeView.hidden = YES;
        makeView.layer.cornerRadius = makeView.frame.size.height / 2.0;
        makeView.clipsToBounds = YES;
        makeView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:makeView];
        self.makeView = makeView;
    }
    return _makeView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化按钮 和 导航条
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:91/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.enabled = YES;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    rightBtn.frame = CGRectMake(15, self.view.frame.size.height - 54 - 64, [UIScreen mainScreen].bounds.size.width - 30, 44);
    rightBtn.layer.masksToBounds = YES ;
    rightBtn.layer.cornerRadius = 22 ;
    rightBtn.backgroundColor = [UIColor colorWithRed:252/255.0 green:163/255.0 blue:17/255.0 alpha:1];
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    self.doneBtn = rightBtn ;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(rightBtn);
    NSString *widthVfl =  @"H:|-15-[rightBtn]-15-|";
    NSString *heightVfl = @"V:[rightBtn(44)]-10-|";
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:0 views:views]];
    
    self.view.bounds = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat cellW = (self.view.frame.size.width - CELL_MARGIN * CELL_ROW + 1 - 20 ) / CELL_ROW;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(cellW, cellW);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = CELL_LINE_MARGIN;
    layout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, TOOLBAR_HEIGHT * 2);
    
    ZLPhotoPickerCollectionView *collectionView = [[ZLPhotoPickerCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    // 时间置顶
    collectionView.status = ZLPickerCollectionViewShowOrderStatusTimeDesc;
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [collectionView registerClass:[ZLPhotoPickerCollectionViewCell class] forCellWithReuseIdentifier:_cellIdentifier];
    // 底部的View
    [collectionView registerClass:[ZLPhotoPickerFooterCollectionReusableView class]  forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:_footerIdentifier];
    
    collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10) ;
    collectionView.collectionViewDelegate = self;
    [self.view insertSubview:collectionView belowSubview:self.doneBtn];
    self.collectionView = collectionView;
    
    NSDictionary *views2 = NSDictionaryOfVariableBindings(collectionView);
    
    NSString *widthVfl2 = @"H:|-0-[collectionView]-0-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl2 options:0 metrics:nil views:views2]];
    
    NSString *heightVfl2= @"V:|-0-[collectionView]-64-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl2 options:0 metrics:nil views:views2]];
}

#pragma mark 初始化所有的组
- (void) setupAssets{
    if (!self.assets) {
        self.assets = [NSMutableArray array];
    }
    __block NSMutableArray *assetsM = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    
    [[ZLPhotoPickerDatas defaultPicker] getGroupPhotosWithGroup:self.assetsGroup finished:^(NSArray *assets) {
        [assets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL *stop) {
            ZLPhotoAssets *zlAsset = [[ZLPhotoAssets alloc] init];
            zlAsset.asset = asset;
            [assetsM addObject:zlAsset];
        }];
        weakSelf.collectionView.dataArray = assetsM;
    }];
}

#pragma mark - setter
-(void)setMinCount:(NSInteger)minCount{
    _minCount = minCount;
    if (self.assets.count > minCount) {
        minCount = 0;
    }else{
        minCount = minCount - self.selectAssets.count;
    }
    self.collectionView.minCount = minCount;
}

- (void)setAssetsGroup:(ZLPhotoPickerGroup *)assetsGroup{
    if (!assetsGroup.groupName.length) return ;
    _assetsGroup = assetsGroup;
    self.title = @"所有图片";
    // 获取Assets
    [self setupAssets];
}


- (void)pickerCollectionViewDidSelected:(ZLPhotoPickerCollectionView *)pickerCollectionView{
    
    self.selectAssets = [NSMutableArray arrayWithArray:pickerCollectionView.selectAsstes];
    NSInteger count = self.selectAssets.count;
    self.makeView.hidden = count;
    self.doneBtn.enabled = (count > 0);
}

#pragma mark -
#pragma mark - UICollectionViewDataSource
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.selectAssets.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
    
    if (self.selectAssets.count > indexPath.item) {
        UIImageView *imageView = [[cell.contentView subviews] lastObject];
        // 判断真实类型
        if (![imageView isKindOfClass:[UIImageView class]]) {
            imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.clipsToBounds = YES;
            [cell.contentView addSubview:imageView];
        }
        
        imageView.tag = indexPath.item;
        imageView.image = [self.selectAssets[indexPath.item] thumbImage];
    }
    return cell;
}

#pragma makr UICollectionViewDelegate
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    ZLPhotoPickerBrowserViewController *browserVc = [[ZLPhotoPickerBrowserViewController alloc] init];
    browserVc.toView = [cell.contentView.subviews lastObject];
    browserVc.currentIndexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:0];
    browserVc.delegate = self;
    browserVc.dataSource = self;
    [self presentViewController:browserVc animated:NO completion:nil];
}

- (NSInteger)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section{
    return self.selectAssets.count;
}

-  (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath{
    ZLPhotoPickerBrowserPhoto *photo = [[ZLPhotoPickerBrowserPhoto alloc] init];
    photo.asset = self.selectAssets[indexPath.row];
    return photo;
}
- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndexPath:(NSIndexPath *)indexPath{
    
    // 删除选中的照片
    ALAsset *asset = self.selectAssets[indexPath.row];
    NSInteger currentPage = 0;
    for (NSInteger i = 0; i < self.collectionView.dataArray.count; i++) {
        ALAsset *photoAsset = self.collectionView.dataArray[i];
        if([[[[asset defaultRepresentation] url] absoluteString] isEqualToString:[[[photoAsset defaultRepresentation] url] absoluteString]]){
            currentPage = i;
            break;
        }
    }
    
    [self.selectAssets removeObjectAtIndex:indexPath.row];
    [self.collectionView.selectsIndexPath removeObject:@(currentPage)];
    [self.collectionView reloadData];
    
    self.makeView.text = [NSString stringWithFormat:@"%ld",self.selectAssets.count];
}

#pragma mark -<Navigation Actions>
#pragma mark -开启异步通知

- (void) back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) done{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_TAKE_DONE object:nil userInfo:@{@"selectAssets":self.selectAssets}];
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc{
    // 赋值给上一个控制器
    self.groupVc.selectAsstes = self.selectAssets;
}

// 生成一个纯色图片
- (UIImage *)creatImageWithSize:(CGSize)size color:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end