//
//  SelectImageShowView.h
//  TZImagePickerController
//
//  Created by jana on 16/12/27.
//  Copyright © 2016年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectImageShowViewDelegate <NSObject>

- (void)presentMyViewController:(UIViewController *)viewController animated:(BOOL)animated;
@optional
- (UIImage *)terminateDealPictures:(UIImage *)picture;

@end

@interface SelectImageShowView : UIView

@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@property (nonatomic, strong) NSMutableArray *selectedAssets;
//是否为预览图片（待完善功能）
//@property (nonatomic, assign) BOOL isBrowse;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) id <SelectImageShowViewDelegate> delegate;

//默认允许
@property (nonatomic, assign) BOOL allowDealWithPhoto;
@property (nonatomic, assign) BOOL allowSelectLocalPhoto;

@end
