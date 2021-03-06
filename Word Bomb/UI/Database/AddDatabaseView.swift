//
//  AddDatabaseView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 4/8/21.
//

import SwiftUI


struct SectionHeaderText: View {
    
    var text: String
    init(_ text: String) {
        self.text = text
    }
    var body: some View {
        Text(text)
            .foregroundColor(.gray)
            .font(.subheadline)
            .padding(.leading, 25)
    }
}

struct DatabaseTextEditor: View {
    
    @Binding var text: String?
    
    init(text: Binding<String?>) {
        UITextView.appearance().backgroundColor = .clear // First, remove the UITextView's backgroundColor.
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            let placeholder = "Separate words by new lines, and commas if they should be grouped together!\nFor example:\nChina \nAmerica, US, USA"
            
            Color(.secondarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
            
            TextEditor(text: Binding($text, replacingNilWith: ""))
                .padding(.horizontal, 25)
                .padding(.top, 1)
            
            Text(text ?? placeholder)
            // following line is a hack to create an inset similar to the TextEditor inset...
                .foregroundColor(Color(.placeholderText))
                .opacity(text == nil ? 1 : 0)
                .padding(.leading, 30)
                .padding(.top, 8)
                .padding(.trailing, 20)
                .disabled(true)
                .allowsHitTesting(false)
        }
        .font(.body)
        .navigationTitle("Custom Words")
        .navigationBarTitleDisplayMode(.inline)
    }
        
}
struct AddDatabaseView: View {
    
    @ObservedObject var errorHandler = Game.errorHandler
    @EnvironmentObject var cdViewModel: CoreDataViewModel
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Database.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Database.name_, ascending: true)]) var databases: FetchedResults<Database>
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var dbName = ""
    @State private var dbType: DBType = .Words
    @State private var selection: Database?
    @State private var dbWords: String?

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                
                SectionHeaderText("Database Type")
                
                Picker("Select a Type", selection: $dbType) {
                    ForEach(DBType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 30)
                .onChange(of: dbType, perform: { value in
                    print("Chose \(dbType)")
                })
                
                SectionHeaderText("Database Name")
                
                TextField("Enter the name of your database", text: $dbName)
                    .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10.0)
                    .padding(.horizontal, 25)
                    .autocapitalization(.words)
                
                SectionHeaderText("Copy Existing")
                    .zIndex(1)
                
                List(databases, id: \.self, selection: $selection) { db in
                    Text(db.name.capitalized)
                    
                }
                .offset(x: 0, y: -30)
                .environment(\.editMode, .constant(EditMode.active))
                
                List {
                    NavigationLink("Add Custom Words") {
                        DatabaseTextEditor(text: $dbWords)
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
            .navigationTitle("Add Database")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            if dbName.trim().count == 0 {
                                errorHandler.showBanner(title: "Database Name Cannot Be Empty", message: "Please give your database a name")
                            } else if !viewContext.checkNewDBForConflict(name: dbName, type: dbType) {
                                // no conflict, we can immediately save
                                createDB()
                            }
                        }
                    }) {
                        Text("Save")
                    }
                }
            }
            .banner(isPresented: $errorHandler.bannerIsShown, title: errorHandler.bannerTitle, message: errorHandler.bannerMessage)
            .alert(isPresented: $errorHandler.alertIsShown) {
                Alert(title: Text("\(errorHandler.alertTitle)"),
                      message: Text("\(errorHandler.alertMessage)"),
                      primaryButton: .default(Text("Overwrite")) {
                    // User wants to overwrite
                    createDB()
                },
                      secondaryButton: .default(Text("Cancel")) {
                    // User does not want to overwrite -> do nothing
                })
            }
        }
    }
    
    private func createDB() {
        var newDB: Database
        let customWords = dbWords?
            .lowercased()
            .components(separatedBy: "\n")
            .map({ $0.components(separatedBy: ",")})
        
        if let selection = selection {
            newDB = Database(context: viewContext, name: dbName, db: selection)
        } else {
            newDB = Database(context: viewContext, name: dbName, type: dbType)
        }
        
        if let customWords = customWords {
            print("Adding: \(customWords)")
            cdViewModel.populateDB(context: viewContext, db: newDB, words: customWords)
        }
        
        viewContext.saveObjects()
        
        // TODO: Add save success alert
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddDatabaseView_Previews: PreviewProvider {

    static var previews: some View {
        AddDatabaseView()
            .environmentObject(CoreDataViewModel())
            .environment(\.managedObjectContext, moc_preview)
    }
}
