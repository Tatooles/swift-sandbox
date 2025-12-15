//
//  DayForecastTile.swift
//  Sandbox
//
//  Created by Kevin Tatooles on 12/14/25.
//

import SwiftUI

struct DayForecastTile: View {
    let weather: WeatherData
    
    var iconName: String {
        weather.isRainy ? "cloud.rain.fill" : "sun.max.fill"
    }
    
    var iconColor: Color {
        weather.isRainy ? .blue : .yellow
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Day and Date
            Text(weather.dayOfWeek)
                .font(.headline)
                .fontWeight(.bold)
            Text(weather.formattedDate)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // Weather Icon
            Image(systemName: iconName)
                .font(.title)
                .foregroundStyle(iconColor)
                .frame(height: 30)
            
            // Temperatures
            HStack(spacing: 4) {
                Text("\(weather.highTemp)°")
                    .fontWeight(.semibold)
                Text("\(weather.lowTemp)°")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
            
            // Precipitation
            HStack(spacing: 2) {
                Image(systemName: "drop.fill")
                    .font(.caption2)
                    .foregroundStyle(.blue)
                Text("\(weather.precipitationChance)%")
                    .font(.caption)
            }
            
            // Sunrise/Sunset
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    Image(systemName: "sunrise.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text(weather.sunriseTime)
                        .font(.caption2)
                }
                HStack(spacing: 2) {
                    Image(systemName: "sunset.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text(weather.sunsetTime)
                        .font(.caption2)
                }
            }
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    DayForecastTile(weather: generateDummyWeatherData().first!)
}
