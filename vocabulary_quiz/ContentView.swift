//
//  ContentView.swift
//  vocabulary_quiz
//
//  Created by VOLKAN EFE on 21.03.2024.
//

import SwiftUI
import Foundation
import AppKit

struct VocabularyItem: Identifiable {
    let id = UUID()
    let word: String
    let kelime: String
    let englishSentence: String
    let turkishSentence: String
}

class VocabularyViewModel: ObservableObject {
    @Published var vocabularyItems: [VocabularyItem] = []
    
    init() {
        if let csvURL = Bundle.main.url(forResource: "vocabulary", withExtension: "csv") {
            do {
                let csvData = try String(contentsOf: csvURL)
                let lines = csvData.components(separatedBy: .newlines)
                for line in lines.dropFirst() {
                    let columns = line.components(separatedBy: ",")
                    if columns.count == 4 {
                        let item = VocabularyItem(word: columns[0],kelime: columns[1], englishSentence: columns[2], turkishSentence: columns[3])
                        vocabularyItems.append(item)
                    }
                }
            } catch {
                print("Error loading CSV file: \(error)")
            }
        } else {
            print("CSV file not found.")
        }
    }
    
    func getRandomWord() -> VocabularyItem? {
        return vocabularyItems.randomElement()
    }
}

struct ContentView: View {
    @StateObject var viewModel = VocabularyViewModel()
    @State private var randomOptions: [String] = []
    @State private var selectedWord: VocabularyItem?
    @State private var isCorrect: Bool?
    @State private var score: Int = 0
    
    init() {
        _selectedWord = State(initialValue: viewModel.getRandomWord())
        _randomOptions = State(initialValue: getRandomOptions())
    }
    
    var body: some View {
        VStack {
            if let word = selectedWord {
                Text("Word: \(word.word)")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
                Text(word.englishSentence)
                    .font(.system(size:20))
                    .padding(.top)
                    .foregroundColor(.green)
                    
                Text(word.turkishSentence)
                    .font(.system(size:20))
                    .padding(.top)
                    .foregroundColor(.red)
            } else {
                Text("No word selected")
            }
            
            Spacer()
            
            Text("====================================")
                .font(.headline)
                .padding(.bottom)
            
            VStack(spacing: 30) {
                ForEach(0..<2) { row in
                    HStack(spacing: 100) {
                        ForEach(0..<2) { column in
                            if let option = randomOptions.get(row * 2 + column) {
                                Button(action: {
                                    checkAnswer(option)
                                }) {
                                    Text(option)
                                        .padding()
                                        .background(isCorrect != nil && isCorrect! && selectedWord?.kelime == option ? Color.green : (isCorrect != nil && !isCorrect! && selectedWord?.kelime == option ? Color.red : Color.primary))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            Text("Score: \(score)")
            
            Spacer()
            
            Button(action: {
                self.selectedWord = viewModel.getRandomWord()
                self.randomOptions = getRandomOptions()
                self.isCorrect = nil
            }) {
                Text("Next")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    
            }
        }
        .padding()
        .frame(width: 500, height: 400)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
            NSApp.terminate(nil)
        }
    }
    
    func getRandomOptions() -> [String] {
        guard let selectedWord = selectedWord else { return [] }
        var options: [String] = []
        options.append(selectedWord.kelime)
        
        while options.count < 4 {
            if let randomWord = viewModel.vocabularyItems.randomElement()?.kelime {
                if !options.contains(randomWord) {
                    options.append(randomWord)
                }
            }
        }
        
        options.shuffle()
        return options
    }
    
    func checkAnswer(_ option: String) {
        guard let selectedWord = selectedWord else { return }
        if option == selectedWord.kelime {
            score += 1
            isCorrect = true
        } else {
            isCorrect = false
        }
    }
}

extension Array {
    func get(_ index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
