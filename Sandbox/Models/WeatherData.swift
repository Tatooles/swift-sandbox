//
//  WeatherData.swift
//  Sandbox
//
//  Created by Kevin Tatooles on 12/14/25.
//

import Foundation

struct WeatherData: Identifiable {
    let id = UUID()
    let date: Date
    let dayOfWeek: String
    let highTemp: Int
    let lowTemp: Int
    let precipitationChance: Int
    let windSpeed: Int
    let dayHumidity: Int?
    let nightHumidity: Int?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    var isRainy: Bool {
        precipitationChance > 30
    }
}

func generateDummyWeatherData() -> [WeatherData] {
    let calendar = Calendar.current
    let today = Date()
    let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    let weatherVariations: [(high: Int, low: Int, precip: Int, wind: Int, humidity: Int, pressure: Double)] = [
        (72, 54, 10, 8, 45, 1015.2),
        (68, 52, 45, 12, 65, 1012.8),
        (65, 48, 80, 18, 85, 1008.5),
        (70, 50, 20, 10, 55, 1018.3),
        (75, 58, 5, 6, 40, 1020.1),
        (78, 60, 15, 9, 50, 1017.6),
        (74, 56, 35, 14, 60, 1014.2),
        (69, 51, 60, 16, 75, 1010.9),
        (71, 53, 25, 11, 58, 1016.4),
        (76, 57, 8, 7, 42, 1019.8)
    ]
    
    return (0..<10).map { dayOffset in
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
        let weekday = calendar.component(.weekday, from: date) - 1
        let variation = weatherVariations[dayOffset]
        
        return WeatherData(
            date: date,
            dayOfWeek: dayNames[weekday],
            highTemp: variation.high,
            lowTemp: variation.low,
            precipitationChance: variation.precip,
            windSpeed: variation.wind,
            dayHumidity: variation.humidity,
            nightHumidity: variation.humidity + 10
        )
    }
}
