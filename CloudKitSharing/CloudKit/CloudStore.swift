import CloudKit

final class CloudStore: ObservableObject {
    let note: Note
    lazy private var privateZoneID = CKRecordZone.ID(zoneName: .privateZoneName)
    lazy var container = CKContainer(identifier: "iCloud.com.redZeppelin.Rewards")
    lazy private var privateDb = container.privateCloudDatabase
    
    var noteRecord: CKRecord? {
        guard let data = UserDefaults.standard.noteRecordData else { return nil }
        guard let decoder = try? NSKeyedUnarchiver(forReadingFrom: data) else { return nil }
        guard let record = CKRecord(coder: decoder) else { return nil }
        record[.textField] = note.text
        return record
    }
    
    init() {
        if let note = UserDefaults.standard.note {
            self.note = note
        }
        else {
            self.note = Note(text: UUID().uuidString)
            UserDefaults.standard.note = self.note
        }
        createZone { [weak self] in
            self?.sendNote()
        }
    }
    
    private func createZone(completion: @escaping ()->()) {
        if UserDefaults.standard.zoneCreated { return completion() }
        print("Creating zone")
        let privateZone = CKRecordZone(zoneID: privateZoneID)
        let operation = CKModifyRecordZonesOperation(recordZonesToSave: [privateZone], recordZoneIDsToDelete: nil)
        operation.modifyRecordZonesCompletionBlock = { saved, _, error in
            print("Zone creation sent")
            guard error == nil else { assertionFailure(); return completion() }
            print("Zone created")
            UserDefaults.standard.zoneCreated = true
            completion()
        }
        operation.qualityOfService = .userInitiated
        privateDb.add(operation)
    }
    
    private func sendNote() {
        if UserDefaults.standard.noteRecordData != nil { return }
        let newRecordID = CKRecord.ID(recordName: UUID().uuidString, zoneID: privateZoneID)
        let newRecord = CKRecord(recordType: .noteRecordType, recordID: newRecordID)
        newRecord[.textField] = note.text
        let sendOperation = CKModifyRecordsOperation(recordsToSave: [newRecord], recordIDsToDelete: nil)
        print("Sending note")
        sendOperation.modifyRecordsCompletionBlock = { saved, _, error in
            print("Note sent")
            guard error == nil, let noteRecord = saved?.first else { assertionFailure(); return }
            let encoder = NSKeyedArchiver(requiringSecureCoding: true)
            noteRecord.encodeSystemFields(with: encoder)
            UserDefaults.standard.noteRecordData = encoder.encodedData
            print("Note cached")
        }
        sendOperation.qualityOfService = .userInitiated
        privateDb.add(sendOperation)
    }
}


extension String {
    fileprivate static var privateZoneName: String { "private-zone" }
    fileprivate static var noteRecordType: String { "Note" }
    fileprivate static var textField: String { "text" }
}
