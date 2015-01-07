//
//  GameLayer.m
//  Sigil North
//
//  Created by M F J C Clowes on 30/03/2014.
//  Copyright (c) 2014 M F J C Clowes. All rights reserved.
//

#import "GameLayer.h"
#import "GameConfig.h"
#import "SimpleAudioEngine.h"
#import "MainGameLayer.h"
#import "HUDLayer.h"
#import "Unit.h"
#import "Building.h"

#import "Building_Castle.h"

#import "CCPanZoomController.h"

extern int level;

@implementation GameLayer

@synthesize _mainGame, _theGame;
@synthesize tileDataArray, p1Units, p2Units, p1Buildings, p2Buildings, eBuildings;
@synthesize wins, mapWidth, mapHeight, mapScale, distance, lastGoodDistance;
@synthesize levelMap, selectedUnit, selectedBuilding, bgLayer, objectLayer;
@synthesize unitActionsMenu, buildingActionsMenu, contextMenuBack;
@synthesize _controller, xOffset, yOffset;

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	GameLayer *layer = [GameLayer node];
	[scene addChild: layer];
	return scene;
}

- (id)init {
    if ((self = [super init])) {
        wins = [[CCDirector sharedDirector] winSize];
        
        self.touchEnabled = YES;

        [self createLevelMap];
        
        // Load units
        p1Units = [[NSMutableArray alloc] initWithCapacity:10]; //what's this capacity thing?
        p2Units = [[NSMutableArray alloc] initWithCapacity:10];
        [self loadUnits:1];
        [self loadUnits:2];
        
        // Load buildings
        p1Buildings = [[NSMutableArray alloc] initWithCapacity:10];
        p2Buildings = [[NSMutableArray alloc] initWithCapacity:10];
        eBuildings = [[NSMutableArray alloc] initWithCapacity:10];
        [self loadBuildings:1];
        [self loadBuildings:2];
        [self loadBuildings:5];
        
        //Enable tile map scrolling
        // _controller is declared in the @interface as an object of CCPanZoomController
        CCPanZoomController *tempController = [[CCPanZoomController controllerWithNode:self] retain];
        tempController.boundingRect = CGRectMake(0,0,1000,1000);
        _controller = tempController;
        [_controller enableWithTouchPriority:3 swallowsTouches:YES];
    }
    return self;
}

-(void)dealloc{
    [tileDataArray release];
    [p1Units release];
    [p2Units release];
    [p1Buildings release];
    [p2Buildings release];
    [_controller disable];
    [_controller release];
    [super dealloc];
}

#pragma mark Build Level

-(void)createLevelMap {
    //Load the right the map
    if (level==1) {
        levelMap = [CCTMXTiledMap tiledMapWithTMXFile:@"StageMap1.tmx"];
    }
    else if (level==2){
        levelMap = [CCTMXTiledMap tiledMapWithTMXFile:@"StageMap2.tmx"];
    }
    else if (level==3){
        levelMap = [CCTMXTiledMap tiledMapWithTMXFile:@"StageMap3.tmx"];
    }
    else if (level==4){
        levelMap = [CCTMXTiledMap tiledMapWithTMXFile:@"StageMap4.tmx"];
    }
    
    [self addChild:levelMap];
    
    mapHeight = levelMap.contentSize.height;
    mapWidth = levelMap.contentSize.width;
    
    distance = 150;
    lastGoodDistance = 150;
    mapScale = 1;
    
    // Get the background layer
    bgLayer = [levelMap layerNamed:@"Background"];
    // Get information for each tile in background layer
    tileDataArray = [[NSMutableArray alloc] initWithCapacity:5];
    for(int i = 0; i< levelMap.mapSize.height;i++) {
        for(int j = 0; j< levelMap.mapSize.width;j++) {
            int movementCost = 1;
            int defensiveBonus = 1;
            NSString * tileType = nil;
            int tileGid=[bgLayer tileGIDAt:ccp(j,i)];
            if (tileGid) {
                NSDictionary *properties = [levelMap propertiesForGID:tileGid];
                if (properties) {
                    movementCost = [[properties valueForKey:@"MovementCost"] intValue];
                    defensiveBonus = [[properties valueForKey:@"defensiveBonus"] intValue];
                    tileType = [properties valueForKey:@"TileType"];
                }
            }
            TileData * tData = [TileData nodeWithTheGame:_theGame movementCost:movementCost defensiveBonus:defensiveBonus position:ccp(j,i) tileType:tileType];
            [tileDataArray addObject:tData];
        }
    }
}

#pragma mark Handle tiles
// Get the scale for a sprite - 1 for normal display, 2 for retina
-(int)spriteScale {
    if (IS_HD)
        return 2;
    else
        return 1;
}

// Get the height for a tile based on the display type (retina or SD)
-(int)getTileHeightForRetina {
    if (IS_HD)
        return TILE_HEIGHT_HD;
    else
        return TILE_HEIGHT;
}

// Return tile coordinates (in rows and columns) for a given position
-(CGPoint)tileCoordForPosition:(CGPoint)position {
    CGSize tileSize = CGSizeMake(levelMap.tileSize.width,levelMap.tileSize.height);
    if (IS_HD) {
        tileSize = CGSizeMake(levelMap.tileSize.width/2,levelMap.tileSize.height/2);
    }
    int x = position.x / tileSize.width;
    int y = ((levelMap.mapSize.height * tileSize.height) - position.y) / tileSize.height;
    return ccp(x, y);
}

// Return the position for a tile based on its row and column
-(CGPoint)positionForTileCoord:(CGPoint)position {
    CGSize tileSize = CGSizeMake(levelMap.tileSize.width,levelMap.tileSize.height);
    if (IS_HD) {
        tileSize = CGSizeMake(levelMap.tileSize.width/2,levelMap.tileSize.height/2);
    }
    int x = position.x * tileSize.width + tileSize.width/2;
    int y = (levelMap.mapSize.height - position.y) * tileSize.height - tileSize.height/2;
    return ccp(x, y);
}

// Get the surrounding tiles (above, below, to the left, and right) of a given tile based on its row and column
-(NSMutableArray *)getTilesNextToTile:(CGPoint)tileCoord {
    NSMutableArray * tiles = [NSMutableArray arrayWithCapacity:4];
    if (tileCoord.y+1<levelMap.mapSize.height)
        [tiles addObject:[NSValue valueWithCGPoint:ccp(tileCoord.x,tileCoord.y+1)]];
    if (tileCoord.x+1<levelMap.mapSize.width)
        [tiles addObject:[NSValue valueWithCGPoint:ccp(tileCoord.x+1,tileCoord.y)]];
    if (tileCoord.y-1>=0)
        [tiles addObject:[NSValue valueWithCGPoint:ccp(tileCoord.x,tileCoord.y-1)]];
    if (tileCoord.x-1>=0)
        [tiles addObject:[NSValue valueWithCGPoint:ccp(tileCoord.x-1,tileCoord.y)]];
    return tiles;
}

// Get the TileData for a tile at a given position
-(TileData *)getTileData:(CGPoint)tileCoord {
    for (TileData * td in tileDataArray) {
        if (CGPointEqualToPoint(td.position, tileCoord)) {
            return td;
        }
    }
    return nil;
}

#pragma mark Handing Touches

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"Got here at least1");
    for (UITouch *touch in touches) {
        NSLog(@"Got here at least");
		// Get the location of the touch
		CGPoint location = [touch locationInView: [touch view]];
        
        NSLog(@"%d, %d", xOffset, yOffset);
        NSLog(@"%f, %f", location.x, location.y);
        
        //adjust for scrolling offset
        location.x = location.x - (xOffset);
        location.y = location.y + (yOffset);
        
        NSLog(@"%f, %f", location.x, location.y);
        
		// Convert the touch location to OpenGL coordinates
		location = [[CCDirector sharedDirector] convertToGL: location];
		// Get the tile data for the tile at touched position
		TileData * td = [self getTileData:[self tileCoordForPosition:location]];
		
        //if concerning units - if buildings, different ...?
        
        if(td.selectedForJoin) { //Join a tile if selected for joining
            // Attack the specified tile
            [selectedUnit doMarkedJoin:td];
            // Deselect the unit
            [self unselectUnit];
        } else if ((td.selectedForMovement && ![self otherUnitInTile:td]) || ([self otherUnitInTile:td] == selectedUnit)) {
            // Move to the tile if we can move there, if it was selected for movement
            if (!unitActionsMenu ){
                [selectedUnit doMarkedMovement:td];
            }
        } else if(td.selectedForAttack) { //Attack a tile if selected for attack
            // Attack the specified tile
            [selectedUnit doMarkedAttack:td];
            // Deselect the unit
            [self unselectUnit];
        } else {
            //THIS NEEDS TO CHANGE DRAMATICALLY!!!
            // Tapped a non-marked tile. What do we do?
            if (selectedUnit.selectingAttack) {
                // Was in the process of attacking - cancel attack and show menu
                selectedUnit.selectingAttack = NO;
                [self unPaintAttackTiles];
                [self showUnitActionsMenu:selectedUnit canAttack:YES canJoin:YES canCapture:YES];
            } else if (selectedUnit.selectingJoin) {
                // Was in the process of joining - cancel joinand show menu
                selectedUnit.selectingJoin = NO;
                [self unPaintJoinTiles];
                [self showUnitActionsMenu:selectedUnit canAttack:YES canJoin:YES canCapture:YES];
            } else if (selectedUnit.selectingMovement) {
                // Was in the process of moving - just remove marked tiles and await further action
                selectedUnit.selectingMovement = NO;
                [selectedUnit unMarkPossibleMovement];
                [self unselectUnit];
            }
        }
	}
}


#pragma mark Handling units

-(void)loadUnits:(int)player {
    // 1 - Retrieve the layer based on the player number
    CCTMXObjectGroup * unitsObjectGroup = [levelMap objectGroupNamed:[NSString stringWithFormat:@"Units_P%d",player]];
    // 2 - Set the player array
    NSMutableArray * units = nil;
    if (player ==1)
        units = p1Units;
    if (player ==2)
        units = p2Units;
    // 3 - Load units into player array based on the objects on the layer
    for (NSMutableDictionary * unitDict in [unitsObjectGroup objects]) {
        NSMutableDictionary * d = [NSMutableDictionary dictionaryWithDictionary:unitDict];
        NSString * unitType = [d objectForKey:@"Type"];
        NSString *classNameStr = [NSString stringWithFormat:@"Unit_%@",unitType];
        Class theClass = NSClassFromString(classNameStr);
        Unit * unit = [theClass nodeWithTheGame:self tileDict:d owner:player];
        [units addObject:unit];
    }
}

// Check specified tile to see if there's any other unit (from either player) in it already
-(Unit *)otherUnitInTile:(TileData *)tile {
    for (Unit *u in p1Units) {
        if (CGPointEqualToPoint([self tileCoordForPosition:u.mySprite.position], tile.position))
            return u;
    }
    for (Unit *u in p2Units) {
        if (CGPointEqualToPoint([self tileCoordForPosition:u.mySprite.position], tile.position))
            return u;
    }
    return nil;
}

// Check specified tile to see if there's an enemy unit in it already
-(Unit *)otherEnemyUnitInTile:(TileData *)tile unitOwner:(int)owner {
    if (owner == 1) {
        for (Unit *u in p2Units) {
            if (CGPointEqualToPoint([self tileCoordForPosition:u.mySprite.position], tile.position)){
                return u;
            }
        }
    } else if (owner == 2) {
        for (Unit *u in p1Units) {
            if (CGPointEqualToPoint([self tileCoordForPosition:u.mySprite.position], tile.position)){
                return u;
            }
        }
    }
    return nil;
}

// Check specified tile to see if there's an enemy unit in it already
-(Unit *)otherJoinableUnitInTile:(TileData *)tile unitOwner:(int)owner unitType:(Unit*) unit {
    if (owner == 1) {
        for (Unit *u in p1Units) {
            if (CGPointEqualToPoint([self tileCoordForPosition:u.mySprite.position], tile.position)){
                if (unit.class==u.class && unit!=u && u.getHP!=100) {
                    return u;
                }
            }
        }
    } else if (owner == 2) {
        for (Unit *u in p2Units) {
            if (CGPointEqualToPoint([self tileCoordForPosition:u.mySprite.position], tile.position)){
                if (unit.class==u.class && unit!=u && u.getHP!=100) {
                    return u;
                }
            }
        }
    }
    return nil;
}

// Mark the specified tile for movement, if it hasn't been marked already
-(BOOL)paintMovementTile:(TileData *)tData {
    CCSprite *tile = [bgLayer tileAt:tData.position];
    if (!tData.selectedForMovement) {
        [tile setColor:ccBLUE];
        tData.selectedForMovement = YES;
        return NO;
    }
    return YES;
}

// Set the color of a tile back to the default color
-(void)unPaintMovementTile:(TileData *)tileData {
    CCSprite * tile = [bgLayer tileAt:tileData.position];
    [tile setColor:ccWHITE];
}

// Select specified unit
-(void)selectUnit:(Unit *)unit {
    selectedUnit = nil;
    selectedUnit = unit;
}

// Deselect the currently selected unit
-(void)unselectUnit {
    if (selectedUnit) {
        [selectedUnit unselectUnit];
    }
    selectedUnit = nil;
}

-(Unit *)unitInTile:(TileData *)tile {
    // Check player 1's buildings
    for (Unit *u in p1Units) {
        if (CGPointEqualToPoint([self tileCoordForPosition:u.mySprite.position], tile.position))
            return u;
    }
    // Check player 2's buildings
    for (Unit *u in p2Units) {
        if (CGPointEqualToPoint([self tileCoordForPosition:u.mySprite.position], tile.position))
            return u;
    }
    return nil;
}

-(void)showUnitActionsMenu:(Unit *)unit canAttack:(BOOL)canAttack canJoin:(BOOL)canJoin canCapture:(BOOL)canCapture {
    // 1 - Get the window size
    wins = [[CCDirector sharedDirector] winSize];
    // 2 - Create the menu background
    contextMenuBack = [CCSprite spriteWithFile:@"popup_bg.png"];
    contextMenuBack.scaleX=1.3;
    contextMenuBack.scaleY=1;
    [_mainGame._hud addChild:contextMenuBack z:19];
    // 3 - Create the menu option labels
    
    //ADD IN A JOIN OTHER UNIT OPTION
    
    CCLabelBMFont * stayLbl = [CCLabelBMFont labelWithString:@"Rest" fntFile:@"Font_dark_size15.fnt"];
    CCMenuItemLabel * stayBtn = [CCMenuItemLabel itemWithLabel:stayLbl target:unit selector:@selector(doStay)];
    CCLabelBMFont * captureLbl = [CCLabelBMFont labelWithString:@"Capture" fntFile:@"Font_dark_size15.fnt"];
    CCMenuItemLabel * captureBtn = [CCMenuItemLabel itemWithLabel:captureLbl target:unit selector:@selector(doCapture)];
    CCLabelBMFont * attackLbl = [CCLabelBMFont labelWithString:@"Attack" fntFile:@"Font_dark_size15.fnt"];
    CCMenuItemLabel * attackBtn = [CCMenuItemLabel itemWithLabel:attackLbl target:unit selector:@selector(doAttack)];
    CCLabelBMFont * joinLbl = [CCLabelBMFont labelWithString:@"Join" fntFile:@"Font_dark_size15.fnt"];
    CCMenuItemLabel * joinBtn = [CCMenuItemLabel itemWithLabel:joinLbl target:unit selector:@selector(doJoin)];
    CCLabelBMFont * cancelLbl = [CCLabelBMFont labelWithString:@"Cancel" fntFile:@"Font_dark_size15.fnt"];
    CCMenuItemLabel * cancelBtn = [CCMenuItemLabel itemWithLabel:cancelLbl target:unit selector:@selector(doCancel)];
    
    unitActionsMenu = [CCMenu menuWithItems:nil];
    [unitActionsMenu addChild:stayBtn];
    // Add the buttons if they're valid
    if (canCapture) {
        [unitActionsMenu addChild:captureBtn];
        contextMenuBack.scaleY+=0.3;
    }
    if (canAttack) {
        [unitActionsMenu addChild:attackBtn];
        contextMenuBack.scaleY+=0.3;
    }
    if (canJoin) {
        [unitActionsMenu addChild:joinBtn];
        contextMenuBack.scaleY+=0.3;
    }
    [unitActionsMenu addChild:cancelBtn];
    
    [_mainGame._hud addChild:unitActionsMenu z:19];
    [unitActionsMenu alignItemsVerticallyWithPadding:5];
    
    if (unit.mySprite.position.x > wins.width/2) {
        [contextMenuBack setPosition:ccp(100,wins.height/2)];
        [unitActionsMenu setPosition:ccp(100,wins.height/2)];
    } else {
        [contextMenuBack setPosition:ccp(wins.width-100,wins.height/2)];
        [unitActionsMenu setPosition:ccp(wins.width-100,wins.height/2)];
    }
}

-(void)removeUnitActionsMenu {
    // Remove the menu from the layer and clean up
    [contextMenuBack.parent removeChild:contextMenuBack cleanup:YES];
    contextMenuBack = nil;
    [unitActionsMenu.parent removeChild:unitActionsMenu cleanup:YES];
    unitActionsMenu = nil;
}

#pragma mark Handling Healing
-(void)doHealing {
    if (_mainGame.playerTurn ==1) {
        for (Unit *u in p1Units) {
            Building *buildingBelow = [self buildingInTile:[self getTileData:[self tileCoordForPosition:u.mySprite.position]]];
            if (buildingBelow.owner == u.owner && buildingBelow.getCanHeal==true){
                [u doHealing1];
            }
            if (u.isHealer==true) {
                //for all units adjacent too - up to 4
                [u doHealing2];
                //Static reference to tile size!!
                Unit *adjUp = [self unitInTile:[self getTileData:[self tileCoordForPosition:ccp(u.mySprite.position.x,u.mySprite.position.y+32)]]];
                Unit *adjDown = [self unitInTile:[self getTileData:[self tileCoordForPosition:ccp(u.mySprite.position.x,u.mySprite.position.y-32)]]];
                Unit *adjLeft = [self unitInTile:[self getTileData:[self tileCoordForPosition:ccp(u.mySprite.position.x-32,u.mySprite.position.y)]]];
                Unit *adjRight = [self unitInTile:[self getTileData:[self tileCoordForPosition:ccp(u.mySprite.position.x+32,u.mySprite.position.y)]]];
                [adjUp doHealing2];
                [adjDown doHealing2];
                [adjLeft doHealing2];
                [adjRight doHealing2];
            }
        }
    }
    else if (_mainGame.playerTurn==2) {
        for (Unit *u in p2Units) {
            Building *buildingBelow = [self buildingInTile:[self getTileData:[self tileCoordForPosition:u.mySprite.position]]];
            if (buildingBelow.owner == u.owner && buildingBelow.getCanHeal==true){
                [u doHealing1];
            }
            if (u.isHealer==true) {
                //for all units adjacent too
                [u doHealing2];
                Unit *adjUp = [self unitInTile:[self getTileData:[self tileCoordForPosition:ccp(u.mySprite.position.x,u.mySprite.position.y+32)]]];
                Unit *adjDown = [self unitInTile:[self getTileData:[self tileCoordForPosition:ccp(u.mySprite.position.x,u.mySprite.position.y-32)]]];
                Unit *adjLeft = [self unitInTile:[self getTileData:[self tileCoordForPosition:ccp(u.mySprite.position.x-32,u.mySprite.position.y)]]];
                Unit *adjRight = [self unitInTile:[self getTileData:[self tileCoordForPosition:ccp(u.mySprite.position.x+32,u.mySprite.position.y)]]];
                [adjUp doHealing2];
                [adjDown doHealing2];
                [adjLeft doHealing2];
                [adjRight doHealing2];
            }
            
        }
    }
}

#pragma mark Handling Buildings
// Load buildings for layer
-(void)loadBuildings:(int)player {
    // Get building object group from tilemap
    CCTMXObjectGroup *buildingsObjectGroup = [levelMap objectGroupNamed:[NSString stringWithFormat:@"Buildings_P%d",player]];
    // Get the correct building array based on the current player
    NSMutableArray *buildings = nil;
    if (player == 1) {
        buildings = p1Buildings;
    } else if (player == 2) {
        buildings = p2Buildings;
    } else if (player == 5){
        buildings = eBuildings;
    }
    // Iterate over the buildings in the array, adding them to the game
    for (NSMutableDictionary *buildingDict in [buildingsObjectGroup objects]) {
        // Get the building type
        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:buildingDict];
        NSString *buildingType = [d objectForKey:@"Type"];
        // Get the right building class based on type
        NSString *classNameStr = [NSString stringWithFormat:@"Building_%@",buildingType];
        Class theClass = NSClassFromString(classNameStr);
        // Create the building
        Building *building = [theClass nodeWithTheGame:self tileDict:d owner:player];
        [buildings addObject:building];
    }
}

// Return the first matching building (if any) on the given tile
-(Building *)buildingInTile:(TileData *)tile {
    // Check player 1's buildings
    for (Building *b in p1Buildings) {
        if (CGPointEqualToPoint([self tileCoordForPosition:b.mySprite.position], tile.position))
            return b;
    }
    // Check player 2's buildings
    for (Building *b in p2Buildings) {
        if (CGPointEqualToPoint([self tileCoordForPosition:b.mySprite.position], tile.position))
            return b;
    }
    //Check environment buildings
    for (Building *b in eBuildings) {
        if (CGPointEqualToPoint([self tileCoordForPosition:b.mySprite.position], tile.position))
            return b;
    }
    return nil;
}

// Select specified building
-(void)selectBuilding:(Building *)building {
    selectedBuilding = nil;
    selectedBuilding = building;
}

// Deselect the currently selected unit
-(void)unselectBuilding {
    if (selectedBuilding) {
        [selectedBuilding unselectBuilding];
    }
    selectedBuilding = nil;
}

-(void)showBuildingActionsMenu:(Building *)building canHireUnit:(BOOL)canHireUnit {
    if (canHireUnit) {
        // Get the window size
        wins = [[CCDirector sharedDirector] winSize];
        // Create the menu background
        contextMenuBack = [CCSprite spriteWithFile:@"popup_bg.png"];
        [_mainGame._hud addChild:contextMenuBack z:19];
        
        contextMenuBack.scaleX=1.5;
        contextMenuBack.scaleY=2;
        // Create the menu option labels
        CCLabelBMFont * footmanLbl = [CCLabelBMFont labelWithString:@"Footman" fntFile:@"Font_dark_size15.fnt"];
        CCMenuItemLabel * footmanBtn = [CCMenuItemLabel itemWithLabel:footmanLbl target:building selector:@selector(hireFootman)];
        CCLabelBMFont * centurionLbl = [CCLabelBMFont labelWithString:@"Centurion" fntFile:@"Font_dark_size15.fnt"];
        CCMenuItemLabel * centurionBtn = [CCMenuItemLabel itemWithLabel:centurionLbl target:building selector:@selector(hireCenturion)];
        CCLabelBMFont * rangerLbl = [CCLabelBMFont labelWithString:@"Ranger" fntFile:@"Font_dark_size15.fnt"];
        CCMenuItemLabel * rangerBtn = [CCMenuItemLabel itemWithLabel:rangerLbl target:building selector:@selector(hireRanger)];
        CCLabelBMFont * mageLbl = [CCLabelBMFont labelWithString:@"Battle Mage" fntFile:@"Font_dark_size15.fnt"];
        CCMenuItemLabel * mageBtn = [CCMenuItemLabel itemWithLabel:mageLbl target:building selector:@selector(hireBattleMage)];
        CCLabelBMFont * priestLbl = [CCLabelBMFont labelWithString:@"Priest" fntFile:@"Font_dark_size15.fnt"];
        CCMenuItemLabel * priestBtn = [CCMenuItemLabel itemWithLabel:priestLbl target:building selector:@selector(hirePriest)];
        CCLabelBMFont * cancelLbl = [CCLabelBMFont labelWithString:@"Cancel" fntFile:@"Font_dark_size15.fnt"];
        CCMenuItemLabel * cancelBtn = [CCMenuItemLabel itemWithLabel:cancelLbl target:building selector:@selector(doCancel)];
        // Create the menu
        buildingActionsMenu = [CCMenu menuWithItems:nil];
        // Add buttons
        [buildingActionsMenu addChild:footmanBtn];
        [buildingActionsMenu addChild:centurionBtn];
        [buildingActionsMenu addChild:rangerBtn];
        [buildingActionsMenu addChild:mageBtn];
        [buildingActionsMenu addChild:priestBtn];
        // Add the Cancel button
        [buildingActionsMenu addChild:cancelBtn];
        // Add the menu to the layer
        [_mainGame._hud addChild:buildingActionsMenu z:19];
        
        // Position menu
        [buildingActionsMenu alignItemsVerticallyWithPadding:5];
        if (building.mySprite.position.x > wins.width/2) {
            [contextMenuBack setPosition:ccp(100,wins.height/2)];
            [buildingActionsMenu setPosition:ccp(100,wins.height/2)];
        } else {
            [contextMenuBack setPosition:ccp(wins.width-100,wins.height/2)];
            [buildingActionsMenu setPosition:ccp(wins.width-100,wins.height/2)];
        }
    }
}

-(void)removeBuildingActionsMenu {
    // Remove the menu from the layer and clean up
    [contextMenuBack.parent removeChild:contextMenuBack cleanup:YES];
    contextMenuBack = nil;
    [buildingActionsMenu.parent removeChild:buildingActionsMenu cleanup:YES];
    buildingActionsMenu = nil;
}

#pragma mark uiMenu Handling

// End the turn, passing control to the other player
-(void)doEndTurn {
    // Do not do anything if a unit is selected
    [[SimpleAudioEngine sharedEngine] playEffect:@"btn.wav"];
    
    [self doHealing];
    
    //need this?
    if (selectedUnit)
        return;
    
    // Switch players depending on who's currently selected
    if (_mainGame.playerTurn ==1) {
        _mainGame.playerTurn = 2;
    } else if (_mainGame.playerTurn ==2) {
        _mainGame.playerTurn = 1;
    }
    // Do a transition to signify the end of turn
    [self showEndTurnTransition];
    // Set the turn label to display the current turn
    [_mainGame._hud setPlayerTurnLabel];
}

// Fancy transition to show turn switch/end
-(void)showEndTurnTransition {
    // Create a black layer
    ccColor4B c = {0,0,0,0};
    CCLayerColor *layer = [CCLayerColor layerWithColor:c];
    [_mainGame._hud addChild:layer z:20];
    // Add a label showing the player turn to the black layer
    CCLabelBMFont * turnLbl = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Player %d's turn",_mainGame.playerTurn] fntFile:@"Font_silver_size17.fnt"];
    [layer addChild:turnLbl];
    [turnLbl setPosition:ccp([CCDirector sharedDirector].winSize.width/2,[CCDirector sharedDirector].winSize.height/2)];
    // Run an action which fades in the black layer, calls the beginTurn method, fades out the black layer, and finally removes it
    [layer runAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.5 opacity:150],[CCCallFunc actionWithTarget:self selector:@selector(beginTurn)],[CCFadeTo actionWithDuration:0.5 opacity:0],[CCCallFuncN actionWithTarget:self selector:@selector(removeLayer:)], nil]];
}

#pragma mark Options Menu Handling
-(void) doLevelSelect {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:2 scene: [MainMenuLayer scene]]];
}

-(void) doRestartLevel {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:2 scene: [MainMenuLayer scene]]];
}

#pragma mark Load for Turn
// Begin the next turn
-(void)beginTurn {
    // Activate the units for the active player
    if (_mainGame.playerTurn ==1) {
        [self activateUnits:p2Units];
        [self activateBuildings:p2Buildings];
    } else if (_mainGame.playerTurn ==2) {
        [self activateUnits:p1Units];
        [self activateBuildings:p1Buildings];
    }
    [_mainGame musicHandler];
    
    [self doGenerateMoney];
}

//Add money based on buildings owned by each player
//Replace this with a moneyValue variable in building classes
-(void)doGenerateMoney {
    if (_mainGame.playerTurn ==1) {
        for (Building *b in p1Buildings) {
            if (b.canGenerateMoney == true){
                if (b.class==Building_Castle.class) {
                    _mainGame.player1Gold+=400;
                } else {
                _mainGame.player1Gold+=100;
                }
            }
        }
        [self updateMoneyLabel];
    }
    else if (_mainGame.playerTurn==2) {
        for (Building *b in p2Buildings) {
            if (b.canGenerateMoney == true){
                if (b.class==Building_Castle.class) {
                    _mainGame.player2Gold+=400;
                } else {
                    _mainGame.player2Gold+=100;
                }
            }
        }
        [self updateMoneyLabel];
    }
}

// Update the HP value display
-(void)updateMoneyLabel {
    if (_mainGame.playerTurn ==1) {
        [_mainGame._hud.moneyLabel setString:[NSString stringWithFormat:@"%d",_mainGame.player1Gold]];
    } else if (_mainGame.playerTurn == 2) {
        [_mainGame._hud.moneyLabel setString:[NSString stringWithFormat:@"%d",_mainGame.player2Gold]];
    }
}

// Remove the black layer added for the turn change transition
-(void)removeLayer:(CCNode *)n {
    [n.parent removeChild:n cleanup:YES];
}

// Activate all the units in the specified array (called from beginTurn passing the units for the active player)
-(void)activateUnits:(NSMutableArray *)units {
    for (Unit *unit in units) {
        [unit startTurn];
    }
}

// Activate all the buildings
-(void)activateBuildings:(NSMutableArray *)buildings {
    for (Building *building in buildings) {
        [building startTurn];
    }
}

#pragma mark Handle attacking

// Check the specified tile to see if it can be attacked
-(BOOL)checkAttackTile:(TileData *)tData unitOwner:(int)owner {
    // Is this tile already marked for attack, if so, we don't need to do anything further
    // If not, does the tile contain an enemy unit? If yes, we can attack this tile
    if (!tData.selectedForAttack && [self otherEnemyUnitInTile:tData unitOwner:owner]!= nil) {
        tData.selectedForAttack = YES;
        return NO;
    }
    return YES;
}

// Paint the given tile as one that can be attacked
-(BOOL)paintAttackTile:(TileData *)tData {
    CCSprite * tile = [bgLayer tileAt:tData.position];
    [tile setColor:ccRED];
    return YES;
}

// Remove the attack marking from all tiles
-(void)unPaintAttackTiles {
    for (TileData * td in tileDataArray) {
        [self unPaintAttackTile:td];
    }
}

// Remove the attack marking from a specific tile
-(void)unPaintAttackTile:(TileData *)tileData {
    CCSprite * tile = [bgLayer tileAt:tileData.position];
    [tile setColor:ccWHITE];
}

// Calculate the damage inflicted when one unit attacks another based on the unit type
-(double)calculateDamageFrom:(Unit *)attacker onDefender:(Unit *)defender {
    double dmg = attacker.unitAtk;
    double def = defender.unitDef;
    /*
     for unit specific modifiers:
     if defender is type a and attacker is type b{
     return x+ modifier;
     }
     */
    //need to add terrain modifier - ((100-defender.unitDef-tile.defenseBonus)/100))
    Building *buildingBelow = [self buildingInTile:[self getTileData:[self tileCoordForPosition:defender.mySprite.position]]];
    def += buildingBelow.buildingDefBonus;
    def += [self getTileData:[self tileCoordForPosition:defender.mySprite.position]].defensiveBonus;
    
    dmg =(dmg/10)*(100-(100-attacker.getHP)*0.9);
    def =(100-def)/10;
    //NSLog(@"> Base Atk: %i Def: %i \n Mod Atk: %f Mod Def: %f\n  Final damage: %f", attacker.unitAtk, defender.unitDef, dmg, def, ((dmg*def)/100));
    return (dmg*def)/10;
}

#pragma mark Handle joining

// Check the specified tile to see if it can be attacked
-(BOOL)checkJoinTile:(TileData *)tData unitOwner:(int)owner joinerType:(Unit *)joiner{
    // Is this tile already marked for joining, if so, we don't need to do anything further
    // If not, does the tile contain an enemy unit? If yes, we can attack this tile
    if (!tData.selectedForJoin && [self otherJoinableUnitInTile:tData unitOwner:owner unitType:joiner]!= nil) {
        tData.selectedForJoin = YES;
        return NO;
    }
    return YES;
}

// Paint the given tile as one that can be attacked
-(BOOL)paintJoinTile:(TileData *)tData {
    CCSprite * tile = [bgLayer tileAt:tData.position];
    [tile setColor:ccRED];
    return YES;
}

// Remove the attack marking from all tiles
-(void)unPaintJoinTiles {
    for (TileData * td in tileDataArray) {
        [self unPaintAttackTile:td];
    }
}

// Remove the attack marking from a specific tile
-(void)unPaintJoinTile:(TileData *)tileData {
    CCSprite * tile = [bgLayer tileAt:tileData.position];
    [tile setColor:ccWHITE];
}

#pragma mark Win conditions
// Check if each player has run out of units
-(void)checkForMoreUnits {
    if ([p1Units count]== 0) {
        [self showEndGameMessageWithWinner:2];
    } else if([p2Units count]== 0) {
        [self showEndGameMessageWithWinner:1];
    }
}

// Show winning message for specified player
-(void)showEndGameMessageWithWinner:(int)winningPlayer {
    // Create black layer
    ccColor4B c = {0,0,0,0};
    CCLayerColor * layer = [CCLayerColor layerWithColor:c];
    [self addChild:layer z:20];
    // Add background image to new layer
    CCSprite * bck = [CCSprite spriteWithFile:@"victory_bck.png"];
    [layer addChild:bck];
    [bck setPosition:ccp([CCDirector sharedDirector].winSize.width/2,[CCDirector sharedDirector].winSize.height/2)];
    // Create winning message
    CCLabelBMFont * turnLbl = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Player %d wins!",winningPlayer]  fntFile:@"Font_dark_size15.fnt"];
    [layer addChild:turnLbl];
    [turnLbl setPosition:ccp([CCDirector sharedDirector].winSize.width/2,[CCDirector sharedDirector].winSize.height/2-30)];
    // Fade in new layer, show it for 2 seconds, call method to remove layer, and finally, restart game
    [layer runAction:[CCSequence actions:[CCFadeTo actionWithDuration:1 opacity:150],[CCDelayTime actionWithDuration:2],[CCCallFuncN actionWithTarget:self selector:@selector(removeLayer:)],[CCCallFunc actionWithTarget:self selector:@selector(restartGame)], nil]];
}

// Restart game
-(void)restartGame {
    //change transition
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:2 scene:[MainMenuLayer scene]]];
}

#pragma mark Map scrolling
-(CCPanZoomController *)getController {
    return _controller;
}

-(void) setXOffset:(int)xAxisOffset setYOffset:(int)yAxisOffset{
    self.xOffset = xAxisOffset;
    self.yOffset = yAxisOffset;
}

@end
