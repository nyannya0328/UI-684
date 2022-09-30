//
//  ContentView.swift
//  UI-684
//
//  Created by nyannyan0328 on 2022/09/30.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CustomRefleshView(showIndicatore: false) {
            
            VStack{
                
                Rectangle()
                    .fill(.red)
                 .frame(height: 200)
                
                Rectangle()
                    .frame(height: 200)
            }
            .padding(15)
        } onReflesh: {
            
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
