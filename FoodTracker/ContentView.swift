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
    var remark:String?
    var starCount:Int
    var image:Data?
    var createdTime:Date
    
    init(title: String,remark:String?=nil, starCount: Int, image: Data? = nil) {
        self.id = UUID()
        self.title = title
        self.remark=remark
        self.starCount = starCount
        self.image = image
        self.createdTime=Date.now
    }
}

struct ContentView: View {
    @State private var isAddItem=false
    @State private var showDeleteButton=false
    @Environment(\.modelContext) private var modelContext
    @Query(sort:\Item.createdTime,order: .reverse) private var items: [Item]
    var body: some View {
        NavigationSplitView {
            VStack {
                if items.isEmpty{
                    Spacer()
                    VStack{
                        Image(systemName: "checkmark.rectangle.stack")
                            .resizable()
                            .frame(width: 200,height: 200)
                        Text("Food Tracker list is empty")
                            .font(.footnote)
                            .foregroundStyle(Color.gray)
                    }
                    .padding()
                    Spacer()
                }else{
                    ScrollView{
                        ForEach(items,id:\.id) { item in
                            NavigationLink{
                                DetailView(item: item)
                                    .padding(.top,72)
                                Spacer()
                            }label:{
                                ItemLabelView(item: item, modelContext: modelContext, showDeleteButton: $showDeleteButton)
                            }
                            .padding([.leading,.trailing],12)
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

struct ItemLabelView:View {
    @Bindable var item:Item
    var modelContext:ModelContext
    @Binding var showDeleteButton:Bool
    var color=Color.blue.opacity(0.22)
    var body: some View {
        HStack{
            ScrollListItemView(item: item)
                .onLongPressGesture(perform: {
                    showDeleteButton.toggle()
                })
            Spacer()
            if showDeleteButton{
                withAnimation{
                    Button(action:{
                        modelContext.delete(item)
                        showDeleteButton.toggle()
                    }){
                        Image(systemName: "minus.circle")
                            .foregroundStyle(Color.red)
                    }
                    .padding()
                }
            }else{
            Text(getTimeLabel(for: item))
                    .font(.footnote)
                    .padding()
            }
        }
        .background(color)
        .cornerRadius(12)
    }
    
    func getTimeLabel(for item: Item) -> String {
        let aHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? Date()
        let aWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let aMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        if item.createdTime > aHourAgo{
            return "last hour"
        }
        if item.createdTime > twentyFourHoursAgo{
            return "last day"
        }
        if item.createdTime > aWeekAgo{
            return "last week"
        }
        if item.createdTime > aMonthAgo{
            return "last month"
        }
        return "a month ago"
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
                            .cornerRadius(8)
                    }else{
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 42, height: 42)
                            .cornerRadius(8)
                    }
                }
                .padding(.leading)
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
                Spacer()
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
    @State private var remark=""
    @State private var editRemark=false
    @State private var editTitle=false
    @FocusState var isEditting
    
    var body: some View {
        VStack{
            HStack{
                VStack{
                    PhotosPicker(selection: $selectedImage, matching: .any(of: [.images,.screenshots]), preferredItemEncoding: .automatic){
                        if let image=item.image{
                            Image(uiImage:UIImage(data: image)!)
                                .resizable()
                                .frame(width: 72, height: 72, alignment: .center)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding()
                                .scaledToFit()
                                .aspectRatio(contentMode: .fit)
                        }else{
                            Image(systemName: "photo.stack")
                                .resizable()
                                .frame(width: 72,height: 72,alignment: .center)
                                .padding()
                                .scaledToFit()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .padding([.horizontal,.vertical])
                }
                .frame(width: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.leading)
                VStack{
                    HStack{
                        if !item.title.elementsEqual(""){
                            Text(item.title)
                                .font(.largeTitle)
                                .bold()
                                .padding([.leading,.top],6)
                        }else{
                            Text("Title")
                                .font(.largeTitle)
                                .bold()
                                .foregroundStyle(Color.white.opacity(0.42))
                                .padding([.leading,.top],6)
                        }
                        Spacer()
                    }
                    .padding(.top,-5)
                    .onTapGesture {
                        if !isEditting{
                            isEditting.toggle()
                            editTitle.toggle()
                        }
                    }
                    Spacer()
                    HStack{
                        if !editTitle && !editRemark{
                            VStack{
                                HStack{
                                    Text(item.remark ?? "Remark is empty")
                                        .padding(.leading,-8)
                                    Spacer()
                                }
                                .padding([.leading,.top],6)
                                Spacer()
                            }
                            .padding()
                        }else if editRemark{
                            VStack{
                                TextField(text: $remark){
                                    if let remark = item.remark,!remark.elementsEqual(""){
                                        Text(remark)
                                    }else{
                                        Text("It's very tasty!")
                                    }
                                }
                                .focused($isEditting)
                                .padding([.leading,.trailing,.bottom],20)
                                Spacer()
                            }

                        }else{
                            VStack{
                                TextField(text: $item.title){
                                    Text(item.title)
                                }
                                .focused($isEditting)
                                .padding([.leading,.trailing,.bottom],20)
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .onTapGesture {
                        if !isEditting{
                            editRemark.toggle()
                            isEditting.toggle()
                        }
                    }
                    .padding([.top,.leading])
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    Spacer()
                    HStack{
                        if !isEditting{
                            StarsView(item: item)
                                .padding(.all,10)
                        }else{
                            Button(action:{
                                if !remark.elementsEqual(""){
                                    item.remark=remark
                                }
                                isEditting.toggle()
                                editRemark=false
                                editTitle=false
                            }){
                                Text("Done")
                            }
                            .frame(width: 120,height: 50)
                            .background(Color.primary)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.bottom,10)
                }
                .padding(.leading)
                Spacer()
            }
            
        }
        .frame(width: 360,height: 240)
        .background(Color.blue.opacity(0.22))
        .clipShape(RoundedRectangle(cornerRadius: 25))
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
        NavigationSplitView{
            ScrollView{
                VStack{
                    PhotosPicker(selection: $selectedImage, matching: .any(of: [.images,.screenshots]), preferredItemEncoding: .automatic){
                        if let imageData {
                            Image(uiImage: UIImage(data: imageData)!)
                                .resizable()
                                .frame(width: 200, height: 200, alignment: .center)
                                .padding()
                                .scaledToFit()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(.capsule)
                        }else{
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 192, height: 192, alignment: .center)
                                .padding()
                                .scaledToFit()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    TextField("input the title",text:$title)
                        .focused($isInputting)
                        .textFieldStyle(.roundedBorder)
                        .padding([.leading,.trailing],20)
                        .clipShape(.capsule)
                        .padding()
                    StarsView(item: Item(title: title, starCount: starCount))
                        .padding([.top,.bottom],20)
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
                            .padding(10)
                    }
                    .frame(width: 120,height: 50)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(Capsule())
                }
                .toolbar(content: {
                    ToolbarItem(placement:.topBarLeading){
                        Button(action:{
                            isPresented.toggle()
                        }){
                            Text("Cancel")
                        }
                    }
                })
                .task(id:selectedImage){
                    if let imagedata=try? await selectedImage?.loadTransferable(type: Data.self){
                        imageData=imagedata
                    }
                }
            }
        }detail: {
            Text("Add an item")
        }
    }
}


//#Preview{
//    ContentView().modelContainer(for:Item.self,inMemory: true)
//}

#Preview{
    return VStack{
        DetailView(item: Item(title: "test", starCount: 1))
            .padding(.top,50)
        Spacer()
    }
}

#Preview{
    var item=Item(title: "test", starCount: 1)
    @State  var selectedImageData:Data?
    @State var selectedImage:PhotosPickerItem?
    @State var editRemark=false
    @FocusState var isEdittingRemark
    @State var remark="very good"

    return VStack{
        HStack{
            VStack{
                PhotosPicker(selection: $selectedImage, matching: .any(of: [.images,.screenshots]), preferredItemEncoding: .automatic){
                    if let image=item.image{
                        Image(uiImage:UIImage(data: image)!)
                            .resizable()
                            .frame(width: 96, height: 96, alignment: .center)
                            .padding()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                    }else{
                        Image(systemName: "photo.stack")
                            .resizable()
                            .frame(width: 96,height: 96,alignment: .center)
                            .padding()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }
            .frame(width: 80)
            .padding(.leading)
            VStack{
                HStack{
                    Text(item.title)
                        .font(.largeTitle)
                        .bold()
                        .padding(.leading,20)
                    Spacer()
                }
                .padding(.top)
                Spacer()
                HStack{
                    if !editRemark{
                        VStack{
                            HStack{
                                Text(item.remark ?? "Remark is empty")
                                    .padding(.leading)
                                Spacer()
                            }
                            .padding(.top)
                            Spacer()
                        }
                        .padding()
                    }else{
                        VStack{
                            TextField(text: $remark){
                                if let remark = item.remark,!remark.elementsEqual(""){
                                    Text(remark)
                                }else{
                                    Text("It's very tasty!")
                                }
                            }
                            .focused($isEdittingRemark)
                            .padding([.leading,.trailing,.bottom],20)
                            Button(action:{
                                item.remark=remark
                                isEdittingRemark.toggle()
                                editRemark=false
                            }){
                                Text("Done")
                            }
                            .frame(width: 120,height: 50)
                            .background(Color.primary)
                            .clipShape(Capsule())
                        }

                    }
                    Spacer()
                }
                .onTapGesture {
                    print("123")
                    if !isEdittingRemark{
                        editRemark.toggle()
                        isEdittingRemark.toggle()
                    }
                }
                .padding([.top,.leading])
                .background(Color.gray)
                Spacer()
                

                HStack{
                    StarsView(item: item)
                        .padding(.all,20)
                }
                .padding(.bottom,20)
            }
            .padding(.leading)
            Spacer()
        }
        
    }
    .frame(width: 360,height: 240)
    .background(Color.yellow)
    .clipShape(RoundedRectangle(cornerRadius: 25))
    .task(id: selectedImage, {
        if let selectedImage{
            selectedImageData=try? await selectedImage.loadTransferable(type: Data.self)
            item.image=selectedImageData
        }
    })
}
