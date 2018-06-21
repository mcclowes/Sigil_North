//
//  Game Screen.h
//  Sigil North
//
//  Created by M F J C Clowes on 20/01/2014.
//  Copyright M F J C Clowes 2014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TileData.h"

@class HUDLayer;
@class GameLayer;

@interface MainGameLayer : CCLayer {
    //Game layers
    MainGameLayer *_mainGame;
    HUDLayer * _hud;
    GameLayer *_theGame;
    
    //Game state variables
    BOOL gameWin;
    int playerTurn;
    int player1Gold;
    int player2Gold;
}
#pragma mark Variables:
//Game layers
@property (nonatomic, retain) MainGameLayer *_mainGame;
@property (nonatomic, retain) HUDLayer * _hud;
@property (nonatomic, retain) GameLayer *_theGame;

//Game state variables
@property (nonatomic, readwrite) BOOL gameWin;
@property (nonatomic, readwrite) int playerTurn;
@property (nonatomic, readwrite) int player1Gold;
@property (nonatomic, readwrite) int player2Gold;

#pragma mark Methods:

+(CCScene *) scene;
- (id)initWithGame:(GameLayer *)theGame initWithHUD:(HUDLayer *)hud;

#pragma mark Music Maintainance
-(void)musicHandler;

@end
