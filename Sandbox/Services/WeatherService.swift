//
//  WeatherService.swift
//  Sandbox
//
//  Created by Kevin Tatooles on 12/16/25.
//

import Foundation

// MARK: - Configuration

struct WeatherConfig {
    static let defaultLatitude = 43.07   // Madison
    static let defaultLongitude = -89.4
}

// MARK: - API Response Models

struct NWSPointsResponse: Codable {
    let properties: NWSPointsProperties
}

struct NWSPointsProperties: Codable {
    let forecast: String
}

struct NWSForecastResponse: Codable {
    let properties: NWSForecastProperties
}

struct NWSForecastProperties: Codable {
    let periods: [NWSPeriod]
}

struct NWSPeriod: Codable {
    let number: Int
    let name: String
    let startTime: String
    let endTime: String
    let isDaytime: Bool
    let temperature: Int
    let temperatureUnit: String
    let shortForecast: String
    let detailedForecast: String
    let windSpeed: String
    let windDirection: String
    let probabilityOfPrecipitation: NWSValue?
    let relativeHumidity: NWSValue?
}

struct NWSValue: Codable {
    let value: Int?
}

// MARK: - Weather Service

enum WeatherError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noData
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noData:
            return "No weather data available"
        case .apiError(let message):
            return "API error: \(message)"
        }
    }
}

class WeatherService {
    static let shared = WeatherService()
    
    private init() {}
    
    func fetchWeather(latitude: Double = WeatherConfig.defaultLatitude,
                     longitude: Double = WeatherConfig.defaultLongitude) async throws -> [WeatherData] {
        // Step 1: Get the forecast URL from the points endpoint
        let forecastURL = try await getForecastURL(latitude: latitude, longitude: longitude)
        
        // Step 2: Fetch the actual forecast data
        let periods = try await fetchForecastPeriods(from: forecastURL)
        
        // Step 3: Transform NWS periods into WeatherData
        let weatherData = transformPeriodsToWeatherData(periods)
        
        return weatherData
    }
    
    private func getForecastURL(latitude: Double, longitude: Double) async throws -> String {
        let pointsURLString = "https://api.weather.gov/points/\(latitude),\(longitude)"
        
        guard let url = URL(string: pointsURLString) else {
            throw WeatherError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("WeatherApp/1.0 (contact@example.com)", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherError.noData
            }
            
            guard httpResponse.statusCode == 200 else {
                throw WeatherError.apiError("HTTP \(httpResponse.statusCode)")
            }
            
            let pointsResponse = try JSONDecoder().decode(NWSPointsResponse.self, from: data)
            return pointsResponse.properties.forecast
            
        } catch let error as DecodingError {
            throw WeatherError.decodingError(error)
        } catch let error as WeatherError {
            throw error
        } catch {
            throw WeatherError.networkError(error)
        }
    }
    
    private func fetchForecastPeriods(from urlString: String) async throws -> [NWSPeriod] {
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("WeatherApp/1.0 (contact@example.com)", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherError.noData
            }
            
            guard httpResponse.statusCode == 200 else {
                throw WeatherError.apiError("HTTP \(httpResponse.statusCode)")
            }
            
            let forecastResponse = try JSONDecoder().decode(NWSForecastResponse.self, from: data)
            return forecastResponse.properties.periods
            
        } catch let error as DecodingError {
            throw WeatherError.decodingError(error)
        } catch let error as WeatherError {
            throw error
        } catch {
            throw WeatherError.networkError(error)
        }
    }
    
    private func transformPeriodsToWeatherData(_ periods: [NWSPeriod]) -> [WeatherData] {
        var weatherDataArray: [WeatherData] = []
        let calendar = Calendar.current
        
        // Group periods by day
        var i = 0
        while i < periods.count && weatherDataArray.count < 10 {
            let period = periods[i]
            
            // Parse the start time
            guard let date = parseISO8601Date(period.startTime) else {
                i += 1
                continue
            }
            
            let dayName = getDayName(from: date)
            
            // Get high and low temps
            var highTemp: Int
            var lowTemp: Int
            var precipChance: Int = 0
            var humidity: Int = 50 // Default
            var windSpeed: Int = 0
            
            if period.isDaytime {
                // This is a daytime period - use this date for the forecast
                highTemp = period.temperature
                precipChance = period.probabilityOfPrecipitation?.value ?? 0
                humidity = period.relativeHumidity?.value ?? 50
                windSpeed = parseWindSpeed(period.windSpeed)
                
                // Look for the next period (night) to get low temp
                if i + 1 < periods.count && !periods[i + 1].isDaytime {
                    lowTemp = periods[i + 1].temperature
                    // Use max precipitation chance
                    let nightPrecip = periods[i + 1].probabilityOfPrecipitation?.value ?? 0
                    precipChance = max(precipChance, nightPrecip)
                    i += 2 // Skip both day and night
                } else {
                    lowTemp = highTemp - 15 // Estimate
                    i += 1
                }
            } else {
                // This is a nighttime period (e.g., "Tonight")
                // We need to pair it with the NEXT day period and use that day's date
                lowTemp = period.temperature
                precipChance = period.probabilityOfPrecipitation?.value ?? 0
                humidity = period.relativeHumidity?.value ?? 50
                windSpeed = parseWindSpeed(period.windSpeed)
                
                // Look ahead for next day to get high and the correct date
                if i + 1 < periods.count && periods[i + 1].isDaytime {
                    let nextDayPeriod = periods[i + 1]
                    // Use the NEXT day's date, not tonight's date
                    guard let nextDayDate = parseISO8601Date(nextDayPeriod.startTime) else {
                        i += 1
                        continue
                    }
                    // Update date to the next day
                    let dayName = getDayName(from: nextDayDate)
                    
                    highTemp = nextDayPeriod.temperature
                    let dayPrecip = nextDayPeriod.probabilityOfPrecipitation?.value ?? 0
                    precipChance = max(precipChance, dayPrecip)
                    
                    // Create the weather data with the NEXT day's date
                    let weatherData = WeatherData(
                        date: nextDayDate,
                        dayOfWeek: dayName,
                        highTemp: highTemp,
                        lowTemp: lowTemp,
                        precipitationChance: precipChance,
                        sunriseTime: "6:30 AM",
                        sunsetTime: "5:45 PM",
                        windchill: nil,
                        windSpeed: windSpeed,
                        humidity: humidity,
                        airPressure: 1015.0,
                        averageHigh: 70,
                        averageLow: 52
                    )
                    weatherDataArray.append(weatherData)
                    i += 2
                    continue // Skip the normal WeatherData creation below
                } else {
                    highTemp = lowTemp + 15 // Estimate
                    i += 1
                }
            }
            
            let weatherData = WeatherData(
                date: date,
                dayOfWeek: dayName,
                highTemp: highTemp,
                lowTemp: lowTemp,
                precipitationChance: precipChance,
                sunriseTime: "6:30 AM", // Default - not available from API
                sunsetTime: "5:45 PM",  // Default - not available from API
                windchill: nil,         // Not available from basic forecast
                windSpeed: windSpeed,
                humidity: humidity,
                airPressure: 1015.0,    // Default - not available from API
                averageHigh: 70,        // Default - not available from API
                averageLow: 52          // Default - not available from API
            )
            
            weatherDataArray.append(weatherData)
        }
        
        return weatherDataArray
    }
    
    private func parseISO8601Date(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
    
    private func getDayName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func parseWindSpeed(_ windSpeedString: String) -> Int {
        // Wind speed comes as "10 mph" or "5 to 10 mph"
        let components = windSpeedString.components(separatedBy: " ")
        if let firstNumber = components.first, let speed = Int(firstNumber) {
            return speed
        }
        // Try to find "to X mph" pattern
        if let toIndex = components.firstIndex(of: "to"),
           toIndex + 1 < components.count,
           let speed = Int(components[toIndex + 1]) {
            return speed
        }
        return 0
    }
}
