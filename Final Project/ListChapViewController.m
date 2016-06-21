//
//  ListChapViewController.m
//  Final Project
//
//  Created by Hung Ga 123 on 6/20/16.
//  Copyright © 2016 HungVu. All rights reserved.
//

#import "ListChapViewController.h"

@interface ListChapViewController ()

@end

@implementation ListChapViewController
-(void) loadListChap:(NSString*)UrlString {
    NSMutableArray *newChaps = [[NSMutableArray alloc] init];
    //Chapter Name and Url
    NSString *chapterNameXpathQueryString = @"//ul[@class='list-chapter']/li/a";
    NSArray *chapterNameNodes = [[APIClient sharedInstance] loadFromUrl:UrlString
                                                   withXpathQueryString:chapterNameXpathQueryString];
    for (TFHppleElement *element in chapterNameNodes) {
        ChapterName *chapterName = [[ChapterName alloc] init];
        chapterName.title = [element objectForKey:@"title"];
        chapterName.url = [element objectForKey:@"href"];
        ChapDetail *chapDetail = [[ChapDetail alloc] init];
        [newChaps addObject:chapDetail];
        chapDetail.chapterName = chapterName;
    }
    self.chapDetailObjects = newChaps;
    [self.tableView reloadData];
}
-(void) loadSummary:(NSString*)UrlString {
    NSMutableArray *newSummarys = [[NSMutableArray alloc] init];
    //Summary
    NSString *summaryContentXpathQueryString = @"//div[@class='desc-text']";
    NSArray *summaryContentNodes = [[APIClient sharedInstance] loadFromUrl:UrlString
                                                      withXpathQueryString:summaryContentXpathQueryString];
    for (TFHppleElement *element in summaryContentNodes) {
        SummaryContent *summaryContent = [[SummaryContent alloc] init];
        summaryContent.textContent = @"";
        for (TFHppleElement *child in element.children) {
            if(child.content != nil) {
                summaryContent.textContent = [summaryContent.textContent stringByAppendingString:child.content];
            } else if([child.tagName isEqualToString:@"p"]) {
                if(child.firstChild.content != nil) {
                    summaryContent.textContent = [summaryContent.textContent stringByAppendingString:child.firstChild.content];
                }
            }
        }
        Summary *summary = [[Summary alloc] init];
        [newSummarys addObject:summary];
        summary.summaryContent = summaryContent;
    }
    //Rating
    NSString *ratingXpathQueryString = @"//span[@itemprop='ratingValue']";
    NSArray *ratingContentNodes = [[APIClient sharedInstance] loadFromUrl:UrlString
                                                     withXpathQueryString:ratingXpathQueryString];
    for (TFHppleElement *element in ratingContentNodes) {
        Rating *rating = [[Rating alloc] init];
        rating.title = element.firstChild.content;
        Summary *summary = [[Summary alloc] init];
        if(newSummarys.count > 0) {
            summary = [newSummarys objectAtIndex:0];
            summary.rating = rating;
        } else {
            [newSummarys addObject:summary];
            summary = [newSummarys objectAtIndex:0];
            summary.rating = rating;
        }
    }
    self.summaryObjects = newSummarys;
    [self viewDidLoad];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chapDetailObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomCell3 *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell3" forIndexPath:indexPath];
    ChapDetail  *chapDetailOfThisCell = [self.chapDetailObjects objectAtIndex:indexPath.row];
    cell.lblLink.text = chapDetailOfThisCell.chapterName.url;
    cell.lblChapterName.text = chapDetailOfThisCell.chapterName.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.chapContentVCL = [sb instantiateViewControllerWithIdentifier:@"5"];
    ChapDetail *chapOfThisCell = [self.chapDetailObjects objectAtIndex:indexPath.row];
    [self.chapContentVCL loadChapContent:chapOfThisCell.chapterName.url];
    [self.navigationController pushViewController:self.chapContentVCL animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    Summary *summary = [[Summary alloc] init];
    summary = [self.summaryObjects objectAtIndex:0];
    self.lblSummaryContent.text = summary.summaryContent.textContent;
    self.lblRating.text = summary.rating.title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end