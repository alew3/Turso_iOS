//
//  ContentView.swift
//  Turso_ios
//
//  Created by Alessandro Cauduro on 27/06/24.
//

import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var results: [DatabaseRow] = []

    func setupDatabase() {
        // delete database if it exists and recreate it
        Database().recreateDatabase()

        let statements = [
            """
            CREATE TABLE movies (
              title TEXT,
              year INT,
              embedding FLOAT32(3)
            );
            """
            ,
            """
            INSERT INTO movies (title, year, embedding)
            VALUES
              (
                'Napoleon',
                2023,
                vector('[1,2,3]')
              ),
              (
                'Black Hawk Down',
                2001,
                vector('[10,11,12]')
              ),
              (
                'Gladiator',
                2000,
                vector('[7,8,9]')
              ),
              (
                'Blade Runner',
                1982,
                vector('[4,5,6]')
              );
            """,
            """
            CREATE INDEX movies_idx USING diskann_cosine_ops ON movies (embedding);
            """
        ]

        Database().executeStatements(statements)
    }
    
    func searchVector() {
        let sql : String = "SELECT title, year FROM movies ORDER BY vector_distance_cos(embedding, '[3,1,2]') LIMIT 3;"
        
        guard let results = Database().executeSelect(query: sql) else {
            return
        }
        self.results = results
    }
}


struct ContentView: View {
    
    private var dbModel = ContentViewModel()
    @State private var msg = ""

    
    var body: some View {
        VStack(alignment: .center){
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello world of Vector Search").padding()
            
            Text(msg)
                .foregroundColor(.red)
                .padding()
            
            Button(action: {
                dbModel.setupDatabase()
                msg = "Database Setup!"
            }, label: {
                Text("Setup Database")
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
            }).padding()

            Button(action: {
                dbModel.searchVector()
                msg = "Search on database executed!"

            }, label: {
                Text("Vector Search")
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }).padding()
            
            List(dbModel.results) { row in
                if let title = row.data["title"], let year = row.data["year"] {
                    Text("Title: ")
                    + Text("\(title) \n").fontWeight(.bold)
                    + Text("Year: ")
                    + Text("\(year)").fontWeight(.bold)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
