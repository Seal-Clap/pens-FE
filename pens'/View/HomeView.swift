//
//  HomeView.swift
//  pens'
//
//  Created by 박상준 on 2023/04/09.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        HStack {
            NavigationSplitView {
                Text("SideBar")
                    .navigationSplitViewColumnWidth(400)
            }
            content: {
                
                List {
                    Text("Group")
                    Text("temp")
                }
                .navigationSplitViewColumnWidth(150)
            }
            detail: {
                Text("Detail")
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
