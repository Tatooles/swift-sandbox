//
//  ContentView.swift
//  Sandbox
//
//  Created by Kevin Tatooles on 12/14/25.
//

import SwiftUI

struct ContentView: View {
    let weatherData = generateDummyWeatherData()
    @State private var selectedWeather: WeatherData?
    
    var todayWeather: WeatherData {
        weatherData.first!
    }
    
    var displayedWeather: WeatherData {
        selectedWeather ?? todayWeather
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top 1/3: Horizontal Scroll View with Day Tiles
                VStack(alignment: .leading, spacing: 8) {
                    Text("10-Day Forecast")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(weatherData) { day in
                                DayForecastTile(weather: day, isSelected: displayedWeather.id == day.id)
                                    .onTapGesture {
                                        selectedWeather = day
                                    }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
                .frame(height: geometry.size.height / 3)
                .background(Color(.systemGroupedBackground))
                
                // Bottom 2/3: Selected Day's Detailed View
                ScrollView {
                    DetailView(weather: displayedWeather)
                        .padding()
                }
                .frame(height: geometry.size.height * 2 / 3)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ContentView()
}
