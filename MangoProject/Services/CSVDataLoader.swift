import Foundation
import CoreLocation
import MapKit

struct CSVPlace {
    let name: String
    let type: String
    let businessName: String
    let certificateNumber: String
    let certificateIssueDate: String
    let totalProducts: Int
    let latitude: Double
    let longitude: Double
    let halalFound: Bool
}

class CSVDataLoader {
    static func loadAll() -> [CSVPlace] {
        var places: [CSVPlace] = []
        
        let paths = [
            "/Users/sebastiandarren/Downloads/Mango/MangoProject/MangoProject/Dataset/Dataset - Maggiore.csv",
            "/Users/sebastiandarren/Downloads/Mango/MangoProject/MangoProject/Dataset/Dataset - The Breeze.csv"
        ]
        
        for path in paths {
            if let content = try? String(contentsOfFile: path, encoding: .utf8) {
                places.append(contentsOf: parseCSV(content))
            } else {
                // Fallback to Bundle resource loading in case of sandboxed run in Simulator/Device
                let filename = (path as NSString).lastPathComponent
                let nameWithoutExtension = (filename as NSString).deletingPathExtension
                if let bundleURL = Bundle.main.url(forResource: nameWithoutExtension, withExtension: "csv"),
                   let content = try? String(contentsOf: bundleURL, encoding: .utf8) {
                    places.append(contentsOf: parseCSV(content))
                }
            }
        }
        
        return places
    }
    
    private static func parseCSV(_ content: String) -> [CSVPlace] {
        var places: [CSVPlace] = []
        let lines = content.components(separatedBy: .newlines)
        
        var headerIndices: [String: Int] = [:]
        var foundHeader = false
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }
            
            let columns = parseCSVLine(trimmed)
            
            if !foundHeader {
                // Check if this line is the header
                let lowercasedColumns = columns.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
                if lowercasedColumns.contains(where: { $0.contains("halal_found") }) &&
                   lowercasedColumns.contains(where: { $0.contains("restaurant_name") }) {
                    for (index, col) in columns.enumerated() {
                        let cleanName = col.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                        headerIndices[cleanName] = index
                    }
                    foundHeader = true
                }
                continue
            }
            
            // Extract indices
            guard let halalIndex = headerIndices["halal_found"],
                  let nameIndex = headerIndices["restaurant_name"] else {
                continue
            }
            
            let halalStr = columns.indices.contains(halalIndex) ? columns[halalIndex] : ""
            let nameStr = columns.indices.contains(nameIndex) ? columns[nameIndex] : ""
            
            if nameStr.isEmpty { continue }
            
            let businessNameIndex = headerIndices["business_name"]
            let businessName = businessNameIndex != nil && columns.indices.contains(businessNameIndex!) ? columns[businessNameIndex!] : ""
            
            let certNumIndex = headerIndices["certificate_number"]
            let certNum = certNumIndex != nil && columns.indices.contains(certNumIndex!) ? columns[certNumIndex!] : ""
            
            let certDateIndex = headerIndices["certificate_issue_date"]
            let certDate = certDateIndex != nil && columns.indices.contains(certDateIndex!) ? columns[certDateIndex!] : ""
            
            let totalProductsIndex = headerIndices["total_products"]
            let totalProductsStr = totalProductsIndex != nil && columns.indices.contains(totalProductsIndex!) ? columns[totalProductsIndex!] : ""
            let totalProducts = Int(totalProductsStr) ?? 0
            
            // Check for "type" or "type "
            var typeStr = ""
            if let typeIndex = headerIndices["type"] ?? headerIndices["type "] {
                if columns.indices.contains(typeIndex) {
                    typeStr = columns[typeIndex]
                }
            }
            
            let latIndex = headerIndices["latitude"]
            let latStr = latIndex != nil && columns.indices.contains(latIndex!) ? columns[latIndex!] : ""
            let lat = Double(latStr) ?? 0.0
            
            let lonIndex = headerIndices["longitude"]
            let lonStr = lonIndex != nil && columns.indices.contains(lonIndex!) ? columns[lonIndex!] : ""
            let lon = Double(lonStr) ?? 0.0
            
            let halalFound = halalStr.lowercased() == "true"
            
            let place = CSVPlace(
                name: nameStr,
                type: typeStr,
                businessName: businessName,
                certificateNumber: certNum,
                certificateIssueDate: certDate,
                totalProducts: totalProducts,
                latitude: lat,
                longitude: lon,
                halalFound: halalFound
            )
            places.append(place)
        }
        
        return places
    }
    
    private static func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        var characters = Array(line)
        var i = 0
        while i < characters.count {
            let char = characters[i]
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                result.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
                current = ""
            } else {
                current.append(char)
            }
            i += 1
        }
        result.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
        return result
    }
}
