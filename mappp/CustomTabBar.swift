//
//  CustomTabBar.swift
//  final2
//
//  Created by Evans on 2023-11-28.
//
// got the tab bar from this https://www.waldo.com/blog/how-to-use-swift-tabview-with-examples
//and modified it a bit

import SwiftUI

enum Tab: String, CaseIterable {
   case house
   case map
   case star
   case ellipsis
}

struct MyTabBar: View {
    @Binding var selectedTab: Tab

    private var fillImage: String {
        selectedTab.rawValue + ".fill"
    }

    var body: some View {
        VStack {
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Spacer()
                    VStack {
                        Image(systemName: selectedTab == tab ? fillImage : tab.rawValue)
                            .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                            .foregroundColor(selectedTab == tab ? .blue : .gray)
                            .font(.system(size: 22))

                        
                    }
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 0.1)) {
                            selectedTab = tab
                        }
                    }
                    Spacer()
                }
            }
            .frame(height: 60) // Adjust the height as needed
            .background(.thinMaterial)
            .cornerRadius(20)
        }
    }
}


struct MyTabBar_Previews: PreviewProvider {
     static var previews: some View {
         MyTabBar(selectedTab: .constant(.house))
     }
}
