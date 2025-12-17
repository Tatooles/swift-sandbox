//
//  ContentView.swift
//  Sandbox
//
//  Created by Kevin Tatooles on 12/14/25.
//

import SwiftUI

struct ContentView: View {
    @State private var weatherData: [WeatherData] = []
    @State private var selectedWeather: WeatherData?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var todayWeather: WeatherData? {
        weatherData.first
    }
    
    var displayedWeather: WeatherData? {
        selectedWeather ?? todayWeather
    }
    
    var body: some View {
        GeometryReader { geometry in
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading weather data...")
                        .scaleEffect(1.2)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else if let errorMessage = errorMessage {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.orange)
                    Text("Unable to Load Weather")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(errorMessage)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Try Again") {
                        Task {
                            await loadWeather()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else if weatherData.isEmpty {
                VStack {
                    Spacer()
                    Text("No weather data available")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
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
                                    DayForecastTile(weather: day, isSelected: displayedWeather?.id == day.id)
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
                    if let weather = displayedWeather {
                        ScrollView {
                            DetailView(weather: weather)
                                .padding()
                        }
                        .frame(height: geometry.size.height * 2 / 3)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await loadWeather()
        }
    }
    
    private func loadWeather() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await WeatherService.shared.fetchWeather()
            weatherData = data
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    ContentView()
}
