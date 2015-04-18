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

@implementation SkillCollection

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

@end

@implementation ArmorSet

-(NSArray *)returnNonNullArmor {
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
    
    return nonNullArmor;
}

@end

