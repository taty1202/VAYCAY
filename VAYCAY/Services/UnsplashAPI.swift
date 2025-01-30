//
//  UnsplashAPI.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/21/25.
//

import Foundation

class UnsplashAPI {
    private let unsplashApiKey: String

    init() {
        // Fetch API Key from Info.plist
        if let key = Bundle.main.object(forInfoDictionaryKey: "UnsplashAPIKey") as? String, !key.isEmpty {
            self.unsplashApiKey = key
        } else {
            fatalError("❌ Unsplash API Key is missing. Ensure it's set in the Info.plist and User-Defined Settings.")
        }
    }

    private let baseUrl = "https://api.unsplash.com/search/photos"

    func fetchImages(for keyword: String, completion: @escaping ([String]?) -> Void) {
        let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "travel"
        guard let url = URL(string: "\(baseUrl)?query=\(query)&client_id=\(unsplashApiKey)&per_page=10&content_filter=high") else {
            print("❌ Invalid URL")
            completion(nil)
            return
        }

        // Print the final URL to verify correctness
        print("🚀 Fetching Unsplash Images: \(url.absoluteString)")

        // Configure session with timeout intervals
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30  // Timeout for request
        sessionConfig.timeoutIntervalForResource = 60 // Timeout for entire resource load
        let session = URLSession(configuration: sessionConfig)

        session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching images: \(error.localizedDescription)")
                completion(nil)
                return
            }

            // Handle rate limit logging
            if let httpResponse = response as? HTTPURLResponse {
                print("ℹ️ Remaining Requests: \(httpResponse.allHeaderFields["X-Ratelimit-Remaining"] ?? "N/A")")
            }

            guard let data = data else {
                print("❌ No data received")
                completion(nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(UnsplashSearchResponse.self, from: data)
                let urls = result.results.map { $0.urls.regular }
                completion(urls)
            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}


// Models
struct UnsplashURLs: Decodable {
    let regular: String
    let small: String
    let thumb: String
}

struct UnsplashImage: Decodable {
    let id: String
    let urls: UnsplashURLs
    let alt_description: String?
}

struct UnsplashSearchResponse: Decodable {
    let total: Int
    let total_pages: Int
    let results: [UnsplashImage]
}
