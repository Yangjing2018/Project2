//
//  AlbumListController.m
//  Project2-PhotoPicker-OC
//
//  Created by YangJing on 2018/3/19.
//  Copyright © 2018年 YangJing. All rights reserved.
//

#import "AlbumListController.h"
#import "PhotoPickerManager.h"
#import "AlbumListCell.h"
#import "PhotoListController.h"

@interface AlbumListController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation AlbumListController

- (instancetype)initWithDelegate:(id<PhotoPickerDelegate>)delegate maxCount:(NSInteger)maxCount {
    self = [super init];
    if (self) {
        self.maxCount = maxCount;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"相册";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    
    [[PhotoPickerManager manager] allAlbumsIfRefresh:YES success:^(NSArray<AlbumModel *> *result) {
        [self.tableView reloadData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addSubViews];

            PhotoListController *subVC = [[PhotoListController alloc] init];
            subVC.model = [PhotoPickerManager manager].defaultAlbum;
            subVC.delegate = self.delegate;
            subVC.maxCount = self.maxCount;
            [self.navigationController pushViewController:subVC animated:NO];
        });
    } failure:^{
        [self addSubViews];

    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

//MARK: - private methods
- (void)dismiss {
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoPickerControllerDidCancel:)]) {
        [self.delegate photoPickerControllerDidCancel:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//MARK: - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AlbumListCell *cell = [tableView dequeueReusableCellWithIdentifier:AlbumListCellID];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

//MARK: - tableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PhotoListController *subVC = [[PhotoListController alloc] init];
    subVC.model = self.dataArray[indexPath.row];
    subVC.delegate = self.delegate;
    subVC.maxCount = self.maxCount;
    [self.navigationController pushViewController:subVC animated:YES];
}

//MARK: - configSubviews
- (void)addSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
}

//MARK: - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 80;
        [_tableView registerClass:[AlbumListCell class] forCellReuseIdentifier:AlbumListCellID];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] initWithArray:[PhotoPickerManager manager].albumArray];
    }
    return _dataArray;
}

@end
