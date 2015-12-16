//
//  CitiesAndStates.m
//  Classroom Hero
//
//  Created by Josh Nussbaum on 12/13/15.
//  Copyright © 2015 Josh Nussbaum. All rights reserved.
//

#import "CitiesAndStates.h"

@implementation CitiesAndStates


+ (NSArray *)getAllStates{
    NSArray *states =  @[@"Alabama",@"Alaska",@"Arizona",@"Arkansas",@"California",@"Colorado",@"Connecticut",@"Delaware", @"Florida",@"Georgia",@"Hawaii",@"Idaho",@"Illinois",@"Indiana",@"Iowa",@"Kansas",@"Kentucky",@"Louisiana", @"Maine",@"Maryland",@"Massachusetts",@"Michigan",@"Minnesota",@"Mississippi",@"Misouri",@"Montana", @"Nevada",@"Nebraska",@"New Hampshire",@"New Jersey",@"New Mexico",@"New York",@"North Carolina",@"North Dakota",@"Ohio",@"Ohio",@"Oklahoma",@"Oregon", @"Pennsylvania",@"Rhode Island",@"South Carolina",@"South Dakota",@"Tennessee",@"Texas",@"Utah", @"Vermont",@"Virginia",@"Washington",@"West Virginia",@"Wisconsin",@"Wyoming", @"Vermont",@"Virginia",@"Washington",@"West Virginia",@"Wisconsin",@"Wyoming"];
    return states;
}

+ (NSArray *)getCitiesByState:(NSString *)state{
    if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"alabama"]){
        return [self getAlabamaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"alaska"]){
        return [self getAlaskaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"arizona"]){
        return [self getArizonaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"arkansas"]){
        return [self getArkansasCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"california"]){
        return [self getCaliforniaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"colorado"]){
        return [self getColoradoCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"connecticut"]){
        return [self getConnecticutCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"deleware"]){
        return [self getDelewareCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"florida"]){
        return [self getFloridaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"georgia"]){
        return [self getGeorgiaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"hawaii"]){
        return [self getHawaiiCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"idaho"]){
        return [self getIdahoCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"illinois"]){
        return [self getIllinoisCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"indiana"]){
        return [self getIndianaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"iowa"]){
        return [self getIowaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"kansas"]){
        return [self getKansasCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"kentucky"]){
        return [self getKentuckyCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"louisiana"]){
        return [self getLousianaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"maine"]){
        return [self getMaineCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"maryland"]){
        return [self getMarylandCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"massachusetts"]){
        return [self getMassachusettsCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"michigan"]){
        return [self getMichiganCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"mississippi"]){
        return [self getMississippiCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"minnesota"]){
        return [self getMinnesotaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"misouri"]){
        return [self getMisouriCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"montana"]){
        return [self getMontanaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"nebraska"]){
        return [self getNebraskaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"nevada"]){
        return [self getNevadaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"newhampshire"]){
        return [self getNewHampshireCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"newjersey"]){
        return [self getNewJerseyCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"newmexico"]){
        return [self getNewMexicoCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"newyork"]){
        return [self getNewYorkCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"northcarolina"]){
        return [self getNorthCarolinaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"northdakota"]){
        return [self getNorthDakotaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"ohio"]){
        return [self getOhioCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"oklahoma"]){
        return [self getOklahomaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"oregon"]){
        return [self getOregonCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"pennsylvania"]){
        return [self getPennsylvaniaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"rhodeisland"]){
        return [self getRhodeIslandCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"southcarolina"]){
        return [self getSouthCarolinaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"southdakota"]){
        return [self getSouthDakotaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"tennessee"]){
        return [self getTennesseeCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"texas"]){
        return [self getTexasCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"utah"]){
        return [self getUtahCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"vermont"]){
        return [self getVermontCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"virginia"]){
        return [self getVirginiaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"washington"]){
        return [self getWashingtonCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"westvirginia"]){
        return [self getWestVirginiaCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"wisconsin"]){
        return [self getWisconsinCities];
    }
    else if ([[state stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString isEqualToString:@"wyoming"]){
        return [self getWyomingCities];
    }
    else {
        return nil;
    }
}

+ (NSArray *)getAlabamaCities{
    return @[@"auburn",
             @"birmingham",
             @"dothan",
             @"florence / muscle shoals",
             @"gadsden-anniston",
             @"huntsville / decatur",
             @"mobile",
             @"montgomery",
             @"tuscaloosa"];

}

+ (NSArray *)getAlaskaCities{
    return @[@"anchorage / mat-su",
             @"fairbanks",
             @"kenai peninsula",
             @"southeast alaska"];
}

+ (NSArray *)getArizonaCities{
    return @[@"flagstaff / sedona",
             @"mohave county",
             @"phoenix",
             @"prescott",
             @"show low",
             @"sierra vista",
             @"tucson",
             @"yuma"];
}

+ (NSArray *)getArkansasCities{
    return @[@"fayetteville",
             @"fort smith",
             @"jonesboro",
             @"little rock",
             @"texarkana"];
}

+ (NSArray *)getCaliforniaCities{
    return @[@"bakersfield",
             @"chico",
             @"fresno / madera",
             @"gold country",
             @"hanford-corcoran",
             @"humboldt county",
             @"imperial county",
             @"inland empire",
             @"los angeles",
             @"mendocino county",
             @"merced",
             @"modesto",
             @"monterey bay",
             @"orange county",
             @"palm springs",
             @"redding",
             @"sacramento",
             @"san diego",
             @"san francisco bay area",
             @"san luis obispo",
             @"santa barbara",
             @"santa maria",
             @"siskiyou county",
             @"stockton",
             @"susanville",
             @"ventura county",
             @"visalia-tulare",
             @"yuba-sutter"];
}

+ (NSArray *)getColoradoCities{
    return  @[@"boulder",
              @"colorado springs",
              @"denver",
              @"eastern CO",
              @"fort collins / north CO",
              @"high rockies",
              @"pueblo",
              @"western slope"];
}

+ (NSArray *)getConnecticutCities{
    return @[@"eastern CT",
             @"hartford",
             @"new haven",
             @"northwest CT"];
}

+ (NSArray *)getDelewareCities{
    return @[@"delware"];
}

+ (NSArray *)getFloridaCities{
    return @[@"daytona beach",
             @"florida keys",
             @"fort lauderdale",
             @"ft myers / SW florida",
             @"gainesville",
             @"heartland florida",
             @"jacksonville",
             @"lakeland",
             @"north central FL",
             @"ocala",
             @"okaloosa / walton",
             @"orlando",
             @"panama city",
             @"pensacola",
             @"sarasota-bradenton",
             @"south florida",
             @"space coast",
             @"st augustine",
             @"tallahassee",
             @"tampa bay area",
             @"treasure coast",
             @"west palm beach"];
}

+ (NSArray *)getGeorgiaCities{
    return @[@"albany",
             @"athens",
             @"atlanta",
             @"augusta",
             @"brunswick",
             @"columbus",
             @"macon / warner robins",
             @"northwest GA",
             @"savannah / hinesville",
             @"statesboro",
             @"valdosta"];
}

+ (NSArray *)getHawaiiCities{
    return @[@"hawaii"];
}

+ (NSArray *)getIdahoCities{
    return @[@"boise",
             @"east idaho",
             @"lewiston / clarkston",
             @"twin falls"];
}

+ (NSArray *)getIllinoisCities{
    return @[@"bloomington-normal",
             @"champaign urbana",
             @"chicago",
             @"decatur",
             @"la salle co",
             @"mattoon-charleston",
             @"peoria",
             @"rockford",
             @"southern illinois",
             @"springfield",
             @"western IL"];
}

+ (NSArray *)getIndianaCities{
    return @[@"bloomington",
             @"evansville",
             @"fort wayne",
             @"indianapolis",
             @"kokomo",
             @"lafayette / west lafayette",
             @"muncie / anderson",
             @"richmond",
             @"south bend / michiana",
             @"terre haute"];
}

+ (NSArray *)getIowaCities{
    return @[@"ames",
             @"cedar rapids",
             @"des moines",
             @"dubuque",
             @"fort dodge",
             @"iowa city",
             @"mason city",
             @"quad cities",
             @"sioux city",
             @"southeast IA",
             @"waterloo / cedar falls"];
}

+ (NSArray *)getKansasCities{
    return @[@"lawrence",
             @"manhattan",
             @"northwest KS",
             @"salina",
             @"southeast KS",
             @"southwest KS",
             @"topeka",
             @"wichita"];
}

+ (NSArray *)getKentuckyCities{
    return @[@"bowling green",
             @"eastern kentucky",
             @"lexington",
             @"louisville",
             @"owensboro",
             @"western KY"];
}

+ (NSArray *)getLousianaCities{
    return @[@"baton rouge",
             @"central louisiana",
             @"houma",
             @"lafayette",
             @"lake charles",
             @"monroe",
             @"new orleans",
             @"shreveport"];
}

+ (NSArray *)getMaineCities{
    return @[@"maine"];
}

+ (NSArray *)getMarylandCities{
    return @[@"annapolis",
             @"baltimore",
             @"eastern shore",
             @"frederick",
             @"southern maryland",
             @"western maryland"];
}

+ (NSArray *)getMassachusettsCities{
    return @[@"boston",
             @"cape cod / islands",
             @"south coast",
             @"western massachusetts",
             @"worcester / central MA"];
}

+ (NSArray *)getMichiganCities{
    return @[@"ann arbor",
             @"battle creek",
             @"central michigan",
             @"detroit metro",
             @"flint",
             @"grand rapids",
             @"holland",
             @"jackson",
             @"kalamazoo",
             @"lansing",
             @"monroe",
             @"muskegon",
             @"northern michigan",
             @"port huron",
             @"saginaw-midland-baycity",
             @"southwest michigan",
             @"the thumb",
             @"upper peninsula"];
}

+ (NSArray *)getMississippiCities{
    return @[@"gulfport / biloxi",
             @"hattiesburg",
             @"jackson",
             @"meridian",
             @"north mississippi",
             @"southwest MS"];

}

+ (NSArray *)getMinnesotaCities{
    return @[@"bemidji",
             @"brainerd",
             @"duluth / superior",
             @"mankato",
             @"minneapolis / st paul",
             @"rochester",
             @"southwest MN",
             @"st cloud"];
}

+ (NSArray *)getMisouriCities{
    return @[@"columbia / jeff city",
             @"joplin",
             @"kansas city",
             @"kirksville",
             @"lake of the ozarks",
             @"southeast missouri",
             @"springfield",
             @"st joseph",
             @"st louis"];
}

+ (NSArray *)getMontanaCities{
    return @[@"billings",
             @"bozeman",
             @"butte",
             @"great falls",
             @"helena",
             @"kalispell",
             @"missoula",
             @"eastern montana"];
    
   
}

+ (NSArray *)getNebraskaCities{
    return @[@"grand island",
             @"lincoln",
             @"north platte",
             @"omaha / council bluffs",
             @"scottsbluff / panhandle"];
}

+ (NSArray *)getNevadaCities{
    return @[@"elko",
             @"las vegas",
             @"reno / tahoe"];
}

+ (NSArray *)getNewHampshireCities{
    return @[@"New Hampshire"];
}

+ (NSArray *)getNewJerseyCities{
    return @[@"central NJ",
             @"jersey shore",
             @"north jersey",
             @"south jersey"];
}

+ (NSArray *)getNewMexicoCities{
    return @[@"albuquerque",
             @"clovis / portales",
             @"farmington",
             @"las cruces",
             @"roswell / carlsbad",
             @"santa fe / taos"];
}

+ (NSArray *)getNewYorkCities{
    return @[@"albany",
             @"binghamton",
             @"buffalo",
             @"catskills",
             @"chautauqua",
             @"elmira-corning",
             @"finger lakes",
             @"glens falls",
             @"hudson valley",
             @"ithaca",
             @"long island",
             @"new york city",
             @"oneonta",
             @"plattsburgh-adirondacks",
             @"potsdam-canton-massena",
             @"rochester",
             @"syracuse",
             @"twin tiers NY/PA",
             @"utica-rome-oneida",
             @"watertown"];
}

+ (NSArray *)getNorthCarolinaCities{
    return @[@"asheville",
             @"boone",
             @"charlotte",
             @"eastern NC",
             @"fayetteville",
             @"greensboro",
             @"hickory / lenoir",
             @"jacksonville",
             @"outer banks",
             @"raleigh / durham / CH",
             @"wilmington",
             @"winston-salem"];
}

+ (NSArray *)getNorthDakotaCities{
    return @[@"bismarck",
             @"fargo / moorhead",
             @"grand forks",
             @"north dakota"];
}

+ (NSArray *)getOhioCities{
    return  @[@"akron / canton",
              @"ashtabula",
              @"athens",
              @"chillicothe",
              @"cincinnati",
              @"cleveland",
              @"columbus",
              @"dayton / springfield",
              @"lima / findlay",
              @"mansfield",
              @"sandusky",
              @"toledo",
              @"tuscarawas co",
              @"youngstown",
              @"zanesville / cambridge"];
}

+ (NSArray *)getOklahomaCities{
    return  @[@"lawton",
              @"northwest OK",
              @"oklahoma city",
              @"stillwater",
              @"tulsa"];
}

+ (NSArray *)getOregonCities{
    return @[@"bend",
             @"corvallis/albany",
             @"east oregon",
             @"eugene",
             @"klamath falls",
             @"medford-ashland",
             @"oregon coast",
             @"portland",
             @"roseburg",
             @"salem"];
}

+ (NSArray *)getPennsylvaniaCities{
    return @[@"altoona-johnstown",
             @"cumberland valley",
             @"erie",
             @"harrisburg",
             @"lancaster",
             @"lehigh valley",
             @"meadville",
             @"philadelphia",
             @"pittsburgh",
             @"poconos",
             @"reading",
             @"scranton / wilkes-barre",
             @"state college",
             @"williamsport",
             @"york"];
}

+ (NSArray *)getRhodeIslandCities{
    return @[@"Rhode Island"];
}

+ (NSArray *)getSouthCarolinaCities{
    return @[@"charleston",
             @"columbia",
             @"florence",
             @"greenville / upstate",
             @"hilton head",
             @"myrtle beach"];
}

+ (NSArray *)getSouthDakotaCities{
    return @[@"northeast SD",
             @"pierre / central SD",
             @"rapid city / west SD",
             @"sioux falls / SE SD",
             @"south dakota"];
}

+ (NSArray *)getTennesseeCities{
    return @[@"chattanooga",
             @"clarksville",
             @"cookeville",
             @"jackson",
             @"knoxville",
             @"memphis",
             @"nashville",
             @"tri-cities"];
}

+ (NSArray *)getTexasCities{
    return @[@"abilene",
             @"amarillo",
             @"austin",
             @"beaumont / port arthur",
             @"brownsville",
             @"college station",
             @"corpus christi",
             @"dallas / fort worth",
             @"deep east texas",
             @"del rio / eagle pass",
             @"el paso",
             @"galveston",
             @"houston",
             @"killeen / temple / ft hood",
             @"laredo",
             @"lubbock",
             @"mcallen / edinburg",
             @"odessa / midland",
             @"san angelo",
             @"san antonio",
             @"san marcos",
             @"southwest TX",
             @"texoma",
             @"tyler / east TX",
             @"victoria",
             @"waco",
             @"wichita falls"];
}

+ (NSArray *)getUtahCities{
    return @[@"logan",
             @"ogden-clearfield",
             @"provo / orem",
             @"salt lake city",
             @"st george"];
}

+ (NSArray *)getVermontCities{
    return  @[@"Vermont"];
}

+ (NSArray *)getVirginiaCities{
    return @[@"charlottesville",
             @"danville",
             @"fredericksburg",
             @"hampton roads",
             @"harrisonburg",
             @"lynchburg",
             @"new river valley",
             @"richmond",
             @"roanoke",
             @"southwest VA",
             @"winchester"];
}

+ (NSArray *)getWashingtonCities{
    return @[@"bellingham",
             @"kennewick-pasco-richland",
             @"moses lake",
             @"olympic peninsula",
             @"pullman / moscow",
             @"seattle-tacoma",
             @"skagit / island / SJI",
             @"spokane / coeur d'alene",
             @"wenatchee",
             @"yakima"];
}

+ (NSArray *)getWestVirginiaCities{
    return @[@"charleston",
             @"eastern panhandle",
             @"huntington-ashland",
             @"morgantown",
             @"northern panhandle",
             @"parkersburg-marietta",
             @"southern WV",
             @"west virginia (old)"];
}

+ (NSArray *)getWisconsinCities{
    return @[@"appleton-oshkosh-FDL",
             @"eau claire",
             @"green bay",
             @"janesville",
             @"kenosha-racine",
             @"la crosse",
             @"madison",
             @"milwaukee",
             @"northern WI",
             @"sheboygan",
             @"wausau"];
}

+ (NSArray *)getWyomingCities{
    return  @[@"Wyoming"];
}



@end
