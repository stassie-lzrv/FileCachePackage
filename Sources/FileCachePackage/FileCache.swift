//
//  FileCache.swift
//  
//
//  Created by Настя Лазарева on 01.07.2023.
//

import Foundation
import CocoaLumberjackSwift

public protocol JSONConvertible {
    associatedtype Item: JSONConvertible
    var json:  Any { get }
    static func parse(json: Any) -> Item?
}


public protocol IdentifiableType {
    var id: String { get }
}

public class FileCache<Item: JSONConvertible & IdentifiableType> {
    public init(){}
    public let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    public var todoItemCollection : [Item] = []
    
    func addNewTask(_ newTask : Item){
        if let ind = todoItemCollection.firstIndex(where: {$0.id == newTask.id}){
            todoItemCollection[ind] = newTask
        } else {
            todoItemCollection.append(newTask)
        }
    }
    
    func deleteTask(with id: String){
        todoItemCollection.removeAll(where: {$0.id == id})
    }
    
    func saveJSON(filename: String){
        let urlPath = url.appendingPathComponent(filename)
        let jsonItems = todoItemCollection.map({$0.json})
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonItems, options: .prettyPrinted)
            try data.write(to: urlPath)
        } catch {
            DDLogError("Error saving data")
        }
    }
    
    func loadJSON(filename: String){
        let urlPath = url.appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: urlPath.path),
           let data = try? Data(contentsOf: urlPath),
           let jsonItems = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
            todoItemCollection = fetchItemsFromJson(jsonItems) ?? []
        } else {
            DDLogError("File not found")
        }
    }
    
    func fetchItemsFromJson(_ json: [Any]) -> [Item]? {
           return json.compactMap { Item.parse(json: $0) as? Item }
       }
    
    
}
