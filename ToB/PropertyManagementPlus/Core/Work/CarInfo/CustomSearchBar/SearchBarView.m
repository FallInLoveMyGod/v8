//
//  SearchBarView.m
//  PropertyManagementPlus
//
//  Created by jana on 17/5/28.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

#import "PropertyManagementPlus-Swift.h"
#import "SearchBarView.h"
#import "ZTSearchBar.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"

@interface SearchBarView () <UISearchBarDelegate,UISearchDisplayDelegate,UISearchResultsUpdating>
@property (nonatomic, strong) NSString *placeHolder;
@property (nonatomic, strong) NSMutableArray *filteredListContent;
@property (nonatomic, assign) SearchBarType searchBarType;
@end

@implementation SearchBarView

- (instancetype)initWithFrame:(CGRect)frame placeHolder:(NSString *)holder searchBarType:(SearchBarType)searchBarType {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.placeHolder = holder;
        self.searchBarType = searchBarType;
        [self addSubview:self.textSearchDisplayController.searchBar];
    }
    return self;
}

#pragma mark - UISearchBarDelegate,UISearchDisplayDelegate,UISearchResultsUpdating

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    _filteredListContent = [[NSMutableArray alloc]init];
    
    if (searchController.searchBar.text.length>0&&![ChineseInclude isIncludeChineseInString:searchController.searchBar.text]) {
        
        if (_searchBarType == SearchBarTypeCar) {
            for (InfoMaterialModel *model  in self.dataSource){
                
                NSArray *names = @[(model.Code),
                                   (model.Name),
                                   (model.Type),
                                   (model.Parkinglot)];
                for (NSString *keyName in names) {
                    [self checkWithName:keyName info:model searchController:searchController];
                }
            }
        }else if (_searchBarType == SearchBarTypeMaterial) {
            
            for (InfoEquipmentMaterialModel *model  in self.dataSource){
                NSArray *names = @[(model.equipmentname),
                                   (model.equipmentno),
                                   (model.equipmenttype),
                                   (model.equipmentstate),
                                   (model.equipmentlocation)];
                for (NSString *keyName in names) {
                    [self checkWithName:keyName info:model searchController:searchController];
                }
            }
            
        }
        else if (_searchBarType == SearchBarTypeIntent) {
            for (InfoCustomerIntentMaterialModel *model  in self.dataSource){
                
                NSString *name = @"";
                name = model.CName;
                [self checkWithName:name info:model searchController:searchController];
            }
        }else if (_searchBarType == SearchBarTypeEnergyMeter) {
            
            for (EnergyMeterReadingModel *model  in self.dataSource){
                NSArray *names = @[(model.Location),
                                   (model.MeterName),
                                   (model.MeterCode),
                                   (model.CustomerName),
                                   (model.PProjectName),
                                   (model.PBuildingName),
                                   (model.PFloorName),
                                   (model.PRoomName)];
                for (NSString *keyName in names) {
                    [self checkWithName:keyName info:model searchController:searchController];
                }
            }
            
        }
        
    } else if (searchController.searchBar.text.length>0 && [ChineseInclude isIncludeChineseInString:searchController.searchBar.text]) {
        
        if (_searchBarType == SearchBarTypeCar) {
            for (InfoMaterialModel *model in self.dataSource) {
                
                NSArray *names = @[(model.Code),
                                   (model.Name),
                                   (model.Type),
                                   (model.Parkinglot)];
                for (NSString *keyName in names) {
                    NSRange titleResult=[keyName rangeOfString:searchController.searchBar.text options:NSCaseInsensitiveSearch];
                    if (titleResult.length>0) {
                        [_filteredListContent addObject:model];
                    }
                }
                
            }
        }else if (_searchBarType == SearchBarTypeMaterial) {
            for (InfoEquipmentMaterialModel *model in self.dataSource) {
                
                NSArray *names = @[(model.equipmentname),
                                   (model.equipmentno),
                                   (model.equipmenttype),
                                   (model.equipmentstate),
                                   (model.equipmentlocation)];
                for (NSString *keyName in names) {
                    NSRange titleResult=[keyName rangeOfString:searchController.searchBar.text options:NSCaseInsensitiveSearch];
                    if (titleResult.length>0) {
                        [_filteredListContent addObject:model];
                    }
                }
            }
        }else if (_searchBarType == SearchBarTypeIntent) {
            for (InfoCustomerIntentMaterialModel *model in self.dataSource) {
                
                NSString *name = @"";
                
                name = model.CName;
                NSRange titleResult=[name rangeOfString:searchController.searchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [_filteredListContent addObject:model];
                }
            }
        }else if (_searchBarType == SearchBarTypeEnergyMeter) {
            for (EnergyMeterReadingModel *model in self.dataSource) {
                
                NSArray *names = @[(model.Location),
                                   (model.MeterName),
                                   (model.MeterCode),
                                   (model.CustomerName),
                                   (model.PProjectName),
                                   (model.PBuildingName),
                                   (model.PFloorName),
                                   (model.PRoomName)];
                for (NSString *keyName in names) {
                    NSRange titleResult=[keyName rangeOfString:searchController.searchBar.text options:NSCaseInsensitiveSearch];
                    if (titleResult.length>0) {
                        [_filteredListContent addObject:model];
                    }
                }
            }
        }
    }
    
    
    // If searchResultsController
    if (self.textSearchDisplayController.searchResultsController) {
        
        // Present SearchResultsTableViewController as the topViewController
        SearchResultsTableViewController *vc = (SearchResultsTableViewController *)self.textSearchDisplayController.searchResultsController;
        vc.isCommon = self.isCommon;
        self.textSearchDisplayController.searchBar.superview.frame = CGRectMake(0, 0, self.textSearchDisplayController.searchBar.superview.bounds.size.width, self.textSearchDisplayController.searchBar.superview.bounds.size.height);
        // Update searchResults
        vc.filteredListContent = self.filteredListContent;
        vc.key = self.textSearchDisplayController.searchBar.text;
        vc.infoMaterialType = self.searchBarType;
        // And reload the tableView with the new data
        [vc.contentTableView reloadData];
        [vc changeOffSet];
    }
}

- (void)checkWithName:(NSString *)name info:(id)info searchController:(UISearchController *)searchController{
    
    if ([ChineseInclude isIncludeChineseInString:name]) {
        NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:name];
        NSRange titleResult=[tempPinYinStr rangeOfString:searchController.searchBar.text options:NSCaseInsensitiveSearch];
        
        if (titleResult.length>0) {
            [_filteredListContent  addObject:info];
            return;
        }
        else {
            NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:name];
            NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:searchController.searchBar.text options:NSCaseInsensitiveSearch];
            if (titleHeadResult.length>0) {
                [_filteredListContent addObject:info];
                return;
            }
        }
        NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:name];
        NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:searchController.searchBar.text options:NSCaseInsensitiveSearch];
        if (titleHeadResult.length>0) {
            [_filteredListContent  addObject:info];
        }
    }
    else {
        NSRange titleResult=[name rangeOfString:searchController.searchBar.text options:NSCaseInsensitiveSearch];
        if (titleResult.length>0) {
            [_filteredListContent addObject:info];
        }
    }
}


#pragma mark - event response

#pragma mark - getters & setters


- (UISearchController *)textSearchDisplayController {
    if (!_textSearchDisplayController) {
        _textSearchDisplayController = [[UISearchController alloc] initWithSearchResultsController:[[SearchResultsTableViewController alloc] init]];
//        _textSearchDisplayController = [[UISearchController alloc] init];
        _textSearchDisplayController.searchBar.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _textSearchDisplayController.searchBar.placeholder = self.placeHolder;
        _textSearchDisplayController.searchBar.delegate = self;
        _textSearchDisplayController.definesPresentationContext = YES;
        _textSearchDisplayController.hidesNavigationBarDuringPresentation = NO;
        _textSearchDisplayController.searchBar.keyboardType = UIKeyboardTypeDefault;
        _textSearchDisplayController.searchResultsUpdater = self;
    }
    return _textSearchDisplayController;
}

@end
