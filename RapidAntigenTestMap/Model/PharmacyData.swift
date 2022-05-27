//
//  PharmacyData.swift
//  RapidAntigenTestMap
//
//  Created by Ryan@work on 2022/5/26.
//

import SwiftUI
import GoogleMaps


// 台北松菸：25.044633, 121.559722
// 基隆長庚：25.120521, 121.722713
// 台北北醫：25.024898, 121.561204
// 板橋車站：25.013884, 121.463180
// 台中車站：24.137159, 120.686262

var radius: Int = 1000

struct MedModel {
    
    var medCode: String                  // 01 "醫事機構代碼"
    var medName: String                  // 02 "醫事機構名稱"
    var medAddress: String               // 03 "醫事機構地址"
    var medPlaceLon: Double              // 04 "經度"
    var medPlaceLat: Double              // 05 "緯度"
    var medPhone: String                 // 06 "醫事機構電話"
    var medBrand: String                 // 07 "廠牌項目"
    var medStoreNumber: String           // 08 "快篩試劑截至目前結餘存貨數量"
    var medUpdateTime: String            // 09 "來源資料時間"
    var medRemarks: String               // 10 "備註"
}
