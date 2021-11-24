//
//  RandomGeneratorSelectionView.swift
//  CSC690_SwiftUI
//
//  Created by Cameron Robinson on 11/23/21.
//

import SwiftUI
import Foundation


/// This class is responsible for loading all of the name generator json files and decoding into the
/// markov generator struct for the data. An instance of this class is used by the generator selector view
/// to display the buttons for each generator to the user.
class RandomGeneratorLoader {
        
    public private(set) var generators: [RandomGeneratorFromTableSet] = []
    
    // Generator index is set by the button when it is pressed. Then when
    // the sheet is presented the index is used to pass the proper generator data
    // into the sheet constructor.
    var generatorIndex = 0
    
    init() {
        
        // Get list of name generators from CSV and unwrap all optional data
        if let nameGeneratorListPath = Bundle.main.path(forResource: "random_generator_list", ofType: "csv"),
           let nameGeneratorLisData = FileManager.default.contents(atPath: nameGeneratorListPath),
           let content = String(data: nameGeneratorLisData, encoding: .utf8) {
            
            // Split the data and loop through rows, each row is a new name generator
            let rows = content.components(separatedBy: "\n")
            for row in rows {
                
                // Make sure the row is not "" because that can cause a crash.
                if row != "" {
                    
                    // attempt to get the file and data for this generator and decode it into a generator.
                    if let path = Bundle.main.path(forResource: row, ofType: "json"),
                       let data = FileManager.default.contents(atPath: path) {
                        
                        do {
                            let generator = try JSONDecoder().decode(RandomGeneratorFromTableSet.self, from: data)
                            self.generators.append(generator)
                        } catch {
                            print(error)
                        }
                   }
                }
            }
        }
    }
    
    /// Get the set of data for the selected generator, then create and return a new sheet view by passing the generator into the constructor.
    /// - Returns: returns the newly created view for the user to generate names.
    func getSheet(callback: (()->Void)? = nil) -> some View {
        var generator = self.generators[self.generatorIndex]
        let initialData = generator.generate()
        let generatorTitle = generator.generatorName
        
        return RandomGeneratorFromTableView(data: initialData,
                                            generatorTitle: generatorTitle,
                                            dismissCallback: callback ?? {},
                                            generator: generator )
    }
}

struct RandomGeneratorSelectionView: View {
    
    let generatorLoader = RandomGeneratorLoader()

    @State var generator: MarkovChain? = nil
    @State var generatorVisible: Bool = false
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 0) {
            VStack {
                ForEach(0..<self.generatorLoader.generators.count) { i in
                    if i % 2 == 0 {
                        let generator = self.generatorLoader.generators[i]
                        Button(action: {
                            self.generatorLoader.generatorIndex = i
                            self.generatorVisible = true
                        }, label: {
                            Text(generator.generatorName)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        })
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(10)
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            VStack {
                ForEach(0..<self.generatorLoader.generators.count) { i in
                    if i % 2 == 1 {
                        let generator = self.generatorLoader.generators[i]
                        Button(action: {
                            self.generatorLoader.generatorIndex = i
                            self.generatorVisible = true
                        }, label: {
                            Text(generator.generatorName)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        })
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(10)
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
        .frame(minHeight: 0, maxHeight: .infinity)
        .padding()
        .sheet(isPresented: $generatorVisible,
               content: {
                self.generatorLoader.getSheet(callback: dismissSheet)
        })
    }
    
    func dismissSheet() -> Void {
        self.generatorVisible = false
    }
}

struct RandomGeneratorSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RandomGeneratorSelectionView()
    }
}
