//
//  MarkovChain.swift
//  CSC690_SwiftUI
//
//  A simple markov chain generator that will randomly create a new word based on the state table
//  generated by a list of words provided.
//
//  Created by Cameron Robinson on 11/10/21.
//

import Foundation

enum MarkovOrder {
    case first
    case second
}

/// Struct to contain the markov state tables and function calls in order to generate new words.
/// Implementes the codable protocol to allow for the state table to be loaded from json files in the project resources.
struct MarkovChain: Codable {
    
    private var generatorName = ""
    
    private var initialState: [String : Int] = [ : ]
    private var initialStateTotalWeight: Int = 0
    
    private var firstOrderTransitions: [String : [String : Int]] = [ : ]
    private var firstOrderTotalWeights: [String : Int] = [ : ]

    private var secondOrderTransitions: [String : [String : Int]] = [ : ]
    private var secondOrderTotalWeights: [String : Int] = [ : ]
    
    private var minLength: Int
    private var maxLength: Int
    private var lengthWeights: [Int : Int] = [ : ]
    private var lengthTotalWeight: Int = 0
    
    init(words: [String], generatorName: String) {
        
        self.generatorName = generatorName
        
        minLength = words[0].count
        maxLength = minLength
        
        for word in words {
            addWordToTransitionTable(word: word)
            
            let wordLength = word.count
            if wordLength > maxLength {
                maxLength = wordLength
            }
            if wordLength < minLength {
                minLength = wordLength
            }
            
            // Initialize and/or update the length weight. Then update total length
            if lengthWeights[wordLength] == nil {
                lengthWeights[wordLength] = 0
            }
            if let weight = lengthWeights[wordLength] {
                lengthWeights[wordLength] = weight + 1
            }
            lengthTotalWeight += 1
        }
    }
    
    public func getGeneratorName() -> String {
        return self.generatorName
    }
    
    
    /// Generates a weighted random value from the initial state table.
    /// - Returns: Returns a string containing the generated initial state.
    public func getInitialLetter() -> String {

        return getWeightedFromTable(table: initialState, totalWeight: initialStateTotalWeight)
    }
    
    /// Gets the next state based on the current state of the passed string
    /// - Parameters:
    ///   - currentString: The current state of the generator, in this case will be a name, used to parse the proper state table out of the set of states
    ///   - order: Order of generation, can either be first or second and determines how far back in the state to look, either the first or second index of the string
    /// - Returns: the next state found in the weighted table.
    public func getNext(currentString: String, order: MarkovOrder) -> String {
        
        if currentString.count > 2 && order == .second {
         
            let currentState = String(currentString.suffix(2))
            if let transitionDict = secondOrderTransitions[currentState],
               let totalWeight = secondOrderTotalWeights[currentState] {
                
                return getWeightedFromTable(table: transitionDict, totalWeight: totalWeight)
            }
        }
            
        let currentState = String(currentString.suffix(1))
        guard let transitionDict = firstOrderTransitions[currentState],
              let totalWeight = firstOrderTotalWeights[currentState] else {
            return "$"
        }
        
        return getWeightedFromTable(table: transitionDict, totalWeight: totalWeight)
    }
    
    /// Gets a weighted random item from the passed table. Uses the total weight to generate a value and then
    /// Loops thorugh the items until the weighted item is selected. This version selects a string.
    /// - Parameters:
    ///   - table: the table which to randomly select an item
    ///   - totalWeight: the total weight of the table
    /// - Returns: returns the string from the table.
    private func getWeightedFromTable(table: [String : Int], totalWeight: Int) -> String {
        
        var returnStr = ""
        
        // Generate a random value between 1 and the total weight, we will use this value
        // to select the item from the table.
        var randVal = Int.random(in: 1...totalWeight)
        
        // Shuffle the table and then loop through each item. If the weight of the item
        // is less than our random value we return that key, otherwise we subtract
        // the value and check the next item.
        for item in table.shuffled() {

            if randVal > item.value {
                
                randVal -= item.value
            }
            else {
                
                returnStr = item.key
                break
            }
        }
        
        return returnStr
    }
    
    /// Gets a weighted random item from the passed table. Uses the total weight to generate a value and then
    /// Loops thorugh the items until the weighted item is selected. This version selects an int, used to select the
    /// length of the generated word.
    /// - Parameters:
    ///   - table: the table which to randomly select an item
    ///   - totalWeight: the total weight of the table
    /// - Returns: returns the string from the table.
    private func getWeightedFromTable(table: [Int : Int], totalWeight: Int) -> Int {
        
        var returnVal = 0
        
        // Generate a random value between 1 and the total weight, we will use this value
        // to select the item from the table.
        var randVal = Int.random(in: 1...totalWeight)
        
        
        // Shuffle the table and then loop through each item. If the weight of the item
        // is less than our random value we return that key, otherwise we subtract
        // the value and check the next item.
        for item in table.shuffled() {

            if randVal > item.value {
                
                randVal -= item.value
            }
            else {
                
                returnVal = item.key
                break
            }
        }
        
        return returnVal
    }
    
    /// Generates an entire word using the markov order passed.
    /// - Parameter order: The order of generation, used to determine how far back the state looks to determine the next state.
    /// - Returns: the generated string.
    func generateWord(order: MarkovOrder) -> String {

        var result = ""
        
        // We want to loop until we get a valid word but can't loop indefinitely in case we end up in an infinite loop.
        // Loop for 100 iterations attempting to get a valid word. If not return empty string
        var loop = true
        for _ in Range(1...100) {
            
            // Start by making sure we get a valid starting character and setup our temp result variable
            var tempResult = "^" + self.getInitialLetter()
            let length = getWeightedFromTable(table: lengthWeights, totalWeight: lengthTotalWeight)
            
            // Loop until we hit our max word length and get the next character based on our current
            for i in 1...length {
                
                let currentChar = self.getNext(currentString: tempResult, order: order)

                // If character returned from the generator is the end of string charater we check if the word is of valid length
                if currentChar == "$" {
                    
                    // If we have a valid name we want to break from both loops.
                    if i == length {
                        loop = false
                        break
                    }
                    // Else we hit an end of word character with an invalid word so break from this loop and start over.
                    else {
                        break
                    }
                }

                // Update our temp result with the generated character
                tempResult += currentChar
            }
            
            if loop == false {
                result = tempResult
                break
            }
        }

        if(result != "") {
            result = String(result.dropFirst())
            result = result.capitalized
        }
        
        return result
    }
    
    /// Main loop used to setup the state table. This function is called from the initalizer for each string in the list
    /// pased. This function loops over each character in the string and updates the neccessary weight tables based on the state
    /// - Parameter word: The word to loop over
    private mutating func addWordToTransitionTable(word: String) {

        let wordArray = Array(word)

        // For each letter in this word we add a new value into the state table
        for index in 0..<wordArray.count {

            let char = String(wordArray[index]).lowercased()
            
            // We need to get the character following our current character
            // if we are on the last character we use $ as the terminating character in the table
            var nextChar = "$"
            if index < wordArray.count - 1 {
                nextChar = String(wordArray[index + 1]).lowercased()
            }
            
            // We also need the previous character for our second order transition table.
            // If we're on the first character we make sure to set the inital character as the ^
            var prevChar = "^"
            if index > 0 {
                prevChar = String(wordArray[index - 1]).lowercased()
            }
            
            // If the index is zero we are at the first character in the
            // word, set up our begining letter key
            if index == 0 {
                
                // Initalize and/op update the weight of the inital characters
                if initialState[char] == nil {
                    initialState[char] = 0
                }
                if let weight = initialState[char] {

                    initialState[char] = weight + 1
                }
                
                // Update the total weight of the inital state table
                initialStateTotalWeight += 1
            }
            
            // -----
            // Set up first order transition table
            
            // Initalize and/or update the transition table for the current character
            if firstOrderTransitions[char] == nil {
                firstOrderTransitions[char] = [:]
            }
            if var letterDict = firstOrderTransitions[char] {
                
                // Initalize and/or update the weight of the next character, then store back into
                // parent dictionary
                if letterDict[nextChar] == nil {
                    letterDict[nextChar] = 0
                }
                if let weight = letterDict[nextChar] {
                    letterDict[nextChar] = weight + 1
                }
                firstOrderTransitions[char] = letterDict
                
                // Initalize and/or uppdate the total weight for the current character
                if firstOrderTotalWeights[char] == nil {
                    firstOrderTotalWeights[char] = 0
                }
                if let totalWeights = firstOrderTotalWeights[char] {
                    firstOrderTotalWeights[char] = totalWeights + 1
                }
            }
            
            // -----
            // Set up second order transition table
            
            // Create the key using previous character and current.
            let secondOrderKey = "\(prevChar)\(char)"
            
            // Initalize and/or update the second order transition table for this 2nd order state
            if secondOrderTransitions[secondOrderKey] == nil {
                secondOrderTransitions[secondOrderKey] = [ : ]
            }
            if var secOrdTransitions = secondOrderTransitions[secondOrderKey] {
                
                // Initalize and/or update the weight for the next character from this state, then update parent table
                if secOrdTransitions[nextChar] == nil {
                    secOrdTransitions[nextChar] = 0
                }
                if let weight = secOrdTransitions[nextChar] {
                    secOrdTransitions[nextChar] = weight + 1
                }
                secondOrderTransitions[secondOrderKey] = secOrdTransitions
                
                // Initalize and/or update the total weight for this state
                if secondOrderTotalWeights[secondOrderKey] == nil {
                    secondOrderTotalWeights[secondOrderKey] = 0
                }
                if let weight = secondOrderTotalWeights[secondOrderKey] {
                   secondOrderTotalWeights[secondOrderKey] = weight + 1
                }
            }
        }
    }
}
