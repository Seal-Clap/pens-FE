//
//  GroupRowView.swift
//  pens'
//
//  Created by 신지선 on 2023/05/02.
//

import SwiftUI

struct GroupRowView: View {
    var groupName: String
    var onDoubleTap: () -> Void

    var body: some View {
        Text(groupName)
            .onTapGesture(count: 2) {
                onDoubleTap()
            }
    }
}

struct GroupRowView_Previews: PreviewProvider {
    static var previews: some View {
        GroupRowView(groupName: "My Group", onDoubleTap: {})
    }
}
