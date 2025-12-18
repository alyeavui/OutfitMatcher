import Foundation

nonisolated
struct OutfitRecommendation: Codable {
    let hatID: String?
    let shirtID: String?
    let pantsID: String?
    let shoesID: String?
    let explanation: String
}

enum AIServiceError: Error {
    case invalidURL
    case noData
    case invalidResponse
    case decodingError(String)
    case networkError(Error)
    case apiError(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "Invalid API URL"
        case .noData: return "No data received from server"
        case .invalidResponse: return "Invalid response format"
        case .decodingError(let msg): return "Decoding error: \(msg)"
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .apiError(let msg): return "API error: \(msg)"
        }
    }
}

class AIService {
    static let shared = AIService()
    private let apiKey = "AIzaSyCgZNcuIUXsW6HzrlHzlCgczUj3DISMQHE"
    private let apiURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    
    private init() {}
    
    func getOutfitRecommendation(clothingItems: [String: [[String: String]]], completion: @escaping (Result<OutfitRecommendation, AIServiceError>) -> Void) {
        guard var components = URLComponents(string: apiURL) else {
            completion(.failure(.invalidURL))
            return
        }
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = createPrompt(from: clothingItems)
        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "responseMimeType": "application/json"
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(.networkError(error)))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                completion(.failure(.noData))
                return
            }
            
            if httpResponse.statusCode != 200 {
                let errorMsg = String(data: data, encoding: .utf8) ?? "HTTP \(httpResponse.statusCode)"
                print("❌ Gemini Error Response: \(errorMsg)")
                completion(.failure(.apiError(errorMsg)))
                return
            }
            
            do {
                let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
                if let jsonText = geminiResponse.candidates.first?.content.parts.first?.text {
                    let recommendation = try JSONDecoder().decode(OutfitRecommendation.self, from: jsonText.data(using: .utf8)!)
                    completion(.success(recommendation))
                } else {
                    completion(.failure(.invalidResponse))
                }
            } catch {
                completion(.failure(.decodingError(error.localizedDescription)))
            }
        }.resume()
    }
    
    private func createPrompt(from items: [String: [[String: String]]]) -> String {
        return """
        Return ONLY JSON. Items:
        Hats: \(items["hats"] ?? [])
        Shirts: \(items["shirts"] ?? [])
        Pants: \(items["pants"] ?? [])
        Shoes: \(items["shoes"] ?? [])
        
        Structure: {"hatID": "ID or null", "shirtID": "ID", "pantsID": "ID", "shoesID": "ID", "explanation": "text"}
        """
    }
}
nonisolated
struct GeminiResponse: Codable {
    let candidates: [Candidate]
    struct Candidate: Codable {
        let content: Content
        struct Content: Codable {
            let parts: [Part]
            struct Part: Codable {
                let text: String?
            }
        }
    }
}
