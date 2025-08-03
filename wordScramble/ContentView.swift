//
//  ContentView.swift
//  wordScramble
//
//  Created by Mohsin khan on 01/08/2025.
//

import SwiftUI

struct ContentView: View {
    
   @State private var userWord = [String]()
    @State private var newWord = ""
    @State private var rootWord = ""
    
    @State private var errorMessage = ""
    @State private var errorTitle = ""
    @State private var showError = false
    
    @State private var playerScore = 0
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("Enter a word here" , text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section{
                    ForEach(userWord , id: \.self){word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                Section{
                    Text("your score \(playerScore) points")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(.blue)
                        .clipShape(.rect(cornerRadius: 25))
                }
                .padding(.horizontal, 80)
                .listRowBackground(Color.clear)
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle , isPresented: $showError){
                Button("OK" , role: .cancel){}
            }message: {
                Text(errorMessage)
            }
            .toolbar{
                Button("Reset"){
                    playerScore = 0
                    newWord = ""
                    userWord.removeAll()
                    startGame()
                }
            }
        }
       
    }
    func addNewWord(){
        let Answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard Answer.count > 2 else {
            wordError(title: "too short", message: "words must be longer than 2 letters")
            return
        }
        
        guard Answer != rootWord else {
            wordError(title: "Same as root", message: "You can't use the root word.")
            return
        }

        
        
        guard isOriginal(word: Answer) else{
            wordError(title: "word used already", message: "be more original")
            return
        }
        guard isPossible(word: Answer) else{
            wordError(title: "word not possible" , message: "you cant spell that word from \(rootWord)")
            return
        }
        
        guard isReal(word: Answer) else{
            wordError(title: "word not real" , message: "that word isnt in the english language")
            return
        }
        
        
        withAnimation{
            userWord.insert(Answer , at: 0)
        }
        newWord = ""
//        playerScore += 1
        playerScore += Answer.count * 10

    }
    
    func startGame(){
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordURL , encoding: .utf8){
                let allWord = startWords.components(separatedBy: "\n")
                 rootWord = allWord.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word : String)-> Bool{
        !userWord.contains(word)
    }
    
    func isPossible(word : String)-> Bool{
        var tempWord = rootWord
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        return true
    }
    
    func isReal(word : String)-> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelled = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelled.location == NSNotFound
    }
    func wordError(title : String , message : String){
        errorTitle = title
        errorMessage = message
        showError = true
    }
    
}

#Preview {
    ContentView()
}
