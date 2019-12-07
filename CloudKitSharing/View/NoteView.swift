import SwiftUI

struct NoteView: View {
    @EnvironmentObject var store: CloudStore
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text(store.note.text)
                if showShareSheet {
                    CloudSharingController(isShowing: $showShareSheet)
                        .frame(width: 0, height: 0)
                }
            }
            .navigationBarItems(trailing: shareButton)
        }
    }
    
    var shareButton: some View {
        Image(systemName: "person.crop.circle.fill.badge.plus")
            .imageScale(.large)
            .padding(EdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5))
            .onTapGesture {
                print("Showing sheet")
                self.showShareSheet = true
        }
    }
}
