//
//  RandomGeneratorFromTableSet.swift
//  CSC690_SwiftUI
//
//  Created by Cameron Robinson on 11/23/21.
//

import Foundation

// MARK: - String capitalization helper
// Extends strings to allow for capitalizing only the first letter of the string leaving the rest unchanged.
extension StringProtocol {
    var sentenceCapitalized: String { prefix(1).capitalized + dropFirst() }
}

// MARK: - Regex helper
// Regex String index helpers is defined by the potocol and then extended to provide the implementation. Discovered this
// trick through researching on the internet in order to effectively have the structs "inherit" function implementation
// like a subclass would. Makes the definition of these functions more clean than repeating the code in mutliple separate
// structs.
protocol RegexStringIndiciesHelpers {
    func getKeyFromRegex(originalString: String, range: NSRange) -> String
    func getIndexRange(string: String, range: NSRange) -> Range<String.Index>
    func getIndexRange(string: String, lowerBound: Int, upperBoundOffset: Int) -> Range<String.Index>
    func getSubStringRange(string: String, range: NSRange) -> String
    func getSubStringRange(string: String, lowerBound: Int, upperBoundOffset: Int) -> String
}
extension RegexStringIndiciesHelpers {
    
    func getKeyFromRegex(originalString: String, range: NSRange) -> String {
        
        // Get the Range<String.Index> from the string based on the passed NSRange and then get the substring.
        let indexRange = getIndexRange(string: originalString, range: range);
        let subString = String(originalString[indexRange]);
        
        // Return result from helper method to removeg the brackets from the key string EG: "[[key]]" -> "key"
        return getSubStringRange(string: subString, lowerBound: 2, upperBoundOffset: -2);
    }
    
    func getIndexRange(string: String, range: NSRange) -> Range<String.Index> {
        
        // Get the upper and lower bounds of the range using the NSRange values to offset the string start index
        let lowerIndex = string.index(string.startIndex, offsetBy: range.lowerBound)
        let upperIndex = string.index(string.startIndex, offsetBy: range.upperBound)
        
        // Return the new range
        return lowerIndex..<upperIndex
    }

    func getIndexRange(string: String, lowerBound: Int, upperBoundOffset: Int) -> Range<String.Index> {
        
        // Get the upper and lower bounds of the range, using the offset from the start of the string for the lower bound
        // and then the offset from the end of the string for the upper bound.
        let lowerIndex = string.index(string.startIndex, offsetBy: lowerBound)
        let upperIndex = string.index(string.startIndex, offsetBy: string.count + upperBoundOffset)
        
        // Return the new range.
        return lowerIndex..<upperIndex
    }

    func getSubStringRange(string: String, range: NSRange) -> String {
        let indexRange = getIndexRange(string: string, range: range)
        return String(string[indexRange])
    }
    
    func getSubStringRange(string: String, lowerBound: Int, upperBoundOffset: Int) -> String {
        let indexRange = getIndexRange(string: string, lowerBound: lowerBound, upperBoundOffset: upperBoundOffset)
        return String(string[indexRange])
    }
}

// MARK: - Generator Items
// This struct is used by the main generator and the table items in order to more easily keep track of what needs generation and what is just a static part of the final string.
// The generator will hold an array of the GeneratorItem and switch over the type to determine what to do with the data
enum GeneratorItemType: Int, Codable {
    case staticString = 1
    case tableName = 2
}
struct GeneratorItem: Codable {
    
    public let itemType: GeneratorItemType
    private let _itemStrings: [String]
    public var itemString: String {
        get {
            if _itemStrings.count == 1 {
                return _itemStrings[0]
            }
            else {
                return _itemStrings.shuffled()[0]
            }
        }
    }
    
    init(itemString: String, type: GeneratorItemType) {
            
        self._itemStrings = itemString.components(separatedBy: "|")
        self.itemType = type
    }
}

// MARK: - Generator Table Items
// These structs are used when generating a random item from the data in the generator. There are eiter static items which return just a string. Or recursive
// items which have their own required random tables within them. When the generator rolls on the table it switches over the implementing structure type
// and if a recursive item is selected will loop through all of the required table names and recursively attempt to fill the required spaces.
enum GeneratorTableType: Int, Codable {
    case staticItem
    case recursiveItem
}
struct GeneratorTableItem: RegexStringIndiciesHelpers, Codable {
    
    public let staticString: String
    public private(set) var recursiveItems: [GeneratorItem] = []
    
    let type: GeneratorTableType
    init(string: String, type :GeneratorTableType) {
        self.type = type
        
        if self.type == .staticItem {
            self.staticString = string
        }
        else { // self.type == .recursiveItem
            
            self.staticString = ""
            initRecursive(string: string)
        }
    }
    
    mutating func initRecursive(string: String) {
        
        do {
            let regex = try NSRegularExpression(pattern: "\\[\\[[a-zA-Z0-9_-|]*\\]\\]", options: [])
            
            // Create a string that will be updated for the parsing process. Until we reach the end of the string look for the next
            // regex match, if there are no more mathces breack the loop.
            var workingString = string
            while true {
                
                if let match = regex.firstMatch(in: workingString, options: [], range: NSMakeRange(0, workingString.utf16.count)) {

                    // If the match is greater than index 0 we save the range index 0 to start of the match as a static string in the
                    // array this saves things such as "[[table1]] is used by [[table2]]" where " is used by " will be stored as a static
                    // string and [[table1]] and [[table2]] will be stored as dynamic table name items.
                    if match.range.lowerBound > 0 {
                        
                        let itemString = self.getSubStringRange(string: workingString, range: NSMakeRange(0, match.range.lowerBound))
                        
                        let genItem = GeneratorItem(itemString: itemString, type: .staticString)
                        self.recursiveItems.append( genItem );
                    }
                    
                    // We have a match so get the key from the match range. Using the same example above this would extract "table1" and "table2" as the key strings
                    let key = getKeyFromRegex(originalString: workingString, range: match.range)

                    // Create the generator item for the key and append it to the list.
                    let keyItem = GeneratorItem(itemString: key, type: .tableName)
                    self.recursiveItems.append( keyItem )
                    
                    // Update our working string to everything after our current match. This updates our string from "[[table1]] is used by [[table2]]" to " is used by [[table2]]"
                    // on the first pass.
                    workingString = getSubStringRange(string: workingString, lowerBound: match.range.upperBound, upperBoundOffset: 0)
                }
                else {
                    break
                }
            }
            
            if workingString.count > 0 {
                let genItem = GeneratorItem(itemString: workingString, type: .staticString)
                self.recursiveItems.append( genItem );
            }
        } catch {
            print("Error Parsing Regex")
        }
    }
    
    func getWeight() -> Int {
        return 1 // TODO: Customize this to have the weight of the range
    }
    
    func getRange() -> NSRange {
        return NSMakeRange(1, 0) //TODO: Set this to something customizable for things like a roll of a D20 17-20
    }
}

// MARK: - Generator Table Implementation
// This struct holds the data for each table used in the generation. Each table holds an array of Generator Table Items
// those items can either be a static item which contains just a string or a recursive item which contains static strings and references to other table names
// which need to be recursivly generated through.
struct GeneratorTable: Codable {
    
    // List of table items, effectively the rows of the table.
    private var items: [GeneratorTableItem] = []
    
    // Total weight of the items. This value is used when the weighted random option is selected, shuffling the items and picking a random item as opposed to the roll system.
    private var totalWeight = 0
    
    init(itemList: [String]) {

        do {
            let regex = try NSRegularExpression(pattern: "\\[\\[[a-zA-Z0-9_-|]*\\]\\]", options: [])
            
            for item in itemList {
            
                // If the item has a single match in its string we create a recursive item. Otherwise we create a static
                // item, appending either item to the list.
                if let _ = regex.firstMatch(in: item, options: [], range: NSMakeRange(0, item.utf16.count)) {
                    self.items.append(GeneratorTableItem(string: item, type: .recursiveItem))
                }
                else {
                    self.items.append(GeneratorTableItem(string: item, type: .staticItem))
                }
                
                // TODO: Update this to use dynamic weighting.
                self.totalWeight += 1
            }
        } catch {}
    }
    
    func getWeightedRandom() -> GeneratorTableItem? {
        
        // Set up our return value and generate a random value within the total weight.
        var returnItem: GeneratorTableItem?
        var randVal = Int.random(in: 1...self.totalWeight)
        
        // Shuffle the items and loop through the list
        for item in items.shuffled() {

            // Get the weight from the table item and check if the weight is a valid match
            // if the weight is too small we subtract the weight and loop, otherwise
            // we setup the return item and break the loop
            let weight = item.getWeight()
            if randVal > weight {
                
                randVal -= weight
            }
            else {
                
                returnItem = item
                break
            }
        }
        
        return returnItem
    }
//
//    func getRolledItem(modifier: Int = 0) -> GeneratorTableItem? {
//
//        var retVal: GeneratorTableItem? = nil
//        let randVal = Int.random(in: 1...self.totalWeight) + modifier
//
//        // If we're below or above the limits, return the limit case.
//        if randVal >= self.totalWeight {
//            retVal = items[items.count - 1]
//        }
//        else if randVal <= 1 {
//            retVal = items[0]
//        }
//        else {
//
//            for item in self.items {
//
//                if item.getRange().contains(randVal) {
//                    retVal = item
//                    break
//                }
//            }
//        }
//
//        return retVal
//    }
}

enum GenerationType {
    case weightedRandom
    case modifiedDieRoll
}

struct RandomGeneratorFromTableSet: RegexStringIndiciesHelpers, Codable {
    
    private var stringItems: [GeneratorItem] = []
    private var keyIndicies: [String : Int] = [:]
    private let tables: [String : GeneratorTable]
    
    private var currentGenerationList: [String] = []

    public private(set) var currentGeneratedString: String = ""
    public let generatorName: String
    
    init(baseString: String, tables: [String : GeneratorTable], generatorName: String) {

        self.tables = tables
        self.generatorName = generatorName
        
        do {
            let regex = try NSRegularExpression(pattern: "\\[\\[[a-zA-Z0-9_-|]*\\]\\]", options: [])
            
            // Create a string that will be updated for the parsing process. Until we reach the end of the string look for the next
            // regex match, if there are no more mathces breack the loop.
            var workingString = baseString
            var index = 0
            while true {
                
                if let match = regex.firstMatch(in: workingString, options: [], range: NSMakeRange(0, workingString.utf16.count)) {

                    // If the match is greater than index 0 we save the range index 0 to start of the match as a static string in the
                    // array this saves things such as "[[table1]] is used by [[table2]]" where " is used by " will be stored as a static
                    // string and [[table1]] and [[table2]] will be stored as dynamic table name items.
                    if match.range.lowerBound > 0 {
                                                
                        let itemString = self.getSubStringRange(string: workingString, range: NSMakeRange(0, match.range.lowerBound))
                        
                        let genItem = GeneratorItem(itemString: itemString, type: .staticString)
                        
                        self.stringItems.append( genItem );
                        index += 1
                    }
                    
                    // We have a match so get the key from the match range. Using the same example above this would extract "table1" and "table2" as the key strings
                    let key = getKeyFromRegex(originalString: workingString, range: match.range)

                    // Update the index in the array for the key, allows for quicker access of the data in the array
                    // rather than looping over array and also know if item in array by key in dictionary
                    self.keyIndicies[key] = index
                    index += 1

                    // Create the generator item for the key and append it to the list.
                    let keyItem = GeneratorItem(itemString: key, type: .tableName)
                    self.stringItems.append( keyItem )
                    
                    // Update our working string to everything after our current match. This updates our string from "[[table1]] is used by [[table2]]" to " is used by [[table2]]"
                    // on the first pass.
                    workingString = getSubStringRange(string: workingString, lowerBound: match.range.upperBound, upperBoundOffset: 0)
                }
                else {
                    break
                }
            }

            if workingString.count > 0 {
                let genItem = GeneratorItem(itemString: workingString, type: .staticString)
                self.stringItems.append( genItem );
            }
        } catch {
            print("Error Parsing Regex")
        }
    }
    
    /// Generates a whole new generated string, using the data within the RandomGenerator structure.
    /// - Returns: The newly generated string
    mutating func generate() -> String {
        
        self.currentGenerationList = self.buildGeneratedStringList(items: stringItems)
        
        self.currentGeneratedString = self.buildGeneratedString()
        return self.currentGeneratedString
    }
    
    /// Regenerate the value for the key passed. Does not affect any of the other items already generated. After getting the required index and key
    /// from the structures, gets the required table and passes to get random from table. After getting the new value updates the item in the array
    /// to hold the new value and re-builds the current generated string, effectively only updating the single required field.
    /// - Parameter key: the key in the "sentance" which needs to be replaced.
    /// - Returns: The newly updated generated string.
    mutating func reGenerateKey(key: String) -> String {
        
        if let keyIndex = self.keyIndicies[key] {
            
            let getKey = self.stringItems[keyIndex].itemString
            
            if let table = self.tables[getKey]{
             
                let str = self.getRandomFromTable(table: table)
                self.currentGenerationList[keyIndex] = str
            }
        }
        
        self.currentGeneratedString = self.buildGeneratedString()
        return self.currentGeneratedString
    }
    
    /// Builds a string by concatinating a list of strings down into a single string.
    /// - Returns: the final string created by concatingating all strings in order.
    private func buildGeneratedString(stringList: [String]? = nil) -> String {
        
        let list: [String] = stringList ?? self.currentGenerationList
        
        var generatedString = ""
        for str in list {
            generatedString = generatedString.appending(str)
        }
        
        return generatedString.lowercased().sentenceCapitalized
    }
    
    /// Gets a random value from the passed table. Function gets a value from the table and then checks if the value is a static type or recurstive type.
    /// if recursive the function passes the list of strings in the recursive structure into the buldGeneratedStringList to allow that function to perform the
    /// actual recursion calls. Once the list of strings is retrieved it is passed to the build generated string function to flatten the array to a single string to be returned
    /// - Parameter table: the generator table object from which a random value will be selected.
    /// - Returns: the random string selected from the table with any recursive tables also iterated over.
    private func getRandomFromTable(table: GeneratorTable) -> String {
        
        let tableItem = table.getWeightedRandom()
        
        var retStr = ""
        if let item = tableItem,
           item.type == .staticItem {
            
            retStr = item.staticString
        }
        else if let item = tableItem,
                item.type == .recursiveItem {
            
            let strList = buildGeneratedStringList(items: item.recursiveItems)
            retStr = self.buildGeneratedString(stringList: strList)
        }
        
        return retStr
    }
    
    /// Takes the list of generation items passed and returns a array of generated strings. Each generator item is checked if it is a static string or a dynamic string to
    /// determine what to append to the returned array.
    /// - Parameter items: The list of generator items to iterate through
    /// - Returns: an array of strings created from the generator items.
    private func buildGeneratedStringList(items: [GeneratorItem]) -> [String] {
        
        var generationList: [String] = []
        for item in items {
            
            if item.itemType == .tableName {
                if let table = self.tables[item.itemString]{
                 
                    let str = self.getRandomFromTable(table: table)
                    generationList.append(str)
                }
            }
            else if item.itemType == .staticString {

                generationList.append(item.itemString)
            }
        }
        
        return generationList
    }
}
