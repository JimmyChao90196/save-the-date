//
//  ExploreModel.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/1.
//

import Foundation
import UIKit

enum ContryModel: String, CaseIterable {
    
    case taiwan = "Taiwan"
    case japan = "Japan"
    case korea = "Korea"
    case america = "America"
    case canada = "Canada"
    case british = "British"
    case france = "France"
    case germany = "Germany"
    
    var countryImageName: String {
        switch self {
        case .taiwan: return "Placeholder01"
        case .japan: return "Placeholder02"
        case .korea: return "Placeholder03"
        case .america: return "Placeholder04"
        case .canada: return "Placeholder05"
        case .british: return "Placeholder06"
        case .france: return "Placeholder07"
        case .germany: return "Placeholder08"
        }
    }
}

enum TaiwanCityModel: String, CaseIterable {
    case taipei = "Taipei City"
    case newTaipei = "New Taipei City"
    case taichung = "Taichung City"
    case tainan = "Tainan City"
    case kaohsiung = "Kaohsiung City"
    case taoyuan = "Taoyuan City"
    case hsinchu = "Hsinchu City"
    case keelung = "Keelung City"
    case chiayi = "Chiayi City"
    case yilan = "Yilan City"
    case miaoli = "Miaoli City"
    case changhua = "Changhua City"
    case nantou = "Nantou City"
    case yunlin = "Yunlin City"
    case pingtung = "Pingtung City"
    case taitung = "Taitung City"
    case hualien = "Hualien City"
    case penghu = "Penghu City"
    case kinmen = "Kinmen City"
    case none
    
    case lienchiang = "Lienchiang"
    
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
                    "Wenshan", "none"].map {$0 + " District"}
            
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
                    "Sanxia", "none"].map {$0 + " District"}
            
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
                    "Wuri", "none"].map {$0 + " District"}
            
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
                    "Zuozhen", "none"].map {$0 + " District"}
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
                    "Nanzi", "none"].map {$0 + " District"}
            
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
                    "Guanyin", "none"].map {$0 + " District"}
            
        case .hsinchu:
            return ["East",
                    "North",
                    "Xiangshan",
                    "Zhubei",
                    "Hukou",
                    "Xinfeng",
                    "Zhubei",
                    "Guanxi",
                    "Qionglin",
                    "Baoshan", "none"].map {$0 + " District"}
            
        case .keelung:
            return ["Ren’ai",
                    "Xinyi",
                    "Zhongzheng",
                    "Zhongshan",
                    "Anle",
                    "Nuannuan",
                    "Qidu", "none"].map {$0 + " District"}
            
        case .chiayi:
            return ["East",
                    "West",
                    "Fanlu",
                    "Meishan",
                    "Zhuqi",
                    "Alishan",
                    "Zhongpu",
                    "Dapu",
                    "Shuishang", "none"].map {$0 + " District"}
            
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
                    "Nan'ao", "none"].map {$0 + " District"}
            
        case .miaoli:
            return ["Miaoli",
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
                    "Gongguan", "none"].map {$0 + " District"}
            
        case .changhua:
            return ["Changhua",
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
                    "Puyan", "none"].map {$0 + " District"}
            
        case .nantou:
            return ["Nantou",
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
                    "Ren'ai", "none"].map {$0 + " District"}
            
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
                    "Lunbei", "none"].map {$0 + " District"}
            
        case .pingtung:
            return ["Pingtung",
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
                    "Linbian", "none"].map {$0 + " District"}
            
        case .taitung:
            return ["Taitung",
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
                    "Lan Yu", "none"].map {$0 + " District"}
            
        case .hualien:
            return ["Hualien",
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
                    "Sioulin", "none"].map {$0 + " District"}
            
        case .penghu:
            return ["Magong", 
                    "Baisha",
                    "Xiyu",
                    "Wang'an",
                    "Qimei",
                    "Huxi",
                    "Fongguei",
                    "Hujing", "none"].map {$0 + " District"}
            
        case .kinmen:
            return ["Jincheng", 
                    "Jinsha",
                    "Jinhu",
                    "Jinning",
                    "Lieyu",
                    "Wuqiu", "none"].map {$0 + " District"}
        case .lienchiang:
            return ["Nangan", "Beigan", "Juguang", "Dongyin", "none"].map {$0 + " District"}
            
        case .none: return ["none"]
        }
        
    }
}
