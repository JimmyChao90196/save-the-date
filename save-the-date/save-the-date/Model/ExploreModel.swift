//
//  ExploreModel.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/1.
//

import Foundation

enum CityModel: String, CaseIterable {
    case taipei
    case newTaipei
    case taichung
    case tainan
    case kaohsiung
    case taoyuan
    case hsinchuCity
    case hsinchuCounty
    case keelung
    case chiayiCity
    case chiayiCounty
    case yilan
    case miaoli
    case changhua
    case nantou
    case yunlin
    case pingtung
    case taitung
    case hualien
    case penghu
    case kinmen
    case lienchiang
    
    var districts: [String] {
        switch self {
        case .taipei:
            return ["Da’an",
                    "Shilin",
                    "Zhongshan",
                    "Wanhua",
                    "Songshan",
                    "Datong",
                    "Nangang",
                    "Neihu",
                    "Zhongzheng",
                    "Xinyi",
                    "Beitou",
                    "Wenshan"]
            
        case .newTaipei:
            return ["Banqiao",
                    "Sanchong",
                    "Zhonghe",
                    "Yonghe",
                    "Xinzhuang",
                    "Tucheng",
                    "Xindian",
                    "Shulin",
                    "Luzhou",
                    "Tamsui",
                    "Yingge",
                    "Sanxia"]
            
        case .taichung:
            return ["Central",
                    "East",
                    "West",
                    "South",
                    "North",
                    "Beitun",
                    "Xitun",
                    "Nantun",
                    "Taiping",
                    "Dali",
                    "Wufeng",
                    "Wuri"]
            
        case .tainan:
            return ["East",
                    "North",
                    "Central West",
                    "South",
                    "Anping",
                    "Annan",
                    "Yongkang",
                    "Rende",
                    "East",
                    "Guiren",
                    "Xinhua",
                    "Zuozhen"]
        case .kaohsiung:
            return ["Lingya",
                    "Fengshan",
                    "Sanmin",
                    "Cianjhen",
                    "Gushan",
                    "Cianjin",
                    "Zuoying",
                    "Niaosong",
                    "Dashu",
                    "Lujhu",
                    "Hunei",
                    "Nanzi"]
            
        case .taoyuan:
            return ["Taoyuan", 
                    "Zhongli",
                    "Daxi",
                    "Yangmei",
                    "Luzhu",
                    "Dayuan",
                    "Guishan",
                    "Bade",
                    "Longtan",
                    "Pingzhen",
                    "Xinwu",
                    "Guanyin"]
            
        case .hsinchuCity:
            return ["East",
                    "North",
                    "Xiangshan"]
        case .hsinchuCounty:
            return ["Zhubei",
                    "Hukou",
                    "Xinfeng",
                    "Zhubei",
                    "Guanxi",
                    "Qionglin",
                    "Baoshan"]
            
        case .keelung:
            return ["Ren’ai",
                    "Xinyi",
                    "Zhongzheng",
                    "Zhongshan",
                    "Anle",
                    "Nuannuan",
                    "Qidu"]
            
        case .chiayiCity:
            return ["East", "West"]
        case .chiayiCounty:
            return ["Fanlu",
                    "Meishan",
                    "Zhuqi",
                    "Alishan",
                    "Zhongpu",
                    "Dapu",
                    "Shuishang"]
            
        case .yilan:
            return ["Yilan City",
                    "Luodong",
                    "Su'ao",
                    "Toucheng",
                    "Jiaoxi",
                    "Zhuangwei",
                    "Yuanshan",
                    "Dongshan",
                    "Wujie",
                    "Sanxing",
                    "Datong",
                    "Nan'ao"]
            
        case .miaoli:
            return ["Miaoli City",
                    "Toufen",
                    "Zhunan",
                    "Houlong",
                    "Tongxiao",
                    "Yuanli",
                    "Zhuolan",
                    "Sanyi",
                    "Xihu",
                    "Dahu",
                    "Tai'an",
                    "Gongguan"]
            
        case .changhua:
            return ["Changhua City",
                    "Yuanlin",
                    "Beidou",
                    "Tianzhong",
                    "Huatan",
                    "Fangyuan",
                    "Xiushui",
                    "Lugang",
                    "Fuxing",
                    "Xianxi",
                    "Erlin",
                    "Puyan"]
            
        case .nantou:
            return ["Nantou City",
                    "Caotun",
                    "Zhushan",
                    "Puli",
                    "Jiji",
                    "Mingjian",
                    "Shuili",
                    "Yuchi",
                    "Guoxing",
                    "Zhongliao",
                    "Lugu",
                    "Ren'ai"]
            
        case .yunlin:
            return ["Douliu",
                    "Huwei",
                    "Beigang",
                    "Dounan",
                    "Dapi",
                    "Tuku",
                    "Baozhong",
                    "Linnei",
                    "Gukeng",
                    "Mailiao",
                    "Taixi",
                    "Lunbei"]
            
        case .pingtung:
            return ["Pingtung City",
                    "Chaozhou",
                    "Donggang",
                    "Hengchun", 
                    "Fangliao",
                    "Fangshan", 
                    "Liuqiu",
                    "Checheng",
                    "Manzhou",
                    "Mudan",
                    "Jiadong",
                    "Linbian"]
            
        case .taitung:
            return ["Taitung City",
                    "Chenggong",
                    "Guanshan",
                    "Beinan",
                    "Changbin",
                    "Luye",
                    "Taimali",
                    "Dawu",
                    "Daren",
                    "Haiduan",
                    "Jinfeng",
                    "Lan Yu"]
            
        case .hualien:
            return ["Hualien City",
                    "Ji'an", 
                    "Shoufeng",
                    "Xincheng", 
                    "Yuli",
                    "Ruisui",
                    "Fenglin",
                    "Guangfu", 
                    "Fuli",
                    "Wanrong", 
                    "Zhuoxi",
                    "Sioulin"]
            
        case .penghu:
            return ["Magong", 
                    "Baisha",
                    "Xiyu",
                    "Wang'an",
                    "Qimei",
                    "Huxi",
                    "Fongguei",
                    "Hujing"]
            
        case .kinmen:
            return ["Jincheng", 
                    "Jinsha",
                    "Jinhu",
                    "Jinning",
                    "Lieyu",
                    "Wuqiu"]
            
        case .lienchiang:
            return ["Nangan", "Beigan", "Juguang", "Dongyin"]
        }
    }
    
}

