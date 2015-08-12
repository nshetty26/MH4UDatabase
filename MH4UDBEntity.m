//
//  MH4UDBEntity.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/10/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "MH4UDBEntity.h"

@implementation Armor

@end

@implementation Item

@end

@implementation Combining

@end

@implementation Quest

@end

@implementation Monster

@end

@implementation MonsterDamage

@end

@implementation MonsterStatusEffect

@end

@implementation MonsterHabitat

@end

@implementation SkillTreeCollection

@end

@implementation Decoration

@end

@implementation Location

@end


@implementation Weapon

-(NSString *)getElementalDescription {
    NSString *elementString;
    if (self.awakenDamage > 0) {
        elementString = [NSString stringWithFormat:@"%@: %i", self.awaken_type, self.awakenDamage];
    } else if (self.elementalDamage_2 > 0) {
        elementString = [NSString stringWithFormat:@"%@\\%@: %i\\%i", self.elementalDamageType_1, self.elementalDamageType_2, self.elementalDamage_1,  self.elementalDamage_2];
    } else if (self.elementalDamage_1 > 0) {
        elementString = [NSString stringWithFormat:@"%@: %i", self.elementalDamageType_1, self.elementalDamage_1];
    } else {
        elementString = @"None";
    }
    
    return elementString;
}



-(NSAttributedString *)returnAttributedAmmoStringFromAmmoString:(NSString *)bowGunAmmoString {
    NSArray *ammoArray = [bowGunAmmoString componentsSeparatedByString:@"|"];
    NSMutableAttributedString *ammoString = [[NSMutableAttributedString alloc] initWithString:@""];
    for (int i = 0; i < ammoArray.count; ++i) {
        NSMutableAttributedString *ammo = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", ammoArray[i]]];
        
        if (!([ammoArray[i] rangeOfString:@"*"].location == NSNotFound)) {
            [ammo addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(0, ammo.length)];
        }
        
        if (i % 3 == 0 && i != 0) {
            [ammo insertAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"] atIndex:0];
            [ammoString appendAttributedString:ammo];
        } else {
            
            [ammoString appendAttributedString:ammo];
        }
        
    }

    return ammoString;
}

-(void)drawBowCoatings:(NSString *)coatingString inView:(UIView *)coatingView {
    //ammoString = @"Power|Poison|Para|Sleep|-|Paint|-|-@";
    NSArray *coatingSplit = [coatingString componentsSeparatedByString:@"|"];
    NSArray *coatingArray = [coatingSplit filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *coatingString, NSDictionary *userInfo){
        if ([coatingString isEqualToString:@"-"]) {
            return false;
        } else {
            return true;
        }
    }]];
    float width = coatingView.frame.size.width / coatingArray.count;
    
    for (int i = 0; i < coatingArray.count; i++) {
        NSString *coating = coatingArray[i];
        UIImage *coatingImage = [self returnImageForCoating:coating];
        UIImageView *coatingImageView = [[UIImageView alloc] initWithImage:coatingImage];
        coatingImageView.frame = CGRectMake(i * width, 0, 30, 30);
        [coatingView addSubview:coatingImageView];
    }
}

-(UIImage *)returnImageForCoating:(NSString *)coating {
    if ([coating isEqualToString:@"Power"]) {
        return [UIImage imageNamed:@"Bottle-Red.png"];
    }
    
    else if ([coating isEqualToString:@"Para"]) {
        return [UIImage imageNamed:@"Bottle-Yellow.png"];
    }
    
    else if ([coating isEqualToString:@"C. Range"]) {
        return [UIImage imageNamed:@"Bottle-White.png"];
    }
    
    else if ([coating isEqualToString:@"Exhaust"]) {
        return [UIImage imageNamed:@"Bottle-Blue.png"];
    }
    
    else if ([coating isEqualToString:@"Paint"]) {
        return [UIImage imageNamed:@"Bottle-Pink.png"];
    }
    
    else if ([coating isEqualToString:@"Poison"]) {
        return [UIImage imageNamed:@"Bottle-Purple.png"];
    }
    
    else if ([coating isEqualToString:@"Sleep"]) {
        return [UIImage imageNamed:@"Bottle-Cyan.png"];
    }
    
    else if ([coating isEqualToString:@"Blast"]) {
        return [UIImage imageNamed:@"Bottle-Orange.png"];
    }
    return nil;
}

-(void)drawSharpness:(NSString *)sharpnessString inView:(UIView *)sharpnessView {
    double frameWidth = 0;
    [sharpnessView setBackgroundColor:[UIColor clearColor]];
    NSArray *sharpness = [sharpnessString componentsSeparatedByString:@"."];
    
    float mRed1 = (float)[sharpness[0] floatValue];
    float mOrange1 = (float)[sharpness[1] floatValue];
    float mYellow1 = (float)[sharpness[2] floatValue];
    float mGreen1 = (float)[sharpness[3] floatValue];
    float mBlue1 = (float)[sharpness[4] floatValue];
    float mWhite1 = (float)[sharpness[5] floatValue];
    float mPurple1 = (float)[sharpness[6] floatValue];
    
    float widthMultiplier = sharpnessView.bounds.size.width / (mRed1 + mOrange1 + mYellow1 + mGreen1 + mBlue1 + mWhite1 + mPurple1);
    
    CGRect sharpnessRect = sharpnessView.bounds;
    
    CGRect red = CGRectMake(sharpnessRect.origin.x, sharpnessRect.origin.y, mRed1 * widthMultiplier, sharpnessRect.size.height);
    UIView *redView = [[UIView alloc] initWithFrame:red];
    frameWidth += red.size.width;
    [redView setBackgroundColor:[UIColor redColor]];
    [sharpnessView addSubview:redView];
    
    CGRect orange = CGRectMake(red.size.width, red.origin.y, mOrange1 * widthMultiplier, sharpnessRect.size.height);
    UIView *orangeView = [[UIView alloc] initWithFrame:orange];
    frameWidth += orange.size.width;
    [orangeView setBackgroundColor:[UIColor orangeColor]];
    [sharpnessView addSubview:orangeView];
    
    CGRect yellow = CGRectMake(red.size.width + orange.size.width, orange.origin.y, mYellow1 * widthMultiplier, sharpnessRect.size.height);
    UIView *yellowView = [[UIView alloc] initWithFrame:yellow];
    frameWidth += yellow.size.width;
    [yellowView setBackgroundColor:[UIColor yellowColor]];
    [sharpnessView addSubview:yellowView];
    
    CGRect green = CGRectMake(red.size.width+yellow.size.width+orange.size.width, yellow.origin.y, mGreen1 * widthMultiplier, sharpnessRect.size.height);
    UIView *greenView = [[UIView alloc] initWithFrame:green];
    frameWidth += green.size.width;
    [greenView setBackgroundColor:[UIColor greenColor]];
    [sharpnessView addSubview:greenView];
    
    CGRect blue = CGRectMake(red.size.width+yellow.size.width+orange.size.width+green.size.width, green.origin.y, mBlue1 * widthMultiplier, sharpnessRect.size.height);
    frameWidth += blue.size.width;
    UIView *blueView = [[UIView alloc] initWithFrame:blue];
    [blueView setBackgroundColor:[UIColor blueColor]];
    [sharpnessView addSubview:blueView];
    
    CGRect white = CGRectMake(red.size.width+yellow.size.width+orange.size.width+green.size.width+blue.size.width, blue.origin.y, mWhite1 * widthMultiplier, sharpnessRect.size.height);
    frameWidth += white.size.width;
    UIView *whiteView = [[UIView alloc] initWithFrame:white];
    [whiteView setBackgroundColor:[UIColor whiteColor]];
    [sharpnessView addSubview:whiteView];
    
    CGRect purple = CGRectMake(red.size.width+yellow.size.width+orange.size.width+green.size.width+blue.size.width+white.size.width, white.origin.y, mPurple1 * widthMultiplier, sharpnessRect.size.height);
    UIView *purpleView = [[UIView alloc] initWithFrame:purple];
    frameWidth += purple.size.width;
    [purpleView setBackgroundColor:[UIColor purpleColor]];
    [sharpnessView addSubview:purpleView];
    
    [sharpnessView setFrame:CGRectMake(sharpnessView.frame.origin.x, sharpnessView.frame.origin.x, frameWidth, sharpnessView.frame.size.height)];
    

    
}

@end

@implementation ArmorSet

-(NSArray *)returnNonNullSetItems {
    NSMutableArray *nonNullArmor = [[NSMutableArray alloc] init];
    
    if (self.helm) {
        [nonNullArmor addObject:self.helm];
    }
    if (self.chest) {
        [nonNullArmor addObject:self.chest];
    }
    if (self.arms) {
        [nonNullArmor addObject:self.arms];
    }
    if (self.waist) {
        [nonNullArmor addObject:self.waist];
    }
    if (self.legs) {
        [nonNullArmor addObject:self.legs];
    }
    if (self.talisman) {
        [nonNullArmor addObject:self.talisman];
    }
    
    if (self.weapon) {
        [nonNullArmor addObject:self.weapon];
    }
    
    return nonNullArmor;
}

-(Item *)returnItemForSlot:(NSString *)slot {
    if ([slot isEqualToString:@"Head"]) {
        return self.helm;
    } else if ([slot isEqualToString:@"Body"]) {
        return self.chest;
    } else if ([slot isEqualToString:@"Arms"]) {
        return self.arms;
    } else if ([slot isEqualToString:@"Waist"]) {
        return self.waist;
    } else if ([slot isEqualToString:@"Legs"]) {
        return self.legs;
    }else if ([slot isEqualToString:@"Talisman"]) {
            return self.talisman;
    } else if ([slot isEqualToString:@"Weapon"]){
        return self.weapon;
    } else {
        return nil;
    }
    
}

-(NSArray *)returnItemsWithDecorations {
    NSMutableArray *itemsWithDecorations = [[NSMutableArray alloc] init];
    
    for (Item *setItem in [self returnNonNullSetItems]) {
        if (setItem.decorationsArray.count > 0) {
            [itemsWithDecorations addObject:@[setItem.slot, setItem.decorationsArray]];
        }
    }
    
    return itemsWithDecorations;
}

-(NSDictionary *)sumAllStats {
    int minDefense = 0;
    int maxDefense = 0;
    int fireRes = 0;
    int waterRes = 0;
    int thunderRes = 0;
    int iceRes = 0;
    int dragonRes = 0;
    int numSlots = 0;
    
    
    for (Item *setItem in [self returnNonNullSetItems]) {
        if (![setItem isEqual:_weapon]) {
            Armor *armor = (Armor *)setItem;
            minDefense += armor.defense;
            maxDefense += armor.maxDefense;
            fireRes += armor.fireResistance;
            waterRes += armor.waterResistance;
            thunderRes += armor.thunderResistance;
            iceRes += armor.iceResistance;
            dragonRes += armor.dragonResistance;
            numSlots += armor.numSlots;
        }
    }
    
    return @{@"minDefense" : [NSNumber numberWithInt:minDefense], @"maxDefense" : [NSNumber numberWithInt:maxDefense], @"fireRes" : [NSNumber numberWithInt:fireRes], @"waterRes" : [NSNumber numberWithInt:waterRes], @"thunderRes" : [NSNumber numberWithInt:thunderRes], @"iceRes" : [NSNumber numberWithInt:iceRes], @"dragonRes" : [NSNumber numberWithInt:dragonRes], @"numSlots" : [NSNumber numberWithInt:numSlots]};
}


@end

@implementation Talisman

@end
