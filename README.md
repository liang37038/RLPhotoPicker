##PhotoKit

**How to use**

```objective-c
    RLPhotoPickerViewController *photoPicker = [[RLPhotoPickerViewController alloc]initWithNibName:NSStringFromClass([RLPhotoPickerViewController class]) bundle:[NSBundle mainBundle]];
```

**Implement delegate to get PHAsset**

```objective-c
@protocol RLPhotoPickerViewControllerDelegate <NSObject>

- (void)didSelectedAssets:(NSArray<PHAsset *> *)assets;

@end
```

**Screenshot**
![](https://media.giphy.com/media/3oKIPaJ0Zw8neiTnhu/source.gif)



