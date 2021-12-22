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
struct AddDatabaseView: View {
    
    @EnvironmentObject var errorHandler: ErrorViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Database.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Database.name_, ascending: true)]) var databases: FetchedResults<Database>
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var dbName = ""
    @State private var dbType: DBType = .words
    @State var selection: Database?
    
    
    var body: some View {
        NavigationView {
            VStack(alignment:.leading) {
                
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
                    .foregroundColor(.secondary)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10.0)
                    .padding(.horizontal, 25)
                    .autocapitalization(.words)
                
                SectionHeaderText("Copy Existing")
                    .offset(x: 0, y: 30)
                    .zIndex(1)
                
                List(databases, id: \.self, selection: $selection) { db in
                    Text(db.name.capitalized)
                    
                }
                .environment(\.editMode, .constant(EditMode.active))
            }
            
            .navigationTitle("Add Database")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            if dbName.trim().count == 0 {
                                errorHandler.showBanner(title: "Database Name Cannot Be Empty", message: "Please give your database a name")
                            } else if !viewContext.checkNewDBForConflict(name: dbName, type: dbType) {
                                // no conflict, we can immediately save
                                _ = Database(context: viewContext, name: dbName, type: dbType, items: selection?.words)
                                viewContext.saveObjects()
                                presentationMode.wrappedValue.dismiss()
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
                    _ = Database(context: viewContext, name: dbName, type: dbType, items: selection?.words)
                    viewContext.saveObjects()
                    presentationMode.wrappedValue.dismiss()
                },
                      secondaryButton: .default(Text("Cancel")) {
                    // User does not want to overwrite -> do nothing
                })
            }
        }
    }
}

struct AddDatabaseView_Previews: PreviewProvider {
    static var previews: some View {
        AddDatabaseView()
    }
}
