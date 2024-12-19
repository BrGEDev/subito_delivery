import SwiftUI

struct Splash: View {
    
    @State var appear: Bool = true
    
    var body: some View {
        ZStack{
            Color.black.edgesIgnoringSafeArea(.all)
            
            ZStack{
                if appear {
                    Image(.logoDark)
                        .resizable()
                        .frame(maxWidth:.infinity, maxHeight: 120)
                        .padding(50)
                        .zIndex(10)
                }
            }
            .background(Color.black)
            .frame(width: 400, height: 400)

        }
    }
}

#Preview {
    Splash()
}
