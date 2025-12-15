//
//  TodayDetailView.swift
//  Sandbox
//
//  Created by Kevin Tatooles on 12/14/25.
//

import SwiftUI

struct DetailView: View {
    let weather: WeatherData
    
    var iconName: String {
        weather.isRainy ? "cloud.rain.fill" : "sun.max.fill"
    }
    
    var iconColor: Color {
        weather.isRainy ? .blue : .yellow
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(weather.dayOfWeek)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(weather.formattedDate)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: iconName)
                    .font(.system(size: 50))
                    .foregroundStyle(iconColor)
            }
            .padding(.bottom, 8)
            
            // Temperature Row
            HStack(spacing: 24) {
                TemperatureCard(title: "High", value: "\(weather.highTemp)°F", icon: "thermometer.sun.fill", color: .red)
                TemperatureCard(title: "Low", value: "\(weather.lowTemp)°F", icon: "thermometer.snowflake", color: .blue)
            }
            
            // Average Temperature Row
            HStack(spacing: 24) {
                TemperatureCard(title: "Avg High", value: "\(weather.averageHigh)°F", icon: "chart.line.uptrend.xyaxis", color: .orange)
                TemperatureCard(title: "Avg Low", value: "\(weather.averageLow)°F", icon: "chart.line.downtrend.xyaxis", color: .cyan)
            }
            
            Divider()
            
            // Detailed Metrics Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                DetailMetricCard(title: "Precipitation", value: "\(weather.precipitationChance)%", icon: "drop.fill", color: .blue)
                DetailMetricCard(title: "Windchill", value: weather.windchill != nil ? "\(weather.windchill!)°F" : "N/A", icon: "wind.snow", color: .purple)
                DetailMetricCard(title: "Wind", value: "\(weather.windSpeed) mph", icon: "wind", color: .teal)
                DetailMetricCard(title: "Humidity", value: "\(weather.humidity)%", icon: "humidity.fill", color: .mint)
                DetailMetricCard(title: "Pressure", value: String(format: "%.1f mb", weather.airPressure), icon: "gauge.with.dots.needle.bottom.50percent", color: .indigo)
            }
            
            Divider()
            
            // Sunrise/Sunset Row
            HStack(spacing: 24) {
                SunTimeCard(title: "Sunrise", time: weather.sunriseTime, icon: "sunrise.fill")
                SunTimeCard(title: "Sunset", time: weather.sunsetTime, icon: "sunset.fill")
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Supporting Views

struct TemperatureCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

struct DetailMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
        )
    }
}

struct SunTimeCard: View {
    let title: String
    let time: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.orange)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(time)
                    .font(.title3)
                    .fontWeight(.medium)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

#Preview {
    DetailView(weather: generateDummyWeatherData().first!)
}
