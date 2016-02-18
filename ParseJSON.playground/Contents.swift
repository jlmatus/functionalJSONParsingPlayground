

import UIKit


import XCPlayground




func flatten<A>(x: A??) -> A? {
    if let y = x { return y }
    return nil
}

infix operator >>>= {}
func >>>= <A, B> (optional: A?, f: A -> B?) -> B? {
    return flatten(optional.map(f))
}

func number(input: [NSObject:AnyObject], key: String) -> NSNumber? {
    return input[key] >>>= { $0 as? NSNumber }
}

func int(input: [NSObject:AnyObject], key: String) -> Int? {
    return number(input, key: key).map { $0.integerValue }
}

func float(input: [NSObject:AnyObject], key: String) -> Float? {
    return number(input, key: key).map { $0.floatValue }
}

func double(input: [NSObject:AnyObject], key: String) -> Double? {
    return number(input, key: key).map { $0.doubleValue }
}

func string(input: [String:AnyObject], key: String) -> String? {
    return input[key] >>>= { $0 as? String }
}

func bool(input: [String:AnyObject], key: String) -> Bool? {
    return number(input, key: key).map { $0.boolValue }
}



protocol JSONParselable {
    static func withJSON(json: [String:AnyObject]) -> Self?
}

struct Player {
    let name: String
    let position: String
    let number: Int
    
    
    init(
        name: String,
        position: String,
        number: Int
        ) {
            self.name  = name
            self.position = position
            self.number = number
    }
}

struct Coach {
    let name: String
    let position: String
    
    init(
        name: String,
        position: String
        ) {
            self.name       = name
            self.position = position
    }
}


struct Team {
    let id: Int
    let teamName: String
    let city: String
    let players: [Player]
    let coaches: [Coach]
    
    init(
        id: Int,
        teamName: String,
        city: String,
        players: [Player],
        coaches: [Coach]
        ) {
            self.id         = id
            self.teamName   = teamName
            self.city       = city
            self.players       = players
            self.coaches       = coaches
    }
}

extension Player: JSONParselable {
    static func withJSON(json: [String:AnyObject]) -> Player? {
        guard
            let name = string(json, key: "name"),
            position = string(json, key: "position"),
            number = int(json, key: "number")
            else {
                return nil
                // A valid Player always has a name and a
                // position.
        }
        
        return Player(
            name: name,
            position: position,
            number: number
        )
    }
}

extension Coach: JSONParselable {
    static func withJSON(json: [String:AnyObject]) -> Coach? {
        guard
            let name = string(json, key: "name"),
            position = string(json, key: "position")
            else {
                return nil
        }
        
        return Coach(
            name: name,
            position: position
        )
    }
}
extension Team {
    static func withJSON(json: [String:AnyObject]) -> Team? {
        
        guard
            let id = int(json, key: "id"),
            teamName = string(json, key: "teamName"),
            city = string(json, key: "City")
            else {
                return nil
        }
        
        let playersDict = json["players"] as? [[String:AnyObject]]
        let coachesDict = json["coaches"] as? [[String:AnyObject]]
        
        func sanitizedPlayers(dicts: [[String:AnyObject]]?) -> [Player] {
            guard let dicts = dicts else {
                return [Player]()
            }
            
            return dicts.flatMap { Player.withJSON($0) }
        }
        
        func sanitizedCoaches(dicts: [[String:AnyObject]]?) -> [Coach] {
            guard let dicts = dicts else {
                return [Coach]()
            }
            
            return dicts.flatMap { Coach.withJSON($0) }
        }
        
        return Team(
            id: id,
            teamName: teamName,
            city: city,
            players: sanitizedPlayers(playersDict),
            coaches: sanitizedCoaches(coachesDict)
        )
    }
}

func dataTaskFinishedWithData(data: NSData) {
    do
    {
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [[String:AnyObject]]
        if let json = json {
            for item in json  {
                let team = Team.withJSON(item)
                print(team)
            }
        }
    } catch {
        print(error)
    }
}



let filePath = XCPlaygroundSharedDataDirectoryURL.URLByAppendingPathComponent("teams.json")


let data = NSData(contentsOfURL: filePath)

dataTaskFinishedWithData(data!)



