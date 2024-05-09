//
//  PersonalRecord.swift
//  FitPro
//
//  Created by Sarthak Aggarwal on 4/15/24.
//

import Foundation
import SwiftData
import MapKit

@Model class meal{
    @Attribute var name: String
    @Attribute var calories: Int
    @Attribute var date: Date
    init(name: String, calories: Int, date: Date) {
            self.name = name
            self.calories = calories
            self.date = date
        }
}

struct Gym: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

// JSON structure of the news articles API
struct news: Decodable {
 let totalArticles:Int
 let articles: [Article]
}

struct Source: Decodable {
 let name:String?
 let url: URL?
}

struct Article :Decodable{
    let content: String?
    let description: String?
    let publishedAt: String?
    let title: String?
    let url : URL?
    let image : URL?
    let source : Source
    
}
// news article structure for list view in the ContentView
struct NewsArticle {
    var id = UUID()
    let title: String?
    let url : URL
}

