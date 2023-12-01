import PluginSupport
import SwiftUI
// import Transactions

struct ContentView: View {
    @State private var showDetails = false
    @State private var result = ""
    var bTree = BinaryTreeCalc()

    // let transaction = TransactionList()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            // Text(bTree.calculate())
            Button("Calculate") {
                Task {
                    result = bTree.calculate()
                }
                if showDetails == false {
                    showDetails.toggle()
                }
                print(result)
            }

            if showDetails {
                Text(result)
                // print("\(Frostflake.generate())")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
