import Foundation
import BetComponents

class GroupManager: ObservableObject {
    @Published private(set) var groups: [[BetComponents.Player]] = []
    @Published private(set) var currentGroupIndex: Int?
    @Published private(set) var isGroupLeader: Bool = false
    private let userDefaults = UserDefaults.standard
    private let groupsKey = "savedGroups"
    private let currentGroupKey = "currentGroupIndex"
    private let isLeaderKey = "isGroupLeader"
    
    init() {
        loadGroups()
    }
    
    private func loadGroups() {
        // Load saved groups
        if let data = userDefaults.data(forKey: groupsKey),
           let savedGroups = try? JSONDecoder().decode([[BetComponents.Player]].self, from: data) {
            groups = savedGroups
        }
        
        // Load current group index
        currentGroupIndex = userDefaults.integer(forKey: currentGroupKey)
        
        // Load leader status
        isGroupLeader = userDefaults.bool(forKey: isLeaderKey)
    }
    
    func setGroups(_ newGroups: [[BetComponents.Player]]) {
        groups = newGroups
        saveGroups()
    }
    
    func setCurrentGroup(_ index: Int) {
        currentGroupIndex = index
        userDefaults.set(index, forKey: currentGroupKey)
    }
    
    func setGroupLeader(_ isLeader: Bool) {
        isGroupLeader = isLeader
        userDefaults.set(isLeader, forKey: isLeaderKey)
    }
    
    private func saveGroups() {
        if let data = try? JSONEncoder().encode(groups) {
            userDefaults.set(data, forKey: groupsKey)
        }
    }
    
    var currentGroup: [BetComponents.Player]? {
        guard let index = currentGroupIndex, index < groups.count else { return nil }
        return groups[index]
    }
    
    func isPlayerInCurrentGroup(_ player: BetComponents.Player) -> Bool {
        currentGroup?.contains(where: { $0.id == player.id }) ?? false
    }
    
    func getGroupForPlayer(_ player: BetComponents.Player) -> Int? {
        groups.firstIndex { group in
            group.contains { $0.id == player.id }
        }
    }
    
    func resetGroups() {
        groups = []
        currentGroupIndex = nil
        isGroupLeader = false
        userDefaults.removeObject(forKey: groupsKey)
        userDefaults.removeObject(forKey: currentGroupKey)
        userDefaults.removeObject(forKey: isLeaderKey)
        objectWillChange.send()
    }
} 