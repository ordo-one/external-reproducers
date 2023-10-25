import FoundationEssentials

struct Monster {
    let level: Int
    let name: String
}

let predicate = #Predicate<Monster> { monster in
    monster.level == 80
}
