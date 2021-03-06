//
//  PullFooter.m
//  mcapp
//
//  Created by zhuchao on 14/11/21.
//  Copyright (c) 2014年 zhuchao. All rights reserved.
//

#import "PullFooter.h"

@implementation PullFooter

- (id)initWithFrame:(CGRect)frame with:(UIScrollView *)scrollView
{
    self = [super initWithFrame:frame with:scrollView];
    if (self) {
        
        scrollView.infiniteScrollingView.frame = CGRectMake(0, scrollView.superview.height, scrollView.superview.width, SVInfiniteScrollingViewHeight);
        
        @weakify(scrollView);
        [[RACObserve(scrollView, contentSize) filter:^BOOL(id value) {
            @strongify(scrollView);
            return scrollView.contentSize.height>scrollView.bounds.size.height;
        }] subscribeNext:^(id x) {
            @strongify(scrollView);
            scrollView.infiniteScrollingView.frame = CGRectMake(0, scrollView.contentSize.height, scrollView.superview.width, SVInfiniteScrollingViewHeight);
        }];
        
        
        
        _arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-down"]];
        _arrowImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_arrowImage];
        
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.autoresizingMask = _arrowImage.autoresizingMask;
        _activityView.hidden = YES;
        [self addSubview:_activityView];
        
    
        [self addSubview:_statusLabel = [self labelWithFontSize:13]];
        
        [self loadAutoLayout];
        
        [RACObserve(self.arrowImage, hidden) subscribeNext:^(NSNumber* hidden) {
            if (hidden.boolValue) {
                self.activityView.hidden = NO;
                [self.activityView startAnimating];
            }else{
                self.activityView.hidden = YES;
                [self.activityView stopAnimating];
            }
        }];
        
        
        @weakify(self);
        [RACObserve(scrollView.infiniteScrollingView, state) subscribeNext:^(id x) {
            @strongify(self);
            [UIView animateWithDuration:0.25f animations:^{
                switch (scrollView.infiniteScrollingView.state) {
                    case SVInfiniteScrollingStateEnded:
                        self.arrowImage.hidden = YES;
                        self.activityView.hidden = YES;
                        self.statusLabel.text = @"没有了哦";
                        break;
                    case SVInfiniteScrollingStateStopped:
                        [self resetScrollViewContentInset:scrollView];
                        self.arrowImage.hidden = NO;
                        self.statusLabel.text = @"上拉加载";
                        self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
                        break;
                    case SVInfiniteScrollingStateTriggered:
                        self.arrowImage.hidden = NO;
                        self.statusLabel.text = @"释放加载";
                        self.arrowImage.transform = CGAffineTransformIdentity;
                        break;
                    case SVInfiniteScrollingStatePulling:
                        self.arrowImage.hidden = NO;
                        self.statusLabel.text = @"上拉加载";
                        self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
                        break;
                    case SVInfiniteScrollingStateLoading:
                        [self setScrollViewContentInsetForInfiniteScrolling:scrollView];
                        self.arrowImage.hidden = YES;
                        self.statusLabel.text = @"正在加载...";
                        
                        break;
                }
            }];
        }];
    }
    return self;
}

-(void)loadAutoLayout{
    [_arrowImage alignCenterYWithView:_arrowImage.superview predicate:@"0"];
    
    [_activityView alignToView:_arrowImage];
    
    [_statusLabel alignCenterWithView:_statusLabel.superview];
    [_statusLabel constrainLeadingSpaceToView:_arrowImage predicate:@"30"];
}

- (UILabel *)labelWithFontSize:(CGFloat)size
{
    UILabel *label = [[UILabel alloc] init];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont boldSystemFontOfSize:size];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}


@end
