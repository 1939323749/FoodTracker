//
//  ContentView.swift
//  FoodTracker
//
//  Created by mba on 2023/10/15.
//

import Foundation
import SwiftUI
import SwiftData
import UIKit
import PhotosUI

@Model
class Item{
    public var id=UUID()
    var title:String
    var starCount:Int
    var image:Data?
    
    init(title: String, starCount: Int, image: Data? = nil) {
        self.id = UUID()
        self.title = title
        self.starCount = starCount
        self.image = image
    }
}

struct ContentView: View {
    @State private var isAddItem=false
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    var body: some View {
        NavigationSplitView {
            VStack {
                if items.isEmpty{
                    VStack{
                        Image(systemName: "checkmark.rectangle.stack")
                            .resizable()
                            .frame(width: 200,height: 200)
                        Text("Food Tracker list is empty")
                            .font(.footnote)
                            .foregroundStyle(Color.gray)
                    }
                }else{
                    ScrollView{
                        ForEach(items,id:\.id) { item in
                            NavigationLink{
                                DetailView(item: item)
                            }label:{
                                ScrollListItemView(item: item)
                            }
                        }
                    }
                    Spacer()
                }
            }
            .padding(.top)        
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    TopBarTitle()
                }
                ToolbarItem(placement:.topBarTrailing){
                    TopBarAddButton(isPresented: $isAddItem, context:modelContext)
                }
            }
            Spacer()
        }detail: {
                Text("food tracker")
        }
    }
}

struct ScrollListItemView:View {
    @Bindable var item:Item
    
    var body: some View {
        VStack{
            HStack{
                VStack{
                    if let image = item.image{
                        Image(uiImage: UIImage(data: image)!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 42, height: 42)
                                .cornerRadius(3)
                    }
                }
                .padding(.leading)
                Spacer()
                VStack{
                    HStack{
                        Text(item.title)
                            .font(.headline)
                            .foregroundColor(.green)
                            .cornerRadius(8)
                            .padding(.leading)
                            .font(.largeTitle)
                        Spacer()
                    }
                    HStack{
                        StarsView(item: item)
                            .padding(.leading)
                        Spacer()
                    }
                }

                .padding(.trailing)
            }
        }
        .padding()
    }
}

struct TopBarTitle:View {
    var body: some View {
        Text("Food Tracker")
            .font(.title)
            .foregroundStyle(LinearGradient(colors: [.yellow,.purple,.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}
                  
struct TopBarAddButton:View {
    @Binding var isPresented:Bool
    var context:ModelContext
    
    var body: some View {
        Button(action: {
            isPresented=true
        }){
            Image(systemName: "plus")
        }
        .popover(isPresented: $isPresented){
            AddItemView(context:context, isPresented: $isPresented)
        }
    }
}

struct DetailView: View {
    @Bindable var item:Item
    @State private var selectedImageData:Data?
    @State private var selectedImage:PhotosPickerItem?
    
    var body: some View {
        VStack {
            VStack{
                if let image=item.image{
                    Image(uiImage:UIImage(data: image)!)
                        .resizable()
                        .frame(width: 200, height: 200, alignment: .center)
                        .padding()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                }
                StarsView(item: item)
                PhotosPicker(selection: $selectedImage, matching: .any(of: [.images,.screenshots]), preferredItemEncoding: .automatic){
                    Label("add",systemImage: "star")
                }
            }
        }
        .toolbar{
            ToolbarItem(placement: .automatic){
                Text(item.title)
            }
        }
        .task(id: selectedImage, {
            if let selectedImage{
                selectedImageData=try? await selectedImage.loadTransferable(type: Data.self)
                item.image=selectedImageData
            }
        })
    }
}

struct StarsView: View {
    @Bindable var item:Item
    private let totalStars: Int = 5
    
    var body: some View {
        HStack {
            ForEach(1...totalStars, id: \.self) { index in
                VStack {
                    if item.starCount >= index {
                        Image(systemName: "star.fill")
                            .foregroundColor(getStarColor())
                    } else {
                        Image(systemName: "star")
                    }
                }
                .onTapGesture {
                    item.starCount = index
                }
            }
        }
    }
    
    private func getStarColor() -> Color {
        switch item.starCount {
        case ..<3:
            return .red
        case ..<5:
            return .yellow
        default:
            return .green
        }
    }
}


struct AddItemView:View {
    var context:ModelContext
    @Binding var isPresented:Bool
    @State private var title=""
    @State private var starCount=5
    @State private var selectedImage:PhotosPickerItem?
    @State var imageData:Data?
    @FocusState private var isInputting:Bool
    var body: some View {
        VStack{
            PhotosPicker(selection: $selectedImage, matching: .any(of: [.images,.screenshots]), preferredItemEncoding: .automatic){
                if let imageData {
                    Image(uiImage: UIImage(data: imageData)!)
                        .resizable()
                        .frame(width: 200, height: 200, alignment: .center)
                        .padding()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                }else{
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 200, height: 200, alignment: .center)
                        .padding()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                }
            }
            TextField("input the title",text:$title)
                .focused($isInputting)
                .textFieldStyle(.roundedBorder)
                .padding([.leading,.trailing],20)
            StarsView(item: Item(title: title, starCount: starCount))
                .padding()
            Button(action:{
                isInputting.toggle()
                if !title.elementsEqual(""){
                    context.insert(Item(title: title, starCount: starCount,image: imageData))
                }
                isPresented.toggle()
            }){
                Text("Done")
                    .font(.title)
                    .foregroundStyle(Color.gray)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                    .padding(10)
            }
        }
        .task(id:selectedImage){
            if let imagedata=try? await selectedImage?.loadTransferable(type: Data.self){
                imageData=imagedata
            }
        }
    }
}
