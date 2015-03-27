//
//  MH4UDBEngine.swift
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/27/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

import Foundation

func dbQuery(query : String) -> FMResultSet? {
    let mh4uDB = FMDatabase(path: NSBundle.mainBundle().pathForResource("mh4u", ofType: ".db"));
    if !mh4uDB.open() {
        return nil;
    } else {
        return mh4uDB.executeQuery(query, withArgumentsInArray: nil);
    }
}

func retrieveMonsters(monsterID : Int?) -> NSArray {
    var monsterArray: [Monster] = [];
    
    var query : String;
    
    if (monsterID != nil) {
        query = "SELECT * FROM Monsters where monsters._id = \(monsterID)";
    } else {
        query = "SELECT * FROM Monsters";
    }
    
    if let s = dbQuery(query) {
        
        while (s.next()) {
            var monster = Monster();
            monster.monsterID = s.intForColumn("_id");
            monster.monsterClass = s.stringForColumn("class");
            monster.monsterName = s.stringForColumn("name");
            monster.trait = s.stringForColumn("trait")
            monster.iconName = s.stringForColumn("icon_name");
            monsterArray.append(monster);
        }
    }
    monsterArray.sort({$0.monsterName < $1.monsterName});
    return monsterArray;
}

func retrieveMonsterDamageForMonster(monster : Monster) {
    var damageArray : [MonsterDamage] = [];
    
//    MonsterDamage *md = [[MonsterDamage alloc] init];
//    md.bodyPart = [s stringForColumn:@"body_part"];
//    md.cutDamage = [s intForColumn:@"cut"];
//    md.impactDamage = [s intForColumn:@"impact"];
//    md.shotDamage = [s intForColumn:@"shot"];
//    md.fireDamage = [s intForColumn:@"fire"];
//    md.waterDamage = [s intForColumn:@"water"];
//    md.iceDamage = [s intForColumn:@"ice"];
//    md.thunderDamage = md.cutDamage = [s intForColumn:@"thunder"];
//    md.dragonDamage = [s intForColumn:@"dragon"];
//    md.stun = [s intForColumn:@"ko"];
//    [monsterDamageArray addObject:md];

}
