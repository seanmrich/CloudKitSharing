import Foundation

extension UserDefaults {
    var noteRecordData: Data? {
        get { data(forKey: .noteRecordDataKey) }
        set { set(newValue, forKey: .noteRecordDataKey) }
    }
    
    var zoneCreated: Bool {
        get { bool(forKey: .zoneCreatedKey) }
        set { set(newValue, forKey: .zoneCreatedKey) }
    }
    
    var note: Note? {
        get {
            guard let noteText = string(forKey: .noteTextKey) else { return nil }
            return Note(text: noteText)
        }
        set {
            set(newValue?.text, forKey: .noteTextKey)
        }        
    }
}


extension String {
    fileprivate static var noteTextKey: String { "noteText" }
    fileprivate static var noteRecordDataKey: String { "noteRecordData" }
    fileprivate static var zoneCreatedKey: String { "zoneCreated" }
}
