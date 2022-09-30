//
//  CustomRefleshView.swift
//  UI-684
//
//  Created by nyannyan0328 on 2022/09/30.
//

import SwiftUI

struct CustomRefleshView<Content : View>: View {
    var content : Content
    var showIndicatore : Bool = false
    var onReflesh : ()async ->()
    
    
    init(showIndicatore: Bool,@ViewBuilder content : @escaping()->Content ,onReflesh: @escaping ()async ->()) {
        self.content = content()
        self.showIndicatore = showIndicatore
        self.onReflesh = onReflesh
    }
    @StateObject var model : ScrollViewModel = .init()
    
    var body: some View {
        ScrollView(.vertical,showsIndicators: showIndicatore){
            
            VStack(spacing: 0){
                
                Rectangle()
                    .fill(.clear)
                    .frame(height: 150 * model.progress)
                content
            }
            .offset(coordinateSpace: "SCROL") { offset in
                model.contentOfset = offset
                
                if !model.isElibled{
                    
                    
                    var progress = offset / 150
                    progress = (progress < 0 ? 0 : progress)
                    progress = (progress > 1 ? 1 : progress)
                    
                    
                    model.scrollOffset = offset
                    model.progress = progress
                    
                    
                }
                
                if model.isElibled && !model.isRefleshing{
                    
                    
                    model.isRefleshing = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
            
            
            
        }
        .overlay(alignment: .top) {
            
            ZStack{
                Capsule()
                    .fill(.black)
            }
            .frame(width: 126,height: 37)
            .offset(y:11)
            .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .top)
            .overlay(alignment: .top) {
                
                Canvas { context, size in
                    
                    context.addFilter(.alphaThreshold(min: 0.5,color: .black))
                    context.addFilter(.blur(radius: 10))
                    
                    context.drawLayer { cxt in
                        
                        for index in [1,2]{
                            
                            
                            if let resolvedImage = context.resolveSymbol(id: index){
                                
                                cxt.draw(resolvedImage, at: CGPoint(x: size.width / 2, y: 30))
                            }
                            
                        }
                    }
                    
                    
                    
                } symbols: {
                    
                    CanvasSimbol()
                        .tag(1)
                    
                    CanvasSimbol(isCircle: true)
                        .tag(2)
                }
                .allowsHitTesting(false)
              

                
            }
            .overlay(alignment: .top) {
                
                RefleshView()
                    .offset(y:11)
                
            }
            .ignoresSafeArea()
            
        }
        .coordinateSpace(name: "SCROL")
        .onAppear{model.addGetsuture()}
        .onDisappear{model.removeGetsture()}
        .onChange(of: model.isRefleshing) { newValue in
             if newValue{
        
                        Task{
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
                            await onReflesh()
        
                            withAnimation(.easeInOut(duration: 0.3)){
        
                                model.isElibled = false
                                model.isRefleshing = false
                               model.scrollOffset = 0
                                model.progress = 0
                            }
                        }
        
        
                    }
        
                }
    }
    @ViewBuilder
    func RefleshView ()->some View{
        
        let contentOffset = model.isElibled ? (model.contentOfset > 95 ? model.contentOfset : 95) : model.scrollOffset
        
        
        let offset = model.scrollOffset > 0 ? contentOffset : 0
        
        
        ZStack{
            
             Image(systemName: "arrow.down")
                .font(.caption.bold())
                .foregroundColor(.white)
             .frame(width: 30,height: 30)
             .rotationEffect(.init(degrees: model.progress * 180))
             .opacity(model.isElibled ? 0  :1)
            
            
            ProgressView()
                .tint(.white)
                .opacity(model.progress)
        }
        .animation(.easeIn(duration: 0.3), value: model.isElibled)
        .opacity(model.progress)
        .offset(y:offset)
        
    }
    @ViewBuilder
    func CanvasSimbol(isCircle : Bool = false)->some View{
        
        
        if isCircle{
            
            let contentOffset = model.isElibled ? (model.contentOfset > 95 ? model.contentOfset : 95) : model.scrollOffset
            
            
            let offset = model.scrollOffset > 0 ? contentOffset : 0
            
            let scale = ((model.progress / 1) * 0.21)
            
            Circle()
                .fill(.black)
             .frame(width:47 ,height:47)
             .scaleEffect(0.79 + scale,anchor: .center)
             .offset(y:offset)
        
            
            
            
        }
        else{
            Capsule()
            .fill(.black)
             .frame(width: 126,height: 37)
        }
    }
}

struct CustomRefleshView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


class ScrollViewModel : NSObject,ObservableObject,UIGestureRecognizerDelegate{
    
    
    @Published var isElibled : Bool = false
    @Published var isRefleshing : Bool = false
    @Published var scrollOffset : CGFloat = 0
    @Published var contentOfset : CGFloat = 0
    
    @Published var progress : CGFloat = 0
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    func addGetsuture(){
        
        let pangesture = UIPanGestureRecognizer(target: self, action: #selector(onGestureChange(gesture: )))
        
        
        pangesture.delegate = self
        
        getRootView().view.addGestureRecognizer(pangesture)
    }
    
    func removeGetsture(){
        getRootView().view.gestureRecognizers?.removeAll()
    }
    
    @objc
    func onGestureChange(gesture : UIPanGestureRecognizer){
        
        if gesture.state == .cancelled || gesture.state == .ended{
            
            if !isRefleshing{
                
                if scrollOffset > 150{
                    
                    isElibled = true
                }
                else{
                    isElibled = false
                }
            }
            
            
            
        }
        
        
    }
    
    
}




func getRootView()->UIViewController{
    
    guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{return.init()}
    
    guard let root = screen.windows.first?.rootViewController else{return .init()}
    
    return root
    
}

extension View{
    @ViewBuilder
    func offset(coordinateSpace : String, offset : @escaping(CGFloat)->()) -> some View{
        
        self
            .overlay {
                
                GeometryReader{proxy in
                    
                    let minY = proxy.frame(in: .named(coordinateSpace)).minY
                    
                    Color.clear
                        .preference(key:OffsetKey.self, value: minY)
                        .onPreferenceChange(OffsetKey.self) { value in
                            
                            offset(value)
                        }
                }
                
            }
        
        
    }
    
}
struct OffsetKey : PreferenceKey{
    
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
