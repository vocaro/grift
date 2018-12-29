import Foundation

class TypeNameExtractor {
  
    static func extractTypeNames(sourceKitTypeName: String) -> [String] {
        let typeName = sourceKitTypeName.replacingOccurrences(of: "@escaping", with: "")
        let delimiters = CharacterSet(charactersIn: ", <>->@?!()")
        var names = (typeName as NSString).components(separatedBy: delimiters)
        names = handleCollectionTypes(names)
        names = names.filter { !$0.isEmpty }
        return names
    }
    
    private static func handleCollectionTypes(_ oldNames: [String]) -> [String] {
        var newNames = [String]()
        oldNames.forEach { name in
            var name = name
            if name.hasPrefix("[") && name.hasSuffix(":") {
                newNames.append("Dictionary")
                name.removeFirst()
                name.removeLast()
            } else if name.hasPrefix("[") && name.hasSuffix("]") && name.contains(":") {
                newNames.append("Dictionary")
                let delimiters = CharacterSet(charactersIn: "[:]")
                (name as NSString).components(separatedBy: delimiters).forEach { name in
                    if !name.isEmpty {
                        newNames.append(name)
                    }
                }
                name = ""
            } else if let arrayType = matchGroup(pattern: "^\\[+(.*)\\]+$", in: name) {
                newNames.append("Array")
                name = arrayType
            } else if name.hasSuffix("]") {
                name.removeLast()
            } else if name.hasSuffix(":") {
                name = ""
            }
            newNames.append(name)
        }
        return newNames
    }
    
    private static func matchGroup(pattern: String, in text: String) -> String? {
        let regex = try! NSRegularExpression(pattern: pattern)
        
        let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        if let firstResult = results.first, firstResult.numberOfRanges == 2 {
            let range = firstResult.range(at: 1)
            let start = text.index(text.startIndex, offsetBy: range.location)
            let end = text.index(text.startIndex, offsetBy: range.length)
            return String(text[start...end])
        }
                
        return nil
    }
}
