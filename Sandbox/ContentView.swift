//
//  ContentView.swift
//  Sandbox
//
//  Created by Kevin Tatooles on 12/14/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Dec 10 - Dec 17")
        ScrollView([.horizontal]) {
            HStack {
                DayForecast(day: "Mon", isRainy: false, high: 70, low: 50)
                DayForecast(day: "Tue", isRainy: true, high: 60, low: 40)
                DayForecast(day: "Wed", isRainy: false, high: 68, low: 49)
                DayForecast(day: "Thu", isRainy: false, high: 68, low: 49)
                DayForecast(day: "Fri", isRainy: false, high: 68, low: 49)
                DayForecast(day: "Sat", isRainy: false, high: 68, low: 49)
                DayForecast(day: "Sun", isRainy: false, high: 68, low: 49)
            }
        }
        .padding()
    }
}

struct DayForecast: View {
    let day: String
    let isRainy: Bool
    let high: Int
    let low: Int
    
    var iconName: String {
        isRainy ? "cloud.rain.fill" : "sun.max.fill"
    }
    
    var iconColor: Color {
        isRainy ? Color.blue : Color.yellow
    }
    
    var body: some View {
        VStack {
            Text(day).font(Font.largeTitle)
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .font(Font.largeTitle)
                .padding(5)
            Text("High: \(high)º")
                .fontWeight(Font.Weight.semibold)
            Text("Low: \(low)º")
                .fontWeight(Font.Weight.medium)
                .foregroundStyle(Color.secondary)
        }
        .padding()
        .border(Color.black)
    }
}

#Preview {
    ContentView()
}
