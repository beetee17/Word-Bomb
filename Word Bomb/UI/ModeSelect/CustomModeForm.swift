//
//  CustomModeForm.swift
//  Word Bomb
//
//  Created by Brandon Thio on 7/7/21.
//

import SwiftUI
import CoreData

struct CustomModeForm: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var errorHandler = Game.errorHandler
    @StateObject var viewModel = CustomModeFormVM()
    
    @FetchRequest(entity: Database.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Database.name_, ascending: true)],
                  predicate: NSPredicate(format: "type_ == %@", DBType.Words.rawValue)) var wordsDBs: FetchedResults<Database>
    
    @FetchRequest(entity: Database.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Database.name_, ascending: true)],
                  predicate: NSPredicate(format: "type_ == %@", DBType.Queries.rawValue)) var queriesDBs: FetchedResults<Database>
    
    var body: some View {
        
        Form {
            Section(header: Text("Game Type")) {
                Picker("Select Type", selection: $viewModel.gameType) {
                    ForEach(GameType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            
            Section(header: Text("Mode Name")) {
                TextField("Enter the name of your mode", text: $viewModel.modeName)
                    .autocapitalization(.words)
            }
            Section(header: Text("Instruction"))  {
                TextField("Enter user instruction here", text: $viewModel.instruction)
                
            }
            Section(header: Text("Words")) {
                DatabaseListing(databases: wordsDBs, selection: $viewModel.wordsDB)
            }
            
            if viewModel.gameType == .Classic {
                Section(header: Text("Queries")) {
                    DatabaseListing(databases: queriesDBs, selection: $viewModel.queriesDB)
                }
            }
            
            Button(action: { viewModel.saveMode(moc: viewContext) })
            {
                HStack {
                    Text("Save Changes")
                    Spacer()
                    Image(systemName: "checkmark.circle")
                }
            }
            .alert(isPresented: $viewModel.showSaveSuccessAlert) {
                Alert(title: Text("Save Successful"),
                      message: Text("You can now find your new custom mode in the mode select view!."),
                      dismissButton: .default(Text("OK")) {
                    print("dismissed")
                    viewModel.showSaveSuccessAlert = false
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
        .foregroundColor(.white)
        .banner(isPresented: $errorHandler.bannerIsShown, title: errorHandler.bannerTitle, message: errorHandler.bannerMessage)
        .alert(isPresented: $errorHandler.alertIsShown) {
            Alert(title: Text("\(errorHandler.alertTitle)"),
                  message: Text("\(errorHandler.alertMessage)"),
                  primaryButton: .default(Text("Overwrite")) {
                // User wants to overwrite
                viewModel.forceOverwrite(moc: viewContext)
            },
                  secondaryButton: .default(Text("Cancel")) {
                // User does not want to overwrite -> do nothing
            })
        }
    }
}

struct DatabaseListing: View {
    
    var databases: FetchedResults<Database>
    @Binding var selection: Database?
    
    var body: some View {
        
        List(databases, id: \.self) { db in
            HStack {
                Button(action: {
                    if db.words_?.count != 0 {
                        selection = db
                    } else {
                        Game.errorHandler.showBanner(title: "Empty Database",
                                               message: "Please select another database")
                    }
                    
                }) {
                    Image(systemName: db == selection ? "checkmark.circle.fill" : "circle")
                }
                Text(db.name.capitalized)
            }
            .foregroundColor(db.words_?.count == 0 ? .gray : .white)
            
        }
        
    }
}

class CustomModeFormVM: ObservableObject {
    
    @Published var gameType = GameType.Exact
    @Published var modeName = ""
    @Published var instruction = ""
    @Published var showSaveSuccessAlert = false
    @Published var wordsDB: Database?
    @Published var queriesDB: Database?
    
    func forceOverwrite(moc: NSManagedObjectContext) {
        _ = GameMode(context: moc, gameType: gameType, name: modeName, instruction: instruction, wordsDB: wordsDB!, queriesDB: queriesDB)
        moc.saveObjects()
        showSaveSuccessAlert.toggle()
    }
    
    func saveMode(moc: NSManagedObjectContext) {
        
        if modeName.trim() == "" {
            Game.errorHandler.showBanner(title: "Empty Mode Name",
                                    message: "Please enter a name for your custom mode.")
            
        }
        
        else if wordsDB == nil || (gameType == .Classic && queriesDB == nil) {
            Game.errorHandler.showBanner(title: "No Database Selected",
                                    message: "Please choose a database.")
            
        }
        
        else {
            if !moc.checkNewModeForConflict(name: modeName, type: gameType) {
                // we can force-unwrap wordsDB and queriesDB due to the check above
                let newMode = GameMode(context: moc, gameType: gameType, name: modeName, instruction: instruction, wordsDB: wordsDB!, queriesDB: queriesDB)
                print("saving item: \(newMode)")
                moc.saveObjects()
                showSaveSuccessAlert.toggle()
            }
        }
    }
}

struct CustomModeForm_Previews: PreviewProvider {
    static var previews: some View {
        CustomModeForm()
            .environment(\.managedObjectContext, moc_preview)
    }
}
