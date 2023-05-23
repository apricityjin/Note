//
//  ImagesTableViewController.m
//  DemoShowImages
//
//  Created by apricity on 2023/5/18.
//

#import "ImagesTableViewController.h"
#import "ImagesModel.h"
#import "ImagePickerTableViewCell.h"
#import "ShowImagesViewController.h"

@interface ImagesTableViewController ()
<ShowImagesViewControllerDelegate>

@property (nonatomic, copy) NSArray<ImagesModel *> * dataAry;

@property (nonatomic, strong) UIBarButtonItem * rightBarButtonItem;

@end

@implementation ImagesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"图片";
    [self.tableView registerClass:ImagePickerTableViewCell.class
           forCellReuseIdentifier:NSStringFromClass(ImagePickerTableViewCell.class)];
    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    dispatch_async(dispatch_queue_create("com.test", DISPATCH_QUEUE_SERIAL), ^{
        [self loadData];
    });
}

- (void)loadData {
    self.dataAry = [ImagesModel getImagesModels];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int i = 0;
    for (ImagesModel * model in self.dataAry) {
        if (model.number > 0) {
            i++;
        }
    }
    return i;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImagePickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ImagePickerTableViewCell.class) forIndexPath:indexPath];
    
    // Configure the cell...
    cell.cellModel = self.dataAry[indexPath.row];
    
    return cell;
}

#pragma mark - ShowImagesViewControllerDelegate

- (void)deleteImagesWithRow:(NSInteger)row
                      count:(NSInteger)count {
    self.dataAry[row].number -= count;
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ImagesModel * model = self.dataAry[indexPath.row];
    
    ShowImagesViewController * vc = [[ShowImagesViewController alloc] initWithRow:indexPath.row number:model.number];
    vc.title = model.title;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - event action

- (void)rightBarButtonItemDidClicked {
    [self loadData];
}

#pragma mark - getter

- (UIBarButtonItem *)rightBarButtonItem {
    if (_rightBarButtonItem == nil) {
        _rightBarButtonItem = [[UIBarButtonItem alloc]
                               initWithTitle:@"重置"
                               style:(UIBarButtonItemStyleDone)
                               target:self
                               action:@selector(rightBarButtonItemDidClicked)];
    }
    return _rightBarButtonItem;
}

@end
