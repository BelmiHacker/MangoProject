//
//  FoodDNAAnalysisService.swift
//  MangoProject
//
//  Created by Muthiara Putri Aliyu on 11/07/26.
//

//
//  Uploads a menu photo to the Food DNA analysis backend and returns
//  the parsed result. Throws on any failure — callers (ViewModel) are
//  responsible for surfacing errors to the user. Never silently
//  substitutes fake/demo data on failure.
//

import Foundation
import UIKit

enum FoodDNAAnalysisError: Error {
    case invalidURL
    case invalidImageData
    case serverError(statusCode: Int)
    case decodingFailed
}

final class FoodDNAAnalysisService {
    /// ⚠️ Placeholder endpoint — this ngrok URL is temporary/dev-only and
    /// will not work outside the original developer's machine session.
    /// Replace with a real, stable backend URL before this ships.
    private let endpoint = "https://repressed-conical-florist.ngrok-free.dev/analyze-menu"

    func analyzeMenu(image: UIImage) async throws -> FoodDNAAnalysisResult {
        guard let url = URL(string: endpoint) else {
            throw FoodDNAAnalysisError.invalidURL
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw FoodDNAAnalysisError.invalidImageData
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"menu.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300
        config.timeoutIntervalForResource = 300
        let session = URLSession(configuration: config)

        let (responseData, response) = try await session.upload(for: request, from: body)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw FoodDNAAnalysisError.serverError(statusCode: statusCode)
        }

        do {
            return try JSONDecoder().decode(FoodDNAAnalysisResult.self, from: responseData)
        } catch {
            throw FoodDNAAnalysisError.decodingFailed
        }
    }
}
