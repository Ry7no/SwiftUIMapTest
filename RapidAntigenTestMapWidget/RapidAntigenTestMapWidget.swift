//
//  RapidAntigenTestMapWidget.swift
//  RapidAntigenTestMapWidget
//
//  Created by @Ryan on 2022/9/6.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), nearestMed: MedModel(name: "健康藥局", address: "  快篩藥局地址  ", phone: "0222222222", storeNumber: "500", distance: 50, updatedTime: "", totalCount: 30), configuration: ConfigurationIntent())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), nearestMed: MedModel(name: "健康藥局", address: "  快篩藥局地址  ", phone: "0222222222", storeNumber: "500", distance: 50, updatedTime: "", totalCount: 30), configuration: configuration)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let name = UserDefaults(suiteName: "group.com.novachens.RapidAntigenTestMap")!.string(forKey: "nearestName") ?? "健康藥局"
        let address = UserDefaults(suiteName: "group.com.novachens.RapidAntigenTestMap")!.string(forKey: "nearestAddress") ?? "避難場所地址"
        let phone = UserDefaults(suiteName: "group.com.novachens.RapidAntigenTestMap")!.string(forKey: "nearestPhone") ?? "02-12346574"
        let storeNumber = UserDefaults(suiteName: "group.com.novachens.RapidAntigenTestMap")!.string(forKey: "nearestStoreNumber") ?? "400"
        let distance = UserDefaults(suiteName: "group.com.novachens.RapidAntigenTestMap")!.integer(forKey: "nearestDistance")
        let updatedTime = UserDefaults(suiteName: "group.com.novachens.RapidAntigenTestMap")!.string(forKey: "nearestUpdateTime") ?? "20220905130023"
        let totalCount = UserDefaults(suiteName: "group.com.novachens.RapidAntigenTestMap")!.integer(forKey: "totalCount")
        
        let currentDate = Date()
        for minuteOffset in 1 ..< 20 {
            guard let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset * 3, to: currentDate) else {
                continue
            }
            let entry = SimpleEntry(date: entryDate, nearestMed: MedModel(name: name, address: address, phone: phone, storeNumber: storeNumber, distance: distance, updatedTime: updatedTime, totalCount: totalCount), configuration: configuration)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let nearestMed: MedModel
    let configuration: ConfigurationIntent
}

struct MedModel {
    
    var name: String = ""
    var address: String = ""
    var phone: String = ""
    var storeNumber: String = ""
    var distance: Int = 0
    var updatedTime: String = ""
    var totalCount: Int = 0
}

struct RapidAntigenTestMapWidgetEntryView : View {
    
    var entry: Provider.Entry
    
    var body: some View {
        
        GeometryReader { geo in
            
            if geo.size.width < UIScreen.main.bounds.width/2 {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack(alignment: .center, spacing: 0) {
                        
                        Image("appImage")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .padding(.horizontal, 10)
                            
                        
                        Text("最近藥局")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)

                        
                        Text("\(entry.nearestMed.totalCount)")
                            .font(.system(size: 9, weight: .bold))
                            .frame(width: 20, height: 20, alignment: .center)
                            .foregroundColor(.white)
                            .background(Circle().foregroundColor(Color("orange")))
                            .padding(.leading, UIScreen.main.bounds.width > 400 ? 34 : 25)
   
                    }
                    .padding(.vertical, 10)
                    .padding([.leading, .top], 3)

                    
                    VStack(alignment: .center) {
                        
                        HStack {
                            
                            HStack(alignment: .center, spacing: 0) {
                                
                                AnnotationViewWidget(name: entry.nearestMed.name, distance: entry.nearestMed.distance)
                                    .frame(width: 50, height: 55)
                                    .offset(y: 20)

                                Text("\(entry.nearestMed.storeNumber)")
                                    .font(.system(size: Int(entry.nearestMed.storeNumber) ?? 500 > 999 ? 25 : 29, weight: .bold))
                                    .padding(.leading, 6)
                                Text(" 組")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .offset(x: -1, y: 7)
                                
                            }
                            .padding(.horizontal, 3)
                            
                        }
                        .padding(.bottom, -1)
                        
                        Text("\(entry.nearestMed.address)")
                            .font(.system(size: 11, weight: .bold))
                            .padding(5)
                            .padding(.horizontal, 2)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.green.opacity(0.3)))
                        
                        
                    }
                    .padding(7)
                    .background(RoundedRectangle(cornerRadius: 15).fill(.thinMaterial))
                    .padding(6)
                    .padding(.top, -2)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onChange(of: entry.nearestMed.distance != UserDefaults(suiteName: "group.com.novachens.RapidAntigenTestMap")!.integer(forKey: "nearestDistance")) { newValue in
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

@main
struct RapidAntigenTestMapWidget: Widget {
    let kind: String = "RapidAntigenTestMapWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            RapidAntigenTestMapWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("快篩地圖捷徑")
        .description("顯示最近快篩藥局")
        .supportedFamilies([.systemSmall])
    }
}

//struct RapidAntigenTestMapWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        RapidAntigenTestMapWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
