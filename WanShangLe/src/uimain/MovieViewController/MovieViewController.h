//
//  MovieViewController.h
//  WanShangLe
//
//  Created by stephenliu on 13-6-5.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CinemaViewController;
@class ApiCmdMovie_getAllMovies;
@class ApiCmdMovie_getAllCinemas;

@interface MovieViewController : UIViewController{
    
}
@property(nonatomic,readwrite,assign)BOOL isMoviePanel;
@property(nonatomic,retain)CinemaViewController *cinemaViewController;
@property(nonatomic,retain)UITableView *movieTableView;
@property(nonatomic,retain)NSArray *moviesArray;
@property(nonatomic,retain)ApiCmdMovie_getAllMovies *apiCmdMovie_getAllMovies;
@property(nonatomic,retain)ApiCmdMovie_getAllCinemas *apiCmdMovie_getAllCinemas;

- (void)switchMovieCinemaAnimation;
- (void)pushMovieCinemaAnimation;
- (void)clickCinemaButtonUp:(id)sender;
- (void)clickCinemaButtonDown:(id)sender;
- (void)clickMovieButtonUp:(id)sender;
- (void)clickMovieButtonDown:(id)sender;
@end
